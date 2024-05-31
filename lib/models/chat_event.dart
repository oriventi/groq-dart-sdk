import 'package:groq_sdk/models/groq_message.dart';
import 'package:groq_sdk/models/groq_response.dart';
import 'package:groq_sdk/models/groq_usage.dart';

///Is the type received by the chat stream \
///It can be a request or a response \
///The request just contains the message \
///The response contains the message and the resource usage \
///Example:
///```dart
///chat.stream.listen((event) {
///   if (event is RequestChatEvent) {
///     print(event.message.message);
///   } else if (event is ResponseChatEvent) {
///     print(event.response.choices.first.message);
///     print(event.usage.totalTokens);
///   }
sealed class ChatEvent {
  const ChatEvent();

  T when<T>({
    required T Function(RequestChatEvent) request,
    required T Function(ResponseChatEvent) response,
  });
}

///Is the type received by the chat stream \
///It contains the message to be sent to the chat \
///Example:
///```dart
///chat.stream.listen((event) {
///   if (event is RequestChatEvent) {
///     print(event.message.message);
///   }
///}
/// ```
class RequestChatEvent extends ChatEvent {
  final GroqMessage message;
  RequestChatEvent(this.message);

  @override
  T when<T>({
    required T Function(RequestChatEvent) request,
    required T Function(ResponseChatEvent) response,
  }) {
    return request(this);
  }
}

///Is the type received by the chat stream \
///It contains the response from the chat and the resource usage  \
///Example:
///```dart
///chat.stream.listen((event) {
///   if (event is ResponseChatEvent) {
///     print(event.response.choices.first.message);
///     print(event.usage.totalTokens);
///   }
///}
///```
class ResponseChatEvent extends ChatEvent {
  final GroqResponse response;
  final GroqUsage usage;
  ResponseChatEvent(this.response, this.usage);

  @override
  T when<T>({
    required T Function(RequestChatEvent) request,
    required T Function(ResponseChatEvent) response,
  }) {
    return response(this);
  }
}
