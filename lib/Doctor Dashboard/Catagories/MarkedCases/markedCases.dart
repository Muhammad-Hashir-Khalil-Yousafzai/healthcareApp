import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MarkedCases extends StatefulWidget {
  @override
  _MarkedCasesState createState() => _MarkedCasesState();
}

class _MarkedCasesState extends State<MarkedCases> {
  List<Map<String, dynamic>> bookmarkedCases = [];
  String searchQuery = "";
  String selectedCategory = "All";
  List<String> categories = ["All", "Heart", "Diabetes", "Lungs", "BP", "Mental"];

  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchBookmarkedCases();
  }

  Future<void> fetchBookmarkedCases() async {
    if (userId == null) return;

    final doctorDoc = await FirebaseFirestore.instance.collection('doctors').doc(userId).get();
    final savedCaseIds = List<String>.from(doctorDoc.data()?['saved_cases'] ?? []);

    if (savedCaseIds.isEmpty) return;

    final casesSnapshot = await FirebaseFirestore.instance
        .collection('Findcases')
        .where(FieldPath.documentId, whereIn: savedCaseIds)
        .get();

    setState(() {
      bookmarkedCases = casesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "title": data["title"] ?? "",
          "details": data["details"] ?? "", // updated field name
          "category": data["category"] ?? "",
        };
      }).toList();
    });
  }

  Future<void> _removeBookmark(String caseId) async {
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance.collection('doctors').doc(userId);
    final doc = await docRef.get();
    List<dynamic> saved = doc.data()?['saved_cases'] ?? [];

    saved.remove(caseId);
    await docRef.update({"saved_cases": saved});
    fetchBookmarkedCases();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredCases = bookmarkedCases.where((caseItem) {
      final matchCategory = selectedCategory == "All" || caseItem["category"] == selectedCategory;
      final matchSearch = caseItem["title"].toLowerCase().contains(searchQuery.toLowerCase()) ||
          caseItem["details"].toLowerCase().contains(searchQuery.toLowerCase()); // updated
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
                      onSelected: (_) {
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
                        caseItem["title"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                      subtitle: Text(
                        caseItem["details"].split(' ').take(20).join(' ') + '...',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark, color: Colors.deepPurple),
                        onPressed: () => _removeBookmark(caseItem["id"]),
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

  void _showCaseDetails(BuildContext context, Map<String, dynamic> caseItem) {
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
                caseItem["title"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                caseItem["details"].split(' ').take(20).join(' ') + '...',
                style: const TextStyle(fontSize: 16),
              ),

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
