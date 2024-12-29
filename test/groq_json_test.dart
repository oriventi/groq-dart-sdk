import 'package:groq_sdk/extensions/groq_json_extensions.dart';
import 'package:groq_sdk/groq_sdk.dart';
import 'package:groq_sdk/utils/groq_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Groq Json Tests', () {
    Map<String, dynamic> getWeather(Map<String, dynamic> args) {
      final location = args['location'] as String;
      final units = args['units'] as String? ?? 'metric';
      return {
        'location': location,
        'units': units,
        'temperature': units == 'metric' ? 15 : 59,
        'description': 'Partly cloudy',
      };
    }

    test('Groq Chat Settings', () {
      final chatSettings = GroqChatSettings(
        temperature: 0.5,
        maxTokens: 100,
        topP: 0.9,
        stop: '\n',
      );

      final json = chatSettings.toJson();
      final newChatSettings = GroqParser.settignsFromJson(json);
      expect(chatSettings, newChatSettings);
    });

    test('Groq Tool Parameter Type', () {
      final type = GroqToolParameterType.string;

      final json = type.toJson();
      final newType = GroqParser.groqToolParameterTypeFromString(json);

      expect(type, newType);
    });
    test('Request Chat Event', () {
      final ChatEvent event = RequestChatEvent(GroqMessage(
          content: 'Hello', isToolCall: false, role: GroqMessageRole.user));

      final json = event.toJson();

      final newEvent = GroqParser.chatEventFromJson(json);

      expect(event, newEvent);
    });

    test('Response Chat Event', () {
      var createdAt = DateTime(2021, 1, 1, 0, 0, 0, 0);
      final int createdAtMillis = createdAt.millisecondsSinceEpoch;
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtMillis).toUtc();
      final ChatEvent event = ResponseChatEvent(
          GroqResponse(
            id: '...',
            choices: [
              GroqChoice(
                  messageData: GroqMessage(
                    content: 'Hello',
                    role: GroqMessageRole.user,
                    isToolCall: false,
                  ),
                  finishReason: 'finished'),
            ],
            createdAt: createdAt,
          ),
          GroqUsage(
            completionTime: Duration(seconds: 1),
            completionTokens: 100,
            promptTime: const Duration(seconds: 1),
            promptTokens: 100,
          ));

      final json = event.toJson();

      final newEvent = GroqParser.chatEventFromJson(json);
      final newResEvent = newEvent as ResponseChatEvent;

      final resEvent = event as ResponseChatEvent;

      expect(resEvent.response.choices, newResEvent.response.choices);
      expect(resEvent.response.id, newResEvent.response.id);
      expect(resEvent.usage, newResEvent.usage);
    });
    test('GroqUsage', () {
      final usage = GroqUsage(
        completionTime: Duration(seconds: 1),
        completionTokens: 100,
        promptTime: const Duration(seconds: 1),
        promptTokens: 100,
      );

      final json = usage.toJson();
      final newUsage = GroqParser.usagefromJson(json);

      expect(usage, newUsage);
    });

    test('GroqChoice', () {
      final choice = GroqChoice(
        messageData: GroqMessage(
          content: 'Hello',
          role: GroqMessageRole.user,
          isToolCall: false,
        ),
        finishReason: 'finished',
      );

      final json = choice.toJson();
      final newChoice = GroqParser.groqChoiceFromJson(json);

      expect(choice, newChoice);
    });

    test('GroqRateLimitInformation', () {
      final rateLimit = GroqRateLimitInformation(
        totalRequestsPerDay: 1000,
        remainingRequestsToday: 100,
        totalTokensPerMinute: 1000,
        remainingTokensThisMinute: 100,
      );

      final json = rateLimit.toJson();
      final newRateLimit = GroqParser.rateLimitInformationFromJson(json);

      expect(rateLimit, newRateLimit);
    });

    test('GroqToolCall', () {
      final toolCall = GroqToolCall(
        callId: '...',
        functionName: '...',
        arguments: {'key': 'value'},
      );

      final json = toolCall.toJson();
      final newToolCall = GroqParser.groqToolCallFromJson(json);

      expect(toolCall, newToolCall);
    });

    test('GroqMessage', () {
      final message = GroqMessage(
        content: 'Hello',
        role: GroqMessageRole.user,
        isToolCall: false,
      );

      final json = message.toJson();
      final newMessage = GroqParser.groqMessageFromJson(json);

      expect(message, newMessage);
    });
  });
}
