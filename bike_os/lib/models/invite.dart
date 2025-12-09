class Invite {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String groupId;
  final String status; // 'pending', 'accepted', 'rejected'

  Invite({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.groupId,
    required this.status,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] as String,
      fromUserId: json['from_user'] as String,
      toUserId: json['to_user'] as String,
      groupId: json['group_id'] as String,
      status: json['status'] as String,
    );
  }
}
