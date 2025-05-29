import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app/screens/transcriptionScreen.dart';
import 'package:health_app/services/firebase_services.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? docID;
  void _showAddEventDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController pidController = TextEditingController();
    TextEditingController didController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add Patient",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Patient Name"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: "Patient Age"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: pidController,
                  decoration: InputDecoration(labelText: "Patient ID"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: didController,
                  decoration: InputDecoration(labelText: "Doctor ID"),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            phoneController.text.isNotEmpty &&
                            ageController.text.isNotEmpty &&
                            pidController.text.isNotEmpty &&
                            didController.text.isNotEmpty) {
                          _firebaseService.addDocument(
                              nameController.text,
                              phoneController.text,
                              ageController.text,
                              pidController.text,
                              didController.text);

                          Navigator.pop(context);
                        }
                      },
                      child: Text("Save"),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getDoctorID() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final userData = query.docs.first.data();
      setState(() {
        docID = userData['docID'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getDoctorID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Patients",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: docID == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patients')
                  .where('docID', isEqualTo: docID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final patients = snapshot.data!.docs;

                if (patients.isEmpty) {
                  return const Center(child: Text("No patients found."));
                }

                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final data = patients[index];

                    return Card(
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          data['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        subtitle: Text(
                          "Phone: ${data['phone']}\nAge: ${data['age']}",
                          style: TextStyle(fontSize: 17),
                        ),
                        trailing: Text(
                          data['patID'],
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TranscriptionScreen(
                                  data: data.data() as Map<String, dynamic>),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
