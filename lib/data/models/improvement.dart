class Improvement {
  final String id;
  final String description;
  final String priority;
  final bool isCompleted;
  final DateTime createdAt;

  Improvement({
    required this.id,
    required this.description,
    this.priority = 'medium',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Improvement.fromJson(Map<String, dynamic> json) {
    return Improvement(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 