class SlammieBotResponse {
  SlammieBotResponse({
    this.text,
    this.question,
    this.chatId,
    this.chatMessageId,
    this.sessionId,
  });

  final String? text;
  final String? question;
  final String? chatId;
  final String? chatMessageId;
  final String? sessionId;

  factory SlammieBotResponse.fromJson(Map<String, dynamic> json){
    return SlammieBotResponse(
      text: json["text"],
      question: json["question"],
      chatId: json["chatId"],
      chatMessageId: json["chatMessageId"],
      sessionId: json["sessionId"],
    );
  }
}