import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final List<String> favoriteItems;
  final List<String> orderHistory;
  final Map<String, dynamic> preferences;
  final String? address;
  final String? paymentMethod;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    List<String>? favoriteItems,
    List<String>? orderHistory,
    Map<String, dynamic>? preferences,
    this.address,
    this.paymentMethod,
  })  : favoriteItems = favoriteItems ?? [],
        orderHistory = orderHistory ?? [],
        preferences = preferences ?? {};

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    List<String>? favoriteItems,
    List<String>? orderHistory,
    Map<String, dynamic>? preferences,
    String? address,
    String? paymentMethod,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      favoriteItems: favoriteItems ?? this.favoriteItems,
      orderHistory: orderHistory ?? this.orderHistory,
      preferences: preferences ?? this.preferences,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
} 