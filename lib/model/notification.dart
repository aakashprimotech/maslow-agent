/*
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

  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      userRef: data['userRef'] as DocumentReference?,
      query: data['query'] as String,
      email: data['email'] as String?,
      status: data['status'] as bool,
      agentFlowRef: data['agentFlowRef'] as DocumentReference,
      createdAt: data['createdAt'] as Timestamp,
    );
  }
}
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final DocumentReference? userRef;
  final String query;
  final String? email;
  final DocumentReference agentFlowRef;
  final Timestamp createdAt;
  final bool status;
  final bool isAccepted;

  NotificationModel({
    required this.userRef,
    required this.query,
    required this.email,
    required this.agentFlowRef,
    required this.createdAt,
    required this.status,
    required this.isAccepted,
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
    };
  }
}
