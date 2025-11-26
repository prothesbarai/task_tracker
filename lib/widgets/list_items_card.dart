import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../date_time_helper/date_time_helper.dart';


/// >>> Recent Activity Component ============================================
Widget listItemsCard({required BuildContext context,required String projectName,required String taskId,required String taskName, required String createdAt, required bool isPlaying, required String status,required String totalTime}) {
  void sMessage(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Only one task can play at a time!")));
  }
  int totalSeconds = int.tryParse(totalTime) ?? 0;
  String durationText = DateTimeHelper.formatDuration(totalSeconds);
  return StatefulBuilder(
    builder: (context, setState) {
      Color cardColor;
      if (isPlaying) {cardColor = Colors.blue[100]!;} else if (status == "Paused") {cardColor = Colors.orange[100]!;} else if (status == "Completed") {cardColor = Colors.green[100]!;} else {cardColor = Colors.white;}
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18),),
        child: Row(
          children: [
            Icon(Icons.task, color: Colors.blue, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "$projectName : ", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black,),),
                        TextSpan(text: taskName, style: const TextStyle(fontSize: 12, color: Colors.black38,),),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text("$status | $createdAt",style: TextStyle(fontSize: 12, color: Colors.black38,),),
                  const SizedBox(height: 2),
                  Text("Time Played: $durationText", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if(status == "Playing" || status == "Paused" || status == "Assigned")...[
              Row(
                children: [
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.blue, size: 30,),
                    onPressed: () async {
                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      final taskRef = FirebaseDatabase.instance.ref("users/$uid/tasks");
                      final snapshot = await taskRef.get();
                      final tasksData = snapshot.value as Map?;
                      if (tasksData == null) return;
                      if (!isPlaying) {
                        // Check if any other task is already playing
                        bool anyOtherPlaying = tasksData.entries.any((entry) {final otherTask = Map<String, dynamic>.from(entry.value);return otherTask["isPlaying"] == true;});
                        if (anyOtherPlaying) {
                          sMessage();
                          return;
                        }
                        // Start the selected task
                        final currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
                        await taskRef.child(taskId).update({"isPlaying": true, "lastPlayStartTime": currentTimeStamp,"status" : "Playing"});
                        setState(() { isPlaying = true; });
                      } else {
                        // Pause the selected task
                        final data = tasksData[taskId] as Map;
                        int lastPlayStartTime = data["lastPlayStartTime"] ?? 0;
                        int oldTotalSeconds = int.tryParse(data["singleTaskTotalPlayHour"] ?? "0") ?? 0;
                        int addedSeconds = ((DateTime.now().millisecondsSinceEpoch - lastPlayStartTime) / 1000).round();
                        int newTotalSeconds = oldTotalSeconds + addedSeconds;
                        await taskRef.child(taskId).update({"isPlaying": false, "singleTaskTotalPlayHour": newTotalSeconds.toString(),"status" : "Paused"});
                        setState(() { isPlaying = false; });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.blue, size: 30,),
                    onPressed: () async{
                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      final taskRef = FirebaseDatabase.instance.ref("users/$uid/tasks");
                      final snapshot = await taskRef.get();
                      final tasksData = snapshot.value as Map?;
                      if (tasksData == null) return;
                      await taskRef.child(taskId).update({"isPlaying": false,"status" : "Completed"});
                    },
                  ),
                ],
              )
            ]
          ],
        ),
      );
    },
  );
}
/// <<< Recent Activity Component ============================================