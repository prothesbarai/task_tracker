import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracker/date_time_helper/date_time_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../firebase_auth/email_auth/provider/user_hive_provider.dart';
import '../../utils/constant/app_colors.dart';
import '../../widgets/list_items_card.dart';
import '../show_diff_task_pages/total_all_task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalTasks = 0;
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskProjectNameController = TextEditingController();
  StreamSubscription? _taskSubscription;


  /// >>> Create Dialogue ======================================================
  void openCreateTaskDialog() {
    final currentDateTime = DateTime.now();
    final createdDateOnly = DateTimeHelper.formatDateOnly(currentDateTime);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
          title: Text("Create New Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// >>> Task Name Input
              TextField(controller: taskNameController, decoration: InputDecoration(labelText: "Task Name", border: OutlineInputBorder(),),),
              SizedBox(height: 10,),
              TextField(controller: taskProjectNameController, decoration: InputDecoration(labelText: "Project Name", border: OutlineInputBorder(),),),
              SizedBox(height: 12),
            ],
          ),

          /// >>> Buttons
          actions: [
            ElevatedButton(onPressed: (){ Navigator.pop(context);FocusScope.of(context).unfocus();}, child: Text("Cancel"),),
            ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final taskName = taskNameController.text.trim();
                final projectName = taskProjectNameController.text.trim();
                if(taskName.isNotEmpty || projectName.isNotEmpty) {
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final today = DateTimeHelper.formatDateOnly(DateTime.now());
                  final ref = FirebaseDatabase.instance.ref("users/$uid/tasks");

                  // >>> Check if task with same name exists today
                  final snapshot = await ref.orderByChild("createdDateOnly").equalTo(today).get();
                  final data = snapshot.value as Map?;
                  bool isDuplicate = false;
                  if(data != null){
                    for(var entry in data.entries){
                      final task = Map<String,dynamic>.from(entry.value);
                      if(task["taskName"]?.toString().toLowerCase() == taskName.toLowerCase()){
                        isDuplicate = true;
                        break;
                      }
                    }
                  }

                  if(isDuplicate){
                    if(!mounted) return;
                    showMessage();
                    return;
                  }
                  // >>> If no duplicate, create task
                  final taskId = ref.push().key;
                  await FirebaseDatabase.instance.ref("users/$uid/tasks/$taskId").set({"taskName": taskName, "projectName": projectName,"status" : "Assigned", "singleTaskTotalPlayHour" : "", "lastPlayStartTime" : "","isPlaying":false, "createdAt": currentDateTime.millisecondsSinceEpoch, "createdDateOnly" : createdDateOnly});
                  taskNameController.clear();
                  taskProjectNameController.clear();
                  if(!mounted) return;
                  backPress();
                }
              },
              child: Text("Save"),
            ),

          ],
        );
      },
    );
  }
  /// <<< Create Dialogue ======================================================


  /// >>> Fetch Recent Activities From Firebase ================================
  Stream<List<Map<String, dynamic>>> getRecentActivityStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    String today = DateTimeHelper.formatDateOnly(DateTime.now());
    // >>> For Only Today task Function =>   .orderByChild("createdDateOnly").equalTo(today);
    final ref = FirebaseDatabase.instance.ref("users/$uid/tasks").orderByChild("createdDateOnly").equalTo(today);

    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      // Convert Map → List
      List<Map<String, dynamic>> taskList = data.entries.map((entry) {
        final tasks = Map.from(entry.value);
        return {
          "id": entry.key,
          "taskName": tasks["taskName"] ?? "",
          "projectName": tasks["projectName"] ?? "",
          "createdAt": tasks["createdAt"] ?? "",
          "status": tasks["status"] ?? "",
          "isPlaying": tasks["isPlaying"] ?? false,
          "singleTaskTotalPlayHour": tasks["singleTaskTotalPlayHour"] ?? "0",
        };
      }).toList();

      // >>> Sort by createdAt
      taskList.sort((a, b) {
        DateTime dateA = DateTime.fromMillisecondsSinceEpoch(a["createdAt"]);
        DateTime dateB = DateTime.fromMillisecondsSinceEpoch(b["createdAt"]);
        return dateB.compareTo(dateA); // latest task first
      });

      // <<< Sort by createdAt
      return taskList;
    });
  }
  /// <<< Fetch Recent Activities From Firebase ================================

  /// >>> Fetch Count Activities From Firebase =================================
  Stream<Map<String, int>> getStatusCountStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref("users/$uid/tasks");
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {return {"completed": 0, "assigned": 0, "running": 0, "paused": 0, "all": 0,};}
      int completed = 0;
      int assigned = 0;
      int running = 0;
      int paused = 0;
      data.forEach((key, value) {
        final task = Map<String, dynamic>.from(value);
        final status = task["status"] ?? "";
        if (status == "Completed") completed++;
        if (status == "Assigned") assigned++;
        if (status == "Playing") running++;
        if (status == "Paused") paused++;
      });
      return {"completed": completed, "assigned": assigned, "running": running, "paused": paused, "all": data.length,};
    });
  }
  /// <<< Fetch Count Activities From Firebase =================================

  
  
  /// >>>  This three method only for daily meeting ============================
  // >>> Check Time Range (use 24-hour format)
  bool isMeetingTime(){
    final now = DateTime.now();
    final startTime  = DateTime(now.year, now.month, now.day, 9, 0);
    final endTime  = DateTime(now.year, now.month, now.day, 10, 0);
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
  // >>> Fetch Google Link From Firebase
  Future<String?> getDailyMeetingLink() async{
    final ref = FirebaseDatabase.instance.ref("settings/daily_meet_link");
    final snapshot = await ref.get();
    if (!snapshot.exists) return null;
    return snapshot.value.toString();
  }
  // >>> Join Button Logic
  void onJoinedPressed() async{
    final meetLink = await getDailyMeetingLink();
    if(meetLink == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No meeting link found!")));
      return;
    }
    if(isMeetingTime()){
      launchUrl(Uri.parse("$meetLink"));
    }else{
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meeting time এখন না, পরে চেষ্টা করুন!")));
      }
    }
  }
  /// <<<  This three method only for daily meeting ============================
  
  
  
  void backPress(){
    Navigator.pop(context);
  }

  void showMessage(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task with same name already exists for today!")));
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskProjectNameController.dispose();
    _taskSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserHiveProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      floatingActionButton: SizedBox(
        width: 150,
        height: 50,
        child: FloatingActionButton(
          onPressed: openCreateTaskDialog,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.8),
          elevation: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, size: 22, color: Colors.white),
              SizedBox(width: 6),
              Text("Create Task", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600,),),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {FocusScope.of(context).unfocus();},
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: kToolbarHeight,left: 16,right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// >>> USER SECTION =============================================
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? "Unknown User", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(user?.phone ?? "Unknown User", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500,),),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              /// <<< USER SECTION =============================================


              /// >>> Daily Meeting ============================================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.deepPurple.shade100, borderRadius: BorderRadius.circular(16),),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Daily Scrum Meeting", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                          SizedBox(height: 4),
                          Text("Meet your team about daily update", style: TextStyle(fontSize: 14),),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onJoinedPressed,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),),
                      child: const Text("Join"),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 25),
              /// <<< Daily Meeting ============================================


              /// >>> Status ===================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("See All")
                ],
              ),
              const SizedBox(height: 10),
              StreamBuilder<Map<String, int>>(
                stream: getStatusCountStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.55,),
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),),),
                        );
                      },
                    );
                  }
                  final counts = snapshot.data!;
                  final List<Map<String, dynamic>> statusList = [
                    {"title": "Completed Tasks", "value": counts["completed"].toString(), "icon": Icons.check_circle, "color": Colors.green,},
                    {"title": "Assigned Tasks", "value": counts["assigned"].toString(), "icon": Icons.assignment_outlined, "color": Colors.pinkAccent,},
                    {"title": "Running Tasks", "value": counts["running"].toString(), "icon": Icons.play_circle_fill, "color": Colors.blue,},
                    {"title": "Paused Tasks", "value": counts["paused"].toString(), "icon": Icons.pause_circle_filled, "color": Colors.orange,},
                    {"title": "All Tasks", "value": counts["all"].toString(), "icon": Icons.all_inbox, "color": Colors.brown,},
                  ];
                  return GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: statusList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.55,),
                    itemBuilder: (context, index) {
                      final item = statusList[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item['icon'], color: item['color'], size: 26),
                            SizedBox(height: 6),
                            Text(item['title'], style: TextStyle(fontSize: 13, color: Colors.grey)),
                            SizedBox(height: 6),
                            Text(item['value'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 25),
              /// <<< Status ===================================================


              /// >>> Recent Activity ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recent Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TotalAllTask(),)),child: Text("See All"))
                ],
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<Map<String,dynamic>>>(
                stream: getRecentActivityStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      children: List.generate(3, (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),),),
                        ),
                      )),
                    );
                  }
                  if (snapshot.data!.isEmpty) {return const Text("Today No Activities Found");}
                  return Column(children: snapshot.data!.map((tasks) {return listItemsCard(context: context,taskId: tasks["id"],projectName:tasks["projectName"],taskName: tasks["taskName"], createdAt: DateTimeHelper.formatDateTime(DateTime.fromMillisecondsSinceEpoch(tasks["createdAt"]),), isPlaying: tasks["isPlaying"], status: tasks["status"],totalTime: tasks["singleTaskTotalPlayHour"] ?? "0",);}).toList(),);
                },
              ),
              /// <<< Recent Activity ==========================================

              SizedBox(height: 150,),
            ],
          ),
        ),
      ),
    );
  }
}