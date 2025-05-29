import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Diseasesscreen extends StatefulWidget {
  const Diseasesscreen({super.key});

  @override
  State<Diseasesscreen> createState() => _DiseasesscreenState();
}

class _DiseasesscreenState extends State<Diseasesscreen> {
  // Function to fetch disease details using diseaseID
  Future<Map<String, dynamic>?> fetchDiseaseInfo(String diseaseID) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('diseaseInfo')
        .where('diseaseID', isEqualTo: diseaseID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }

  // Function to show details in a dialog (FIXED)
  void showDiseaseDetails(
      BuildContext context, String diseaseName, String diseaseID) async {
    // Show loading dialog while fetching data
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss while loading
      builder: (context) {
        return const AlertDialog(
          content: SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );

    // Fetch disease details
    final diseaseInfoData = await fetchDiseaseInfo(diseaseID);

    // Close the loading dialog
    Navigator.pop(context);

    if (diseaseInfoData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data found for $diseaseName')),
      );
      return;
    }

    // Extract details
    String symptoms = diseaseInfoData['Symptoms'] ?? 'No symptoms available';
    String cure = diseaseInfoData['Cure'] ?? 'No cure information available';

    // Show the actual details dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(diseaseName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Symptoms:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(symptoms),
                const SizedBox(height: 10),
                const Text("Cure:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(cure),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Common Diseases",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('diseases').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No diseases found"));
          }

          final diseases = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: diseases.length,
            itemBuilder: (context, index) {
              var diseasesData = diseases[index].data() as Map<String, dynamic>;
              String diseaseName = diseasesData['disease'] ?? 'Unknown';
              String diseaseId = diseasesData['diseaseID'] ?? '';
              String imageUrl =
                  diseasesData['image'] ?? ''; // Fetching image URL

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          showDiseaseDetails(context, diseaseName, diseaseId),
                      child: Row(
                        children: [
                          // Display Image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // Disease Name & Description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  diseaseName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Click to see symptoms & cure",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow Icon
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black45,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
