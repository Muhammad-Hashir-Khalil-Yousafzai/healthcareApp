import 'package:flutter/material.dart';

class FindCases extends StatefulWidget {
  const FindCases({super.key});

  @override
  _FindCasesState createState() => _FindCasesState();
}

class _FindCasesState extends State<FindCases> {
  final List<Map<String, String>> allCases = [
    {
      "title": "Heart Attack",
      "description":
      "Severe chest pain radiating to left arm, sweating, and shortness of breath.",
      "category": "Cardiac"
    },
    {
      "title": "Type 2 Diabetes",
      "description":
      "Fatigue, increased thirst, frequent urination, blurred vision, and slow wound healing.",
      "category": "Diabetes"
    },
    {
      "title": "Chronic Asthma",
      "description":
      "Recurrent wheezing, tight chest, coughing at night, worsened by allergens or cold air.",
      "category": "Lungs"
    },
    {
      "title": "Chronic Kidney Disease",
      "description":
      "Swelling in legs, fatigue, difficulty concentrating, foamy urine, and poor appetite.",
      "category": "Kidney"
    },
    {
      "title": "Major Depressive Disorder",
      "description":
      "Persistent sadness, loss of interest in activities, insomnia, and feelings of worthlessness.",
      "category": "Mental"
    },
    {
      "title": "Hypertension (High BP)",
      "description":
      "Often asymptomatic but may cause headaches, nosebleeds, and shortness of breath.",
      "category": "Cardiac"
    },
    {
      "title": "Gestational Diabetes",
      "description":
      "High blood sugar during pregnancy, frequent urination, increased hunger, blurred vision.",
      "category": "Diabetes"
    },
    {
      "title": "COPD (Chronic Obstructive Pulmonary Disease)",
      "description":
      "Long-term cough with mucus, frequent respiratory infections, and wheezing.",
      "category": "Lungs"
    },
    {
      "title": "Kidney Stones",
      "description":
      "Sharp pain in side/back, pink/red urine, nausea, frequent urination, fever.",
      "category": "Kidney"
    },
    {
      "title": "Anxiety Disorder",
      "description":
      "Restlessness, rapid heartbeat, excessive worrying, sweating, sleep issues.",
      "category": "Mental"
    },
  ];

  // Use a Set to store bookmarked titles for efficient checking
  final Set<String> _bookmarkedTitles = <String>{};

  List<String> categories = ["All", "Cardiac", "Diabetes", "Lungs", "Kidney", "Mental"];
  String selectedCategory = "All";
  String searchQuery = "";

  // Method to handle bookmark toggles
  void _handleBookmarkToggled(String title) {
    setState(() {
      if (_bookmarkedTitles.contains(title)) {
        _bookmarkedTitles.remove(title);
      } else {
        _bookmarkedTitles.add(title);
      }
      print('Bookmarked Titles: $_bookmarkedTitles'); // For debugging
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredCases = allCases.where((caseItem) {
      final matchCategory =
          selectedCategory == "All" || caseItem["category"] == selectedCategory;
      final matchSearch = caseItem["title"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          caseItem["description"]!.toLowerCase().contains(searchQuery.toLowerCase());
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
            // 🔍 Search Field
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

            // 🧠 Category Filters
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

            // 📋 Case List
            Expanded(
              child: filteredCases.isEmpty
                  ? const Center(
                child: Text(
                  "No cases found",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: filteredCases.length,
                itemBuilder: (context, index) {
                  final caseItem = filteredCases[index];
                  final isBookmarked = _bookmarkedTitles.contains(caseItem["title"]); //check if bookmarked
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          _handleBookmarkToggled(caseItem["title"]!);
                        },
                      ),
                      onTap: () {
                        _showCaseDetails(context, caseItem);
                      },
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

  // 🪟 Modal for Case Detail
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
              Text(
                caseItem["description"]!,
                style: const TextStyle(fontSize: 16),
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.contact_page, color: Colors.white),
                label: const Text(
                  "View Patient Info",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  // Handle patient contact / view logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Patient Info feature coming soon!")),
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
