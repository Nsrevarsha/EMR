import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<DocumentSnapshot> getUserDetails() {
    final user = _auth.currentUser;
    return _firestore.collection('users').doc(user?.uid).snapshots();
  }

  Future<void> addDocument(
      String name, String phone, String age, String pid, String did) async {
    final User? user = _auth.currentUser;

    if (user != null) {
      _firestore.collection("patients").add({
        'name': name,
        'phone': phone,
        'age': age,
        'patID': pid,
        'docID': did
      }).then((_) {
        print("Patient Added Successfully");
      }).catchError((error) {
        print("Failed to add patient: $error");
      });
    } else {
      print("No user logged in");
    }
  }

  Future<String?> getUserName() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("No authenticated user found!");
      return null;
    }
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    print(querySnapshot.docs.first.data());
    if (querySnapshot.docs.isEmpty) {
      print("No matching document found!");
      return null;
    }

    final userData = querySnapshot.docs.first.data();
    print(userData);
    return userData['name'];
  }
}
