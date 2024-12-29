import 'package:groq_sdk/models/groq_message.dart';

class GroqChoice {
  ///The message of the choice \
  ///It contains the message and metadata, like role \
  ///Example:
  ///```dart
  ///final choice = response.choices.first;
  ///print(choice.message); //prints the message of the choice
  ///```
  final GroqMessage messageData;

  ///The reason why the conversation ended \
  ///It can be `finished` or `aborted` \
  ///Example:
  ///```dart
  ///final choice = response.choices.first;
  ///print(choice.finishReason); //prints the reason why the conversation ended
  ///```
  final String? finishReason;

  ///Creates a GroqChoice with the given messageData and finishReason \
  ///The messageData is the message of the choice \
  ///The finishReason is the reason why the conversation ended \
  GroqChoice({
    required this.messageData,
    required this.finishReason,
  });

  ///Returns the message of the choice \
  ///It is the content of the messageData \
  ///Example:
  ///```dart
  ///final choice = response.choices.first;
  ///print(choice.message); //prints the message of the choice
  ///```
  String get message => messageData.content;

  @override
  int get hashCode => messageData.hashCode ^ finishReason.hashCode;

  @override
  bool operator ==(Object other) =>
      other is GroqChoice &&
      other.messageData == messageData &&
      other.finishReason == finishReason;

  @override
  String toString() {
    return 'GroqChoice{messageData: $messageData, finishReason: $finishReason}';
  }
}

class GroqResponse {
  ///The identifier of the response \
  ///It is given by the Groq API \
  final String id;

  ///The possible responses to the prompt \
  ///Each choice contains a `message` and a `finish reason` \
  ///The choices are set in the `GroqChatSettings` of your current groqChat \
  final List<GroqChoice> choices;
  final DateTime createdAt;

  ///Creates a GroqResponse with the given id, choices and createdAt \
  ///The id is the identifier of the response \
  ///The choices are the possible responses to the prompt \
  ///The createdAt is the date and time when the response was created \
  GroqResponse({
    required this.id,
    required this.choices,
    required this.createdAt,
  });

  @override
  int get hashCode => id.hashCode ^ choices.hashCode ^ createdAt.hashCode;

  @override
  bool operator ==(Object other) =>
      other is GroqResponse &&
      other.id == id &&
      other.choices == choices &&
      other.createdAt.millisecond == createdAt.millisecond;

  @override
  String toString() {
    return 'GroqResponse{id: $id, choices: $choices, createdAt: $createdAt}';
  }
}
