import 'package:cloud_firestore/cloud_firestore.dart';
import 'agent_flow_example.dart';

class AgentFlowModel {
  final String flowName;
  final DocumentReference createdBy;
  final String apiURL;
  final String socketUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String description;
  final bool isPublished;
  final String category;
  final Authentication authentication;
  List<DocumentReference>? marketplaceUsers;
  List<AgentFlowExample>? agentFlowExamples;

  AgentFlowModel({
    required this.flowName,
    required this.createdBy,
    required this.apiURL,
    required this.socketUrl,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.category = '',
    this.isPublished = false,
    required this.authentication,
    this.marketplaceUsers,
    this.agentFlowExamples,
  });

  factory AgentFlowModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AgentFlowModel(
      flowName: data['flowName'] as String,
      createdBy: data['createdBy'] as DocumentReference,
      apiURL: data['apiURL'] as String,
      socketUrl: data['socketUrl'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      isPublished: data['isPublished'] ?? false,
      authentication: Authentication.fromMap(data['authentication'] as Map<String, dynamic>),
      marketplaceUsers: (data['marketplaceUsers'] != null && data['marketplaceUsers'] is List)
          ? (data['marketplaceUsers'] as List<dynamic>)
          .map((item) => item as DocumentReference)
          .toList()
          : null,
      agentFlowExamples: (data['agentFlowExamples'] != null && data['agentFlowExamples'] is List)
          ? (data['agentFlowExamples'] as List<AgentFlowExample>)
          .map((item) => item)
          .toList()
          : null,
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      'flowName': flowName,
      'createdBy': createdBy,
      'apiURL': apiURL,
      'socketUrl': socketUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'description': description,
      'category': category,
      'isPublished': isPublished,
      'authentication': authentication.toMap(),
      'marketplaceUsers': marketplaceUsers,
      'agentFlowExamples': agentFlowExamples,
    };
  }
}

class Authentication {
  final String key;
  final String token;
  final String type;

  Authentication({
    required this.key,
    required this.token,
    required this.type,
  });

  factory Authentication.fromMap(Map<String, dynamic> map) {
    return Authentication(
      key: map['key'] as String,
      token: map['token'] as String,
      type: map['type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'token': token,
      'type': type,
    };
  }
}