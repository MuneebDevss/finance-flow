import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserEntity {
  final String uid;
  final String email;
  final String name;
  final DateTime dateOfBirth;
  final String phoneNumber;
  String preferedCurrency;
  UserEntity({
    this.preferedCurrency="",
    required this.uid,
    required this.email,
    required this.name,
    required this.dateOfBirth,
    required this.phoneNumber,
  });

  // Convert UserEntity to a Map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'phoneNumber': phoneNumber,
      'preferedCurrency': preferedCurrency,
    };
  }

  // Factory constructor to create a UserEntity from Firestore data
  factory UserEntity.fromMap(Map<String, dynamic> map, String documentId) {
    return UserEntity(
      uid: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      dateOfBirth: DateTime.parse(map['dateOfBirth'] ?? DateTime.now().toIso8601String()),
      phoneNumber: map['phoneNumber'] ?? '',
      preferedCurrency: map['preferedCurrency'] ?? '',
    );
  }
}

// Define the Users Repository
class UsersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = "Users";
  Future<void> updateUserProfile(UserEntity user) async {
    try {
      await _firestore.collection(_collectionName).doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
  // Register a new user with email and password
  Future<UserEntity> registerUser({
    required String email,
    required String password,
    required String name,
    required DateTime dateOfBirth,
    required String phoneNumber,
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a UserEntity
      UserEntity newUser = UserEntity(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
      );

      // Store user in Firestore
      await _firestore
          .collection(_collectionName)
          .doc(newUser.uid)
          .set(newUser.toMap());

      return newUser;
    } catch (e) {
      throw Exception("Failed to register user: $e");
    }
  }

  // Login user with email and password
  Future<UserEntity?> loginUser(String email, String password) async {
    try {
      // Authenticate the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve user data from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection(_collectionName)
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return UserEntity.fromMap(userDoc.data()!, userDoc.id);
      } else {
        throw Exception("User not found in Firestore.");
      }
    } catch (e) {
      throw Exception("Failed to log in user: $e");
    }
  }
   Future<bool> checkEmailVerified() async {
    
      User? user = _auth.currentUser;
      await user?.reload(); // Reload user to get the latest state
      return user!.emailVerified;
      }
  // Validate phone number format (Pakistani format)
  bool validatePhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^\+92[0-9]{10}\$');
    return regex.hasMatch(phoneNumber);
  }

  // Validate password format
  bool validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#\$!%*?&])[A-Za-z\d@#\$!%*?&]{8,}\$');
    return regex.hasMatch(password);
  }

  // Retrieve user details by UID
  Future<UserEntity> getUserById(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection(_collectionName)
          .doc(uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return UserEntity.fromMap(userDoc.data()!, userDoc.id);
      } else{
      return UserEntity(uid: "", email: "", name: "", dateOfBirth: DateTime.now()  , phoneNumber: "");
    }
    } catch (e) {
      throw Exception("Failed to retrieve user: $e");
    }
  }

  // Logout the user
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  Future<UserEntity> fetchCurrentUser() async {
    final user=_auth.currentUser;
    if(user!=null){
     return await  getUserById(user.uid);
    }
    else{
      return UserEntity(uid: "", email: "", name: "", dateOfBirth: DateTime.now()  , phoneNumber: "");
    }
  }
}
