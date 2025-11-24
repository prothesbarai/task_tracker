import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../firebase_auth/email_auth/provider/user_hive_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserHiveProvider>(context).user;
    final List<Map<String, dynamic>> statusList = [
      {
        "title": "Tasks Done",
        "value": "05",
        "icon": Icons.check_circle,
        "color": Colors.green,
      },
      {
        "title": "Pending",
        "value": "03",
        "icon": Icons.access_time,
        "color": Colors.orange,
      },
      {
        "title": "In Progress",
        "value": "02",
        "icon": Icons.loop,
        "color": Colors.blue,
      },
      {
        "title": "Upcoming",
        "value": "04",
        "icon": Icons.upcoming,
        "color": Colors.purple,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: kToolbarHeight,left: 16,right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// >>> USER SECTION ===============================================
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
            /// <<< USER SECTION ===============================================

            /// >>> Daily Meeting ==============================================
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
            /// <<< Daily Meeting ==============================================


            /// >>> Status =====================================================
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
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item['icon'], color: item['color'], size: 26),
                      SizedBox(height: 6),
                      Text(item['title'], style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(item['value'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            /// <<< Status =====================================================



            /// >>> Recent Activity ============================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Recent Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("See All")
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(3, (index) => _recentActivityCard()),
            /// <<< Recent Activity ============================================
          ],
        ),
      ),
    );
  }


  /// >>> Recent Activity Component ============================================
  Widget _recentActivityCard() {
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
              children: const [
                Text("Daily Standup Meeting", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Completed at 09:00 AM"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// <<< Recent Activity Component ============================================
}
