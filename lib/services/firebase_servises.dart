import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register user
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Register Error: $e");
      rethrow;
    }
  }

  // Login user
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add ToDo
  Future<void> addTodo(String title) async {
    await _firestore.collection('todos').add({
      'title': title,
      'isDone': false,
      'createdAt': Timestamp.now(),
    });
  }

  // Update isDone
  Future<void> toggleTodoDone(String docId, bool currentStatus) async {
    await _firestore.collection('todos').doc(docId).update({
      'isDone': !currentStatus,
    });
  }

  // Update Title
  Future<void> updateTodoTitle(String docId, String newTitle) async {
    await _firestore.collection('todos').doc(docId).update({
      'title': newTitle,
    });
  }

  // Delete
  Future<void> deleteTodo(String docId) async {
    await _firestore.collection('todos').doc(docId).delete();
  }

  // Stream todos
  Stream<QuerySnapshot> getTodos() {
    return _firestore
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}