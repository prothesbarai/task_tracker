import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:task_tracker/date_time_helper/date_time_helper.dart';
import '../../widgets/list_items_card.dart';

class TotalAllTask extends StatefulWidget {
  const TotalAllTask({super.key});

  @override
  State<TotalAllTask> createState() => _TotalAllTaskState();
}

class _TotalAllTaskState extends State<TotalAllTask> {

  String searchQuery = "";

  /// >>> Fetch all tasks ======================================================
  Stream<List<Map<String, dynamic>>> getAllTaskStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref("users/$uid/tasks");

    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      List<Map<String, dynamic>> taskList = data.entries.map((entry) {
        final tasks = Map<String, dynamic>.from(entry.value);
        return {"id": entry.key, "taskName": tasks["taskName"] ?? "", "projectName": tasks["projectName"] ?? "", "createdAt": tasks["createdAt"] ?? 0, "status": tasks["status"] ?? "", "isPlaying": tasks["isPlaying"] ?? false, "singleTaskTotalPlayHour": tasks["singleTaskTotalPlayHour"] ?? "0",};
      }).toList();

      /// Sort New to Old
      taskList.sort((a, b) {return b["createdAt"].toString().compareTo(a["createdAt"].toString());});

      return taskList;
    });
  }
  /// <<< Fetch all tasks ======================================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Tasks"),
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextFormField(
                onChanged: (value) {setState(() {searchQuery = value.toLowerCase().trim();});},
                decoration: InputDecoration(
                  hintText: "Search Task...",
                  prefixIcon: Icon(Icons.search, size: 18,),
                  filled: true,
                  isDense: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10,),
                  constraints: const BoxConstraints(minHeight: 36, maxHeight: 36,),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),
                ),
              ),
            )
        ),
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {FocusScope.of(context).unfocus();},
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: getAllTaskStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {return const Center(child: CircularProgressIndicator());}

            List<Map<String, dynamic>> tasks = snapshot.data!;

            if(searchQuery.isNotEmpty){
              tasks = tasks.where((t){
                final name = t["taskName"].toString().toLowerCase();
                final project = t["projectName"].toString().toLowerCase();
                return name.contains(searchQuery) || project.contains(searchQuery);
              }).toList();
            }

            if (tasks.isEmpty) {
              return const Center(child: Text("No Task Found", style: TextStyle(fontSize: 16),),);
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final t = tasks[index];
                return listItemsCard(
                  context: context,
                  taskId: t["id"],
                  taskName: t["taskName"],
                  projectName: t["projectName"],
                  createdAt: DateTimeHelper.formatDateTime(DateTime.fromMillisecondsSinceEpoch(t["createdAt"]),).toString(),
                  isPlaying: t["isPlaying"],
                  status: t["status"],
                  totalTime: t["singleTaskTotalPlayHour"].toString(),
                );

              },
            );
          },
        ),
      ),
    );
  }
}
