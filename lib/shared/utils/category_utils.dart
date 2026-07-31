import 'package:flutter/material.dart';

class CategoryMeta {
  final IconData icon;
  final Color color;
  final Color bg;

  const CategoryMeta(this.icon, this.color, this.bg);
}

class CategoryUtils {
  static const Map<String, CategoryMeta> meta = {
    'Food & Dining':   CategoryMeta(Icons.restaurant_outlined,    Color(0xFFFF7043), Color(0xFFFFF3F0)),
    'Transport':       CategoryMeta(Icons.local_gas_station_outlined, Color(0xFF42A5F5), Color(0xFFE8F4FD)),
    'Entertainment':   CategoryMeta(Icons.tv_outlined,             Color(0xFFAB47BC), Color(0xFFF8F0FA)),
    'Groceries':       CategoryMeta(Icons.shopping_basket_outlined, Color(0xFF26A69A), Color(0xFFE8F5F4)),
    'Health':          CategoryMeta(Icons.favorite_border,          Color(0xFFEF5350), Color(0xFFFFF0F0)),
    'Shopping':        CategoryMeta(Icons.shopping_bag_outlined,    Color(0xFFFF7043), Color(0xFFFFF3F0)),
    'Housing':         CategoryMeta(Icons.home_outlined,            Color(0xFFAB47BC), Color(0xFFF8F0FA)),
    'Bills':           CategoryMeta(Icons.receipt_long_outlined,    Color(0xFF78909C), Color(0xFFF0F2F4)),
    'Education':       CategoryMeta(Icons.school_outlined,          Color(0xFF5C6BC0), Color(0xFFF0F1FB)),
    'Travel':          CategoryMeta(Icons.flight_outlined,          Color(0xFF29B6F6), Color(0xFFE7F7FE)),
    'Other':           CategoryMeta(Icons.category_outlined,        Color(0xFF8D6E63), Color(0xFFF5F0EE)),
  };

  static CategoryMeta resolve(String categoryName) {
    return meta[categoryName] ?? meta['Other']!;
  }
}
