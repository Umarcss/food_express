import 'package:cloud_firestore/cloud_firestore.dart';

enum FoodCategory {
  burgers,
  salads,
  sides,
  desserts,
  drinks;

  String get label {
    switch (this) {
      case FoodCategory.burgers:
        return 'Burgers';
      case FoodCategory.salads:
        return 'Salads';
      case FoodCategory.sides:
        return 'Sides';
      case FoodCategory.desserts:
        return 'Desserts';
      case FoodCategory.drinks:
        return 'Drinks';
    }
  }

  static FoodCategory fromName(String value) {
    return FoodCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => FoodCategory.burgers,
    );
  }
}

class Food {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int priceKobo;
  final FoodCategory category;
  final List<Addon> availableAddons;
  final bool isAvailable;
  final int sortOrder;

  const Food({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.priceKobo,
    required this.category,
    required this.availableAddons,
    this.isAvailable = true,
    this.sortOrder = 0,
  });

  factory Food.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    final addons = data['addons'];
    return Food(
      id: snapshot.id,
      name: data['name'] as String? ?? 'Untitled item',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      priceKobo: (data['priceKobo'] as num?)?.toInt() ?? 0,
      category: FoodCategory.fromName(data['category'] as String? ?? ''),
      availableAddons: addons is List
          ? addons
              .whereType<Map>()
              .map((addon) => Addon.fromMap(Map<String, dynamic>.from(addon)))
              .toList()
          : const [],
      isAvailable: data['isAvailable'] as bool? ?? true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'priceKobo': priceKobo,
      'category': category.name,
      'addons': availableAddons.map((addon) => addon.toMap()).toList(),
      'isAvailable': isAvailable,
      'sortOrder': sortOrder,
    };
  }

  bool get usesAssetImage => imageUrl.startsWith('lib/');

  String get describtion => description;
  String get imagePath => imageUrl;
  double get price => priceKobo / 100;
}

class Addon {
  final String id;
  final String name;
  final int priceKobo;

  const Addon({
    required this.id,
    required this.name,
    required this.priceKobo,
  });

  factory Addon.fromMap(Map<String, dynamic> map) {
    return Addon(
      id: map['id'] as String? ?? map['name'] as String? ?? '',
      name: map['name'] as String? ?? 'Add-on',
      priceKobo: (map['priceKobo'] as num?)?.toInt() ??
          (((map['price'] as num?) ?? 0) * 100).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'priceKobo': priceKobo,
    };
  }

  double get price => priceKobo / 100;

  @override
  bool operator ==(Object other) {
    return other is Addon && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
