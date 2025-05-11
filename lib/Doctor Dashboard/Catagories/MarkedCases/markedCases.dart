import 'package:flutter/material.dart';

class MarkedCases extends StatefulWidget {
  @override
  _MarkedCasesState createState() => _MarkedCasesState();
}

class _MarkedCasesState extends State<MarkedCases> {
  final List<Map<String, String>> bookmarkedCases = [
    {
      "title": "Heart Attack",
      "description": "Severe chest pain radiating to left arm, sweating, and shortness of breath.",
      "category": "Cardiac"
    },
    {
      "title": "Type 2 Diabetes",
      "description": "Fatigue, increased thirst, frequent urination, blurred vision, and slow wound healing.",
      "category": "Diabetes"
    },
    {
      "title": "Anxiety Disorder",
      "description": "Restlessness, rapid heartbeat, excessive worrying, sweating, sleep issues.",
      "category": "Mental"
    },
  ];

  String searchQuery = "";
  String selectedCategory = "All";
  List<String> categories = ["All", "Cardiac", "Diabetes", "Lungs", "Kidney", "Mental"];

  void _removeBookmark(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove Bookmark"),
        content: Text("Are you sure you want to remove this case from bookmarks?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Remove", style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                bookmarkedCases.removeAt(index);
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredCases = bookmarkedCases.where((caseItem) {
      final matchCategory = selectedCategory == "All" || caseItem["category"] == selectedCategory;
      final matchSearch = caseItem["title"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          caseItem["description"]!.toLowerCase().contains(searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Marked Cases', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 🔍 Search
            TextField(
              decoration: InputDecoration(
                hintText: "Search by keyword...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // 🧠 Category Filter
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: Colors.deepPurple,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // 📋 Bookmarked Cases
            Expanded(
              child: filteredCases.isEmpty
                  ? const Center(child: Text("No bookmarked cases found", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                itemCount: filteredCases.length,
                itemBuilder: (context, index) {
                  final caseItem = filteredCases[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        caseItem["title"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                      subtitle: Text(
                        caseItem["description"]!,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark, color: Colors.deepPurple),
                        onPressed: () => _removeBookmark(index),
                      ),
                      onTap: () => _showCaseDetails(context, caseItem),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 👁️ Modal Bottom Sheet
  void _showCaseDetails(BuildContext context, Map<String, String> caseItem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.deepPurple[50],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caseItem["title"]!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Text(caseItem["description"]!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.local_hospital, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text("Category: ${caseItem["category"]}", style: const TextStyle(fontSize: 16, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.contact_page, color: Colors.white),
                label: const Text("View Patient Info", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Patient Info feature coming soon!")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
