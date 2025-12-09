class Group {
  final String id;
  final String name;
  final String ownerId;

  Group({
    required this.id,
    required this.name,
    required this.ownerId,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner'] as String,
    );
  }
}
