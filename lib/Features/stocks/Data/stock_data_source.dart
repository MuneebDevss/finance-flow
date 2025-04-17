//#E7VGEB1DL8GTREMX
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Features/stocks/Data/stocks_asset.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // CRUD operations for assets
  Future<List<Asset>> getAssets() async {
    try {
      final snapshot = await _firestore
          .collection('stockAssets')
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => Asset.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching stockAssets: $e');
      return [];
    }
  }

  Future<Asset?> getAsset(String assetId) async {
    try {
      final doc = await _firestore.collection('stockAssets').doc(assetId).get();
      if (doc.exists) {
        return Asset.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error fetching asset: $e');
      return null;
    }
  }

  Future<bool> addAsset(Asset asset) async {
    try {
      await _firestore.collection('stockAssets').add(asset.toJson());
      return true;
    } catch (e) {
      print('Error adding asset: $e');
      return false;
    }
  }

  Future<bool> updateAsset(Asset asset) async {
    try {
      await _firestore
          .collection('stockAssets')
          .doc(asset.id)
          .update(asset.toJson());
      return true;
    } catch (e) {
      print('Error updating asset: $e');
      return false;
    }
  }

  Future<bool> deleteAsset(String assetId) async {
    try {
      await _firestore.collection('stockAssets').doc(assetId).delete();
      return true;
    } catch (e) {
      print('Error deleting asset: $e');
      return false;
    }
  }
}
