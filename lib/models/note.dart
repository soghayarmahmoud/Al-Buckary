
class Note {
  final int? id;
  final int hadithId;
  final String text;
  final DateTime createdAt;
  final int color; // Color.value stored as integer

  Note({
    this.id,
    required this.hadithId,
    required this.text,
    required this.createdAt,
    this.color = 0xFFFFC107, // Default amber color
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hadith_id': hadithId,
      'text': text,
      'created_at': createdAt.millisecondsSinceEpoch,
      'color': color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      hadithId: map['hadith_id'],
      text: map['text'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      color: map['color'] ?? 0xFFFFC107, // Default amber if null (for migration)
    );
  }
}
