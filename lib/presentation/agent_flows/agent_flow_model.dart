import 'package:cloud_firestore/cloud_firestore.dart';

import 'agents_data_response.dart';

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
  String? dummyQuestion;
  List<AgentReasoning>? dummyAnswer;
  List<DocumentReference>? marketplaceUsers; // New field

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
    this.dummyQuestion,
    this.dummyAnswer,
    this.marketplaceUsers, // Initialize new field
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
      dummyQuestion: data['dummyQuestion'] as String?,
      dummyAnswer: (data['dummyAnswer'] as List<dynamic>?)
          ?.map((item) => AgentReasoning.fromJson(item as Map<String, dynamic>))
          .toList(),
      marketplaceUsers: (data['marketplaceUsers'] as List<dynamic>?)
          ?.map((item) => item as DocumentReference) // No conversion needed
          .toList(),
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
      'dummyQuestion': dummyQuestion,
      'dummyAnswer': dummyAnswer?.map((item) => item.toJson()).toList(),
      'marketplaceUsers': marketplaceUsers, // Directly store DocumentReference
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

/*
import 'package:cloud_firestore/cloud_firestore.dart';

import 'agents_data_response.dart';

class AgentFlowModel {
  final String flowName;
  final DocumentReference createdBy;
  final String apiURL;
  final String socketUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String description;
  final bool isPublished;
  final bool isPublic;
  final String category;
  final Authentication authentication;
  String? dummyQuestion;
  List<AgentReasoning>? dummyAnswer;
  List<DocumentReference>? marketplaceUsers; // New field

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
    this.isPublic = false,
    required this.authentication,
    this.dummyQuestion,
    this.dummyAnswer,
    this.marketplaceUsers, // Initialize new field
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
      isPublic: data['isPublic'] ?? false,
      authentication: Authentication.fromMap(data['authentication'] as Map<String, dynamic>),
      dummyQuestion: data['dummyQuestion'] as String?,
      dummyAnswer: (data['dummyAnswer'] as List<dynamic>?)
          ?.map((item) => AgentReasoning.fromJson(item as Map<String, dynamic>))
          .toList(),
      marketplaceUsers: (data['marketplaceUsers'] as List<dynamic>?)
          ?.map((item) => item as DocumentReference) // Convert dynamic to DocumentReference
          .toList(),
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
      'isPublic': isPublic,
      'authentication': authentication.toMap(),
      'dummyQuestion': dummyQuestion,
      'dummyAnswer': dummyAnswer?.map((item) => item.toJson()).toList(),
      'marketplaceUsers': marketplaceUsers?.map((item) => item.path).toList(), // Convert DocumentReference to path string
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
*/
