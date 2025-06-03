import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FindCases extends StatefulWidget {
  const FindCases({super.key});

  @override
  _FindCasesState createState() => _FindCasesState();
}

class _FindCasesState extends State<FindCases> {
  List<Map<String, dynamic>> allCases = [];
  Set<String> _bookmarkedCaseIds = <String>{};
  List<String> categories = ["All", "Cardiac", "Diabetes", "Lungs", "Kidney", "Mental"];
  String selectedCategory = "All";
  String searchQuery = "";

  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchCases();
    fetchBookmarkedCases();
  }

  Future<void> fetchCases() async {
    final snapshot = await FirebaseFirestore.instance.collection('Findcases').get();
    setState(() {
      allCases = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "title": data["title"] ?? "",
          "details": data["details"] ?? "", // Use 'details' here
          "category": data["category"] ?? "",
          "imageString": data["imageString"] ?? "",
        };
      }).toList();
    });
  }

  Future<void> fetchBookmarkedCases() async {
    if (userId == null) return;
    final doc = await FirebaseFirestore.instance.collection('doctors').doc(userId).get();
    final saved = doc.data()?['saved_cases'] ?? [];
    setState(() {
      _bookmarkedCaseIds = Set<String>.from(saved);
    });
  }

  Future<void> toggleBookmark(String caseId) async {
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance.collection('doctors').doc(userId);
    final doc = await docRef.get();
    List<dynamic> saved = doc.data()?['saved_cases'] ?? [];

    if (_bookmarkedCaseIds.contains(caseId)) {
      saved.remove(caseId);
      _bookmarkedCaseIds.remove(caseId);
    } else {
      saved.add(caseId);
      _bookmarkedCaseIds.add(caseId);
    }

    await docRef.update({"saved_cases": saved});
    setState(() {});
  }

  String truncateDetails(String? text, int wordLimit) {
    if (text == null || text.trim().isEmpty) return "No details provided.";
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= wordLimit) return text;
    return words.sublist(0, wordLimit).join(' ') + '...';
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredCases = allCases.where((caseItem) {
      final matchCategory = selectedCategory == "All" || caseItem["category"] == selectedCategory;
      final matchSearch = caseItem["title"].toLowerCase().contains(searchQuery.toLowerCase()) ||
          caseItem["details"].toLowerCase().contains(searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Find Cases',
          style: TextStyle(color: Colors.white),
        ),
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
                  ? const Center(child: Text("No cases found", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                itemCount: filteredCases.length,
                itemBuilder: (context, index) {
                  final caseItem = filteredCases[index];
                  final isBookmarked = _bookmarkedCaseIds.contains(caseItem["id"]);
                  final shortDetails = truncateDetails(caseItem["details"], 20);

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
                        shortDetails,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () => toggleBookmark(caseItem["id"]),
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
    final shortDetails = truncateDetails(caseItem["details"], 20);

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
              Text(shortDetails, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.local_hospital, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    "Category: ${caseItem["category"]}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
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
