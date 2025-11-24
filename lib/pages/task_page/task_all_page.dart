import 'package:flutter/material.dart';

class TaskAllPage extends StatelessWidget {
  final List<Map<String, dynamic>> allTasks;

  const TaskAllPage({super.key, required this.allTasks});

  List<Color> _gradient(String status) {
    if (status == "completed") {
      return [Colors.green.shade400, Colors.green.shade700];
    } else if (status == "pending") {
      return [Colors.orange.shade300, Colors.orange.shade600];
    } else {
      return [Colors.blue.shade300, Colors.blue.shade600];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Tasks"),
        backgroundColor: Colors.blue,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allTasks.length,
        itemBuilder: (context, index) {
          final t = allTasks[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _gradient(t["status"])),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.task, color: Colors.white, size: 30),
                const SizedBox(width: 12),

                Expanded(
                    child: Text(t["title"],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),

                Text(t["status"].toUpperCase(),
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      ),
    );
  }
}
