import 'package:cloud_firestore/cloud_firestore.dart';

class BRDComponent {
  final String id;
  final String title;
  final String content;
  final bool isCompleted;
  final DateTime lastModified;

  BRDComponent({
    required this.id,
    required this.title,
    required this.content,
    this.isCompleted = false,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isCompleted': isCompleted,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }

  factory BRDComponent.fromMap(Map<String, dynamic> map) {
    return BRDComponent(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      isCompleted: map['isCompleted'] as bool,
      lastModified: (map['lastModified'] as Timestamp).toDate(),
    );
  }

  BRDComponent copyWith({
    String? id,
    String? title,
    String? content,
    bool? isCompleted,
    DateTime? lastModified,
  }) {
    return BRDComponent(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isCompleted: isCompleted ?? this.isCompleted,
      lastModified: lastModified ?? this.lastModified,
    );
  }
} 