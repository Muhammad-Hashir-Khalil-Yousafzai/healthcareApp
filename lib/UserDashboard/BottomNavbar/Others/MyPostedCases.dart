import 'package:flutter/material.dart';

class MyPostedCasesPage extends StatelessWidget {
  const MyPostedCasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list of stories
    final List<Map<String, dynamic>> myCases = [
      {'title': 'Heart Surgery', 'category': 'Surgery'},
      {'title': 'High Blood Pressure', 'category': 'BP'},
      {'title': 'Pain in Chest', 'category': 'Others'},
      {'title': 'Anxiety and Depression', 'category': 'Mental Health'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('My Posted Cases', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: myCases.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          final caseItem = myCases[index];
          return ListTile(
            leading: Icon(Icons.folder_copy_outlined, color: Colors.deepPurple),
            title: Text(caseItem['title']),
            subtitle: Text('Category: ${caseItem['category']}'),
            trailing: PopupMenuButton(
              onSelected: (val) {
                if (val == 'edit') {
                  // TODO: Implement edit logic
                } else if (val == 'delete') {
                  // TODO: Implement delete logic
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          );
        },
      ),
    );
  }
}
