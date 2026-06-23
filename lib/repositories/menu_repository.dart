import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:food_express/data/seed_menu.dart';
import 'package:food_express/models/food.dart';

class MenuRepository {
  MenuRepository({
    FirebaseFirestore? firestore,
    bool firebaseEnabled = true,
  })  : _firestore = firestore,
        _firebaseEnabled = firebaseEnabled;

  final FirebaseFirestore? _firestore;
  final bool _firebaseEnabled;

  Stream<List<Food>> watchMenu() async* {
    if (kDebugMode) {
      yield seedMenu;
    }

    if (!_firebaseEnabled) return;

    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      yield* firestore
          .collection('menuItems')
          .where('isAvailable', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs.map(Food.fromFirestore).toList();
        return items.isEmpty && kDebugMode ? seedMenu : items;
      });
    } on FirebaseException catch (error) {
      debugPrint('MenuRepository Firebase error: ${error.message}');
      yield seedMenu;
    } catch (error) {
      debugPrint('MenuRepository error: $error');
      yield seedMenu;
    }
  }
}
