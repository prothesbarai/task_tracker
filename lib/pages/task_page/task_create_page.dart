import 'package:flutter/material.dart';
import 'package:task_tracker/date_time_helper/date_time_helper.dart';

class TaskCreatePage extends StatefulWidget {
  const TaskCreatePage({super.key});

  @override
  State<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  final titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Task"), backgroundColor: Colors.blue,),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(hintText: "Task Title...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),),),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                final formattedTime = DateTimeHelper.formatDateTime(now);

                final newTask = {
                  "title": titleController.text,
                  "time": formattedTime,
                  "status": "pending",
                };

                Navigator.pop(context, newTask);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Save Task"),
            )
          ],
        ),
      ),
    );
  }
}
