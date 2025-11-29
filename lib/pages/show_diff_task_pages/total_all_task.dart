import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:task_tracker/date_time_helper/date_time_helper.dart';
import '../../widgets/list_items_card.dart';

class TotalAllTask extends StatelessWidget {
  const TotalAllTask({super.key});

  /// 🔥 Fetch all tasks (No filter)
  Stream<List<Map<String, dynamic>>> getAllTaskStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref("users/$uid/tasks");

    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      List<Map<String, dynamic>> taskList = data.entries.map((entry) {
        final tasks = Map<String, dynamic>.from(entry.value);
        return {
          "id": entry.key,
          "taskName": tasks["taskName"] ?? "",
          "projectName": tasks["projectName"] ?? "",
          "createdAt": tasks["createdAt"] ?? 0,
          "status": tasks["status"] ?? "",
          "isPlaying": tasks["isPlaying"] ?? false,
          "singleTaskTotalPlayHour": tasks["singleTaskTotalPlayHour"] ?? "0",
        };
      }).toList();

      /// Sort New → Old
      taskList.sort((a, b) {
        return b["createdAt"].toString().compareTo(a["createdAt"].toString());
      });

      return taskList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Tasks"),
        centerTitle: true,
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getAllTaskStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                "No Task Found",
                style: TextStyle(fontSize: 16),
              ),
            );
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
    );
  }
}
