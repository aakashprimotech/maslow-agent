import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final DocumentReference? userRef;
  final String query;
  final String? email;
  final DocumentReference agentFlowRef;
  final Timestamp createdAt;
  final bool status;

  NotificationModel({
    required this.userRef,
    required this.query,
    required this.email,
    required this.agentFlowRef,
    required this.createdAt,
    required this.status ,
  });

  Map<String, dynamic> toMap() {
    return {
      'userRef': userRef,
      'query': query,
      'email': email,
      'agentFlowRef': agentFlowRef,
      'createdAt': createdAt,
      'status' : status ?? false,
    };
  }

  factory NotificationModel.fromMap(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      userRef: map['userRef'] as DocumentReference?,
      query: map['query'] as String,
      email: map['email'] as String?,
      status: map['status'] as bool,
      agentFlowRef: map['agentFlowRef'] as DocumentReference,
      createdAt: map['createdAt'] as Timestamp,
    );
  }
}
