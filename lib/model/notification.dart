import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final DocumentReference? userRef;
  final String query;
  final String? email;
  final DocumentReference agentFlowRef;
  final Timestamp createdAt;
  final bool status;
  final DocumentReference? notificationRef;
  final bool isAccepted;

  NotificationModel({
    required this.userRef,
    required this.query,
    required this.email,
    required this.agentFlowRef,
    required this.createdAt,
    required this.status,
    required this.isAccepted,
    this.notificationRef,
  });

  Map<String, dynamic> toMap() {
    return {
      'userRef': userRef,
      'query': query,
      'email': email,
      'agentFlowRef': agentFlowRef,
      'createdAt': createdAt,
      'status': status,
      'isAccepted': isAccepted,
      'notificationRef': notificationRef
    };
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      userRef: data['userRef'] as DocumentReference?,
      query: data['query'] as String,
      email: data['email'] as String?,
      agentFlowRef: data['agentFlowRef'] as DocumentReference,
      createdAt: data['createdAt'] as Timestamp,
      status: data['status'] as bool,
      isAccepted: data['isAccepted'] as bool,
      notificationRef: doc.reference as DocumentReference?
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userRef': userRef,
      'query': query,
      'email': email,
      'agentFlowRef': agentFlowRef,
      'createdAt': createdAt,
      'status': status,
      'isAccepted' : isAccepted,
      'notificationRef' : notificationRef,
    };
  }
}
