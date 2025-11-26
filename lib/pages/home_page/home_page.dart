import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/date_time_helper/date_time_helper.dart';
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
    DateTime dateTime = DateTime.now();
    final currentDateTime = DateTimeHelper.formatDateTime(dateTime);
    final createdDateOnly = DateTimeHelper.formatDateOnly(dateTime);
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
                if(taskNameController.text.isNotEmpty && taskProjectNameController.text.isNotEmpty) {
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final taskId = FirebaseDatabase.instance.ref("users/$uid/tasks").push().key;
                  await FirebaseDatabase.instance.ref("users/$uid/tasks/$taskId").set({"taskName": taskNameController.text, "projectName": taskProjectNameController.text,"status" : "Assigned", "singleTaskTotalPlayHour" : "", "lastPlayStartTime" : "","isPlaying":false, "createdAt": currentDateTime, "createdDateOnly" : createdDateOnly});
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
      taskList.sort((a, b) {return b["createdAt"].toString().compareTo(a["createdAt"].toString());});
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

  void backPress(){
    Navigator.pop(context);
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
                      onPressed: () {},
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
                  if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
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
                  if (!snapshot.hasData) {return const Center(child: CircularProgressIndicator());}
                  if (snapshot.data!.isEmpty) {return const Text("Today No Activities Found");}
                  return Column(children: snapshot.data!.map((tasks) {return listItemsCard(context: context,taskId: tasks["id"],projectName:tasks["projectName"],taskName: tasks["taskName"], createdAt: tasks["createdAt"], isPlaying: tasks["isPlaying"], status: tasks["status"],totalTime: tasks["singleTaskTotalPlayHour"] ?? "0",);}).toList(),);
                },
              ),
              /// <<< Recent Activity ==========================================

              SizedBox(height: 50,),
            ],
          ),
        ),
      ),
    );
  }
}