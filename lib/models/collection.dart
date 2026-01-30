
import 'dart:ui';

class Collection {
  final int? id;
  final String name;
  final int color;
  final DateTime createdAt;

  Collection({
    this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
