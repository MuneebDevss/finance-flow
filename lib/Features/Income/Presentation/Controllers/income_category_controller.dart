import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IncomeCategoriesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;

  final TextEditingController categoryNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser ?.uid; // Get current user ID
      if (userId == null) {
        Get.snackbar(
          "Error",
          "User  not logged in",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final snapshot = await _firestore
          .collection('categories')
          .doc('incomeCategoriesDocs')
          .collection('items')
          .where('userId', isEqualTo: userId) // Filter by user ID
          .get();
      categories.value =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch categories: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add a category
  Future<void> addCategory(String categoryName) async {
    if (categoryName.isEmpty) {
      Get.snackbar(
        "Error",
        "Category name cannot be empty",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final userId = _auth.currentUser ?.uid; // Get current user ID
      if (userId == null) {
        Get.snackbar(
          "Error",
          "User  not logged in",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await _firestore
          .collection('categories')
          .doc('incomeCategoriesDocs')
          .collection('items')
          .add({'name': categoryName, 'userId': userId}); // Add user ID
      categoryNameController.clear();
      await fetchCategories();
      Get.snackbar(
        "Success",
        "Category added successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add category: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update a category
  Future<void> updateCategory(String id, String newName) async {
    if (newName.isEmpty) {
      Get.snackbar(
        "Error",
        "Category name cannot be empty",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final userId = _auth.currentUser ?.uid; // Get current user ID
      if (userId == null) {
        Get.snackbar(
          "Error",
          "User  not logged in",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Check if the category belongs to the user
      final doc = await _firestore
          .collection('categories')
 .doc('incomeCategoriesDocs')
          .collection('items')
          .doc(id)
          .get();

      if (doc.exists && doc.data()?['userId'] == userId) {
        await _firestore
            .collection('categories')
            .doc('incomeCategoriesDocs')
            .collection('items')
            .doc(id)
            .update({'name': newName});
        await fetchCategories();
        Get.snackbar(
          "Success",
          "Category updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Category does not belong to the current user",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update category: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser  ?.uid; // Get current user ID
      if (userId == null) {
        Get.snackbar(
          "Error",
          "User   not logged in",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Check if the category belongs to the user
      final doc = await _firestore
          .collection('categories')
          .doc('incomeCategoriesDocs')
          .collection('items')
          .doc(id)
          .get();

      if (doc.exists && doc.data()?['userId'] == userId) {
        await _firestore
            .collection('categories')
            .doc('incomeCategoriesDocs')
            .collection('items')
            .doc(id)
            .delete();
        await fetchCategories();
        Get.snackbar(
          "Success",
          "Category deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Category does not belong to the current user",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete category: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
