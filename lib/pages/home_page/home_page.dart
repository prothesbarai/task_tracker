import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/date_time_helper/date_time_helper.dart';
import '../../firebase_auth/email_auth/provider/user_hive_provider.dart';
import '../../utils/constant/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalTasks = 0;
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskProjectNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    loadUserTotalTask();
  }


  /// >>> Show Total Created Task ==============================================
  void loadUserTotalTask(){
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseDatabase.instance.ref("users/$uid/tasks").onValue.listen((event){
      final data = event.snapshot.value;
      if(data == null){
        setState(() {totalTasks = 0;});
        return;
      }
      final taskMap = Map<String,dynamic>.from(data as Map);
      setState(() {totalTasks = taskMap.length;});
    });
  }
  /// <<< Show Total Created Task ==============================================


  /// >>> Create Dialogue ======================================================
  void openCreateTaskDialog() {
    DateTime dateTime = DateTime.now();
    final currentDateTime = DateTimeHelper.formatDateTime(dateTime);
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
                  await FirebaseDatabase.instance.ref("users/$uid/tasks/$taskId").set({"taskName": taskNameController.text, "projectName": taskProjectNameController.text,"status" : "Assigned", "singleTaskTotalPlayHour" : "", "isPlaying":false, "createdAt": currentDateTime,});
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
    final ref = FirebaseDatabase.instance.ref("users/$uid/tasks");
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.entries.map((entry) {
        final tasks = Map.from(entry.value);
        return {
          "id": entry.key,
          "taskName": tasks["taskName"] ?? "",
          "projectName": tasks["projectName"] ?? "",
          "createdAt": tasks["createdAt"] ?? "",
          "status": tasks["status"] ?? "",
          "isPlaying": tasks["isPlaying"] ?? false,
        };
      }).toList();
    });
  }
  /// <<< Fetch Recent Activities From Firebase ================================



  void backPress(){
    Navigator.pop(context);
  }
  @override
  void dispose() {
    taskNameController.dispose();
    taskProjectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserHiveProvider>(context).user;
    final List<Map<String, dynamic>> statusList = [
      {
        "title": "Today Completed Tasks",
        "value": "05",
        "icon": Icons.check_circle,
        "color": Colors.green,
        "status": "Pending",
        "singleTaskTotalPlayHour": "",
      },
      {
        "title": "Pending Tasks",
        "value": "03",
        "icon": Icons.access_time,
        "color": Colors.orange,
        "status": "Pending",
        "singleTaskTotalPlayHour": "",
      },
      {
        "title": "In Progress Tasks",
        "value": "02",
        "icon": Icons.loop,
        "color": Colors.orange,
        "status": "Pending",
        "singleTaskTotalPlayHour": "",
      },
      {
        "title": "All Tasks",
        "value": totalTasks.toString(),
        "icon": Icons.all_inbox,
        "color": Colors.orange,
        "status": "Pending",
        "singleTaskTotalPlayHour": "",
      },
    ];

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
                  Text("See All") ],
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: statusList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.28,),
                itemBuilder: (context, index) {
                  final item = statusList[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 10),
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
              ),
              const SizedBox(height: 25),
              /// <<< Status ===================================================


              /// >>> Recent Activity ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Recent Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("See All")
                ],
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<Map<String,dynamic>>>(
                stream: getRecentActivityStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {return const Center(child: CircularProgressIndicator());}
                  if (snapshot.data!.isEmpty) {return const Text("No Recent Activities Found");}
                  return Column(children: snapshot.data!.map((tasks) {return _recentActivityCard(taskName: tasks["taskName"], createdAt: tasks["createdAt"], isPlaying: tasks["isPlaying"], status: tasks["status"],);}).toList(),);
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

  /// >>> Recent Activity Component ============================================
  Widget _recentActivityCard({required String taskName, required String createdAt, required bool isPlaying, required String status,}) {
    bool localIsPlaying = isPlaying;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12),),
                child: const Icon(Icons.task, color: Colors.blue, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(taskName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("$status | $createdAt"),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(localIsPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.blue, size: 32,),
                    onPressed: () {
                      setState(() {
                        localIsPlaying = !localIsPlaying;
                      });
                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.blue, size: 32,),
                    onPressed: () {

                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
/// <<< Recent Activity Component ============================================
}
