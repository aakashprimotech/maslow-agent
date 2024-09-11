import 'package:cloud_firestore/cloud_firestore.dart';
import 'agents_data_response.dart';

class AgentFlowExample {
  final Timestamp createdAt;
  final String? dummyQuestion;
  List<dynamic>? dummyAnswer;  // Keep as dynamic to accept toJson() output
  final String label;

  AgentFlowExample({
    required this.createdAt,
    this.dummyQuestion,
    this.dummyAnswer,
    required this.label,
  });

  // Factory constructor to create an instance from Firestore data
  factory AgentFlowExample.fromFirestore(Map<String, dynamic> data) {
    return AgentFlowExample(
      createdAt: data['createdAt'] as Timestamp,
      dummyQuestion: data['dummyQuestion'] as String?,
      dummyAnswer: (data['dummyAnswer'] as List<dynamic>?)
          ?.map((item) => AgentReasoning.fromJson(item as Map<String, dynamic>))
          .toList(),
      label: data['label'] as String,
    );
  }

  // Method to convert the object to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': createdAt,
      'dummyQuestion': dummyQuestion,
      'dummyAnswer': dummyAnswer,  // dummyAnswer already contains Map<String, dynamic>
      'label': label,
    };
  }
}
