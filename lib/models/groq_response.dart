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

  factory GroqChoice.fromJson(Map<String, dynamic> json) {
    return GroqChoice(
      messageData: GroqMessage.fromJson(json["message"]),
      finishReason: json['finish_reason'] as String?,
    );
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

  factory GroqResponse.fromJson(Map<String, dynamic> json) {
    return GroqResponse(
      id: json['id'] as String,
      choices: (json['choices'] as List)
          .map(
            (item) => GroqChoice.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created'] as int,
          isUtc: true),
    );
  }
}
