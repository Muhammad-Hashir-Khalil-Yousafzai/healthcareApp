import 'package:flutter/material.dart';

class MyPostedstoriesPage extends StatelessWidget {
  const MyPostedstoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list of stories
    final List<Map<String, dynamic>> mystories = [
      {'title': 'Back Surgery Experience', 'category': 'Surgery'},
      {'title': 'Mental Health Recovery', 'category': 'Mental Health'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('My Posted stories', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: mystories.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          final caseItem = mystories[index];
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
