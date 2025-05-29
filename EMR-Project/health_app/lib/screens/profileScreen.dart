import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_app/screens/loginpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("No authenticated user found!");
      return;
    }
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) {
      print("No matching document found!");
      return;
    }

    final document = querySnapshot.docs.first;
    setState(() {
      userData = document.data();
    });
  }

  @override
  Widget build(BuildContext context) {
    return userData == null
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Profile Picture + Logout Button
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              (userData!['name'] as String?)?.isNotEmpty == true
                                  ? (userData!['name'] as String)
                                      .substring(0, 1)
                                      .toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  DateTime logoutTime = DateTime.now();
                                  final querySnapshot = await _firestore
                                      .collection('users')
                                      .where('email', isEqualTo: user.email)
                                      .limit(1)
                                      .get();

                                  if (querySnapshot.docs.isNotEmpty) {
                                    final document = querySnapshot.docs.first;

                                    await document.reference.update({
                                      'logout_time': logoutTime,
                                    });
                                    await _auth.signOut();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                    );
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildInfoCard(context),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(context, Icons.person, 'Name',
                userData!['name'] ?? 'Not provided'),
            const Divider(),
            _buildInfoRow(context, Icons.email, 'Email',
                userData!['email'] ?? 'Not provided'),
            const Divider(),
            _buildInfoRow(context, Icons.phone, 'Phone',
                userData!['phone'] ?? 'Not provided'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
