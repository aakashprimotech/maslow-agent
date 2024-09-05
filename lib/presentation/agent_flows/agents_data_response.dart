class AgentReasoning {
  final String agentName;
  final List<String>? messages;
  final String next;
  final String? instructions;
  final List<dynamic> usedTools;
  final List<dynamic> sourceDocuments;
  final Map<String, dynamic> state;
  final String nodeId;

  AgentReasoning({
    required this.agentName,
    required this.messages,
    required this.next,
    required this.instructions,
    required this.usedTools,
    required this.sourceDocuments,
    required this.state,
    required this.nodeId,
  });

  factory AgentReasoning.fromJson(Map<String, dynamic> json) {
    return AgentReasoning(
      agentName: json['agentName'] as String? ?? '',
      messages: (json['messages'] as List<dynamic>? ?? []).cast<String>(),
      next: json['next'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      usedTools: json['usedTools'] as List<dynamic>? ?? [],
      sourceDocuments: json['sourceDocuments'] as List<dynamic>? ?? [],
      state: json['state'] as Map<String, dynamic>? ?? {},
      nodeId: json['nodeId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentName': agentName,
      'messages': messages,
      'next': next,
      'instructions': instructions,
      'usedTools': usedTools,
      'sourceDocuments': sourceDocuments,
      'state': state,
      'nodeId': nodeId,
    };
  }
}

class DataModel {
  final String text;
  final String question;
  final String chatId;
  final String chatMessageId;
  final String sessionId;
  final List<AgentReasoning> agentReasoning;

  DataModel({
    required this.text,
    required this.question,
    required this.chatId,
    required this.chatMessageId,
    required this.sessionId,
    required this.agentReasoning,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      text: json['text'] as String? ?? '',
      question: json['question'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      chatMessageId: json['chatMessageId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
 /*     agentReasoning: (json['agentReasoning'] as List<dynamic>? ?? [])
          .map((item) => AgentReasoning.fromJson(item as Map<String, dynamic>))
          .toList(),*/
      agentReasoning: (json['agentReasoning'] as List)
          .map((i) => AgentReasoning.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'question': question,
      'chatId': chatId,
      'chatMessageId': chatMessageId,
      'sessionId': sessionId,
      'agentReasoning': agentReasoning.map((item) => item.toJson()).toList(),
    };
  }
}