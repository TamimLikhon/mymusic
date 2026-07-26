class Tag {
  final String id;
  final String name;
  final int color;
  final String? icon;
  final int createdAt;
  final int updatedAt;

  Tag({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });
}
