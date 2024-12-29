import 'dart:io';

import 'package:groq_sdk/groq_sdk.dart';
import 'package:test/test.dart';

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

dynamic Function(Map<String, dynamic>) toolFunctionMapper(String functionName) {
  if (functionName == 'get_weather') {
    return getWeather;
  }
  throw Exception('Unknown function: $functionName');
}

void main() {
  group('Groq Chat tests', () {
    final String apiKey = Platform.environment['GROQ_API_KEY'] ?? '';
    final groq = Groq(apiKey);
    final chat = groq.startNewChat('gemma2_9b');
    final weatherTool = GroqToolItem(
      functionName: 'get_weather',
      functionDescription: 'Get weather information for a specified location',
      parameters: [
        GroqToolParameter(
          parameterName: 'location',
          parameterDescription: 'City or location name',
          parameterType: GroqToolParameterType.string,
          isRequired: true,
        ),
        GroqToolParameter(
          parameterName: 'units',
          parameterDescription: 'Temperature units (metric or imperial)',
          parameterType: GroqToolParameterType.string,
          isRequired: false,
          allowedValues: ['metric', 'imperial'],
        ),
      ],
      function: getWeather,
    );

    test('Start new Chat with gemma2', () {
      expect(chat, isNotNull);
      expect(chat.model, 'gemma2_9b');
      expect(chat.settings, GroqChatSettings.defaults());
    });
    test('Start new Chat with custom settings', () {
      final customSettings = GroqChatSettings(
        maxTokens: 100,
        temperature: 0.5,
        topP: 0.9,
        maxConversationalMemoryLength: 1,
      );
      final chat =
          groq.startNewChat(GroqModels.gemma2_9b, settings: customSettings);
      expect(chat, isNotNull);
      expect(chat.model, GroqModels.gemma2_9b);
      expect(chat.settings, customSettings);
      expect(chat.latestResponse, isNull);
      expect(chat.totalTokens, 0);
      expect(chat.latestUsage, isNull);
      expect(chat.registeredTools, isEmpty);
    });
    test('Switch model', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      expect(chat, isNotNull);
      expect(chat.model, GroqModels.gemma2_9b);
      expect(chat.settings, GroqChatSettings.defaults());
      chat.switchModel(GroqModels.mixtral8_7b);
      expect(chat.model, GroqModels.mixtral8_7b);
    });

    test('Add message without sending', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      chat.addMessageWithoutSending('Hello');
      expect(chat.messages, isNotEmpty);
      expect(chat.messages.length, 1);
      expect(
          (chat.messages.first as RequestChatEvent).message.content, 'Hello');
      expect((chat.messages.first as RequestChatEvent).message.role,
          GroqMessageRole.assistant);
    });

    test('Send message', () async {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      await chat.sendMessage('Hello');
      chat.stream.listen((event) {
        if (event is RequestChatEvent) {
          expect(event.message.content, 'Hello');
        } else if (event is ResponseChatEvent) {
          expect(event.response.choices.first.message, isNotEmpty);
          expect(event.usage.totalTokens, isPositive);
          expect(event.response.choices.first.messageData.isToolCall, isFalse);
          expect(event.response.choices.first.messageData.role,
              GroqMessageRole.system);
        }
      });
      expect(chat.messages, isNotEmpty);
      expect(chat.messages.length, 2);
      expect(
          (chat.messages.first as RequestChatEvent).message.content, 'Hello');
      expect((chat.messages.first as RequestChatEvent).message.role,
          GroqMessageRole.user);
      expect(chat.messages.last, isA<ResponseChatEvent>());
      expect(
          (chat.messages.last as ResponseChatEvent)
              .response
              .choices
              .first
              .message,
          isNotEmpty);
      expect(chat.latestResponse, isNotNull);
      expect(chat.totalTokens, isPositive);
      expect(chat.latestUsage, isNotNull);
    });

    test('Register tool', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      chat.registerTool(weatherTool);
      expect(chat.registeredTools, isNotEmpty);
      expect(chat.registeredTools.length, 1);
      expect(chat.registeredTools.first.functionName, weatherTool.functionName);
      expect(chat.registeredTools.first.functionDescription,
          weatherTool.functionDescription);
      expect(chat.registeredTools.first.parameters, weatherTool.parameters);
    });

    test('Register same tool twice', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      chat.registerTool(weatherTool);
      expect(chat.registeredTools, isNotEmpty);
      expect(
          () => chat.registerTool(weatherTool), throwsA(isA<AssertionError>()));
    });

    test('Unregister tools', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      chat.registerTool(weatherTool);
      chat.unregisterTool(weatherTool.functionName);
      expect(chat.registeredTools, isEmpty);
    });

    test('Set tools', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      chat.registerTool(weatherTool);
      chat.setTools([weatherTool]);
      expect(chat.registeredTools, isNotEmpty);
      expect(chat.registeredTools.length, 1);
      expect(chat.registeredTools.first.functionName, weatherTool.functionName);
      expect(chat.registeredTools.first.functionDescription,
          weatherTool.functionDescription);
      expect(chat.registeredTools.first.parameters, weatherTool.parameters);
    });

    test('Get tool callable', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      chat.registerTool(weatherTool);
      final toolCallable = chat.getToolCallable(GroqToolCall(
          callId: '...',
          functionName: weatherTool.functionName,
          arguments: {'location': 'London'}));
      expect(toolCallable, isNotNull);
      expect(toolCallable, isA<Function>());
    });
    test('Get tool callable with invalid function_name', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      chat.registerTool(weatherTool);
      expect(
          () => chat.getToolCallable(GroqToolCall(
              callId: '...',
              functionName: 'unknown_function',
              arguments: {'location': 'London'})),
          throwsA(isA<Exception>().having(
              (e) => e.toString(), 'description', contains('Tool not found'))));
    });

    test('Tool call flow with weather', () async {
      final chat = groq.startNewChat(GroqModels.llama33_70b_versatile);
      chat.registerTool(weatherTool);
      chat.addMessageWithoutSending(
          'You are a weather assistant bot. Please say this in your first message');
      final (response, usage) = await chat.sendMessage(
        'What is the weather in Boston like (in metric and imperial units)?',
      );
      final message = response.choices.first.messageData;
      expect(message.isToolCall, isTrue);
      expect(message.toolCalls, isNotEmpty);
      expect(message.toolCalls.length, 2);
      for (final toolCall in message.toolCalls) {
        expect(toolCall.functionName, weatherTool.functionName);
        final retrieveWeatherInBoston = chat.getToolCallable(toolCall);
        final weatherResult = retrieveWeatherInBoston();
        expect(weatherResult, isNotNull);
        expect(weatherResult, isA<Map<String, dynamic>>());
        expect(weatherResult['units'], anyOf('metric', 'imperial'));
        if (weatherResult['units'] == 'metric') {
          expect(weatherResult['temperature'], 15);
        } else {
          expect(weatherResult['temperature'], 59);
        }
        expect(weatherResult['location'], 'Boston');
        expect(weatherResult['description'], 'Partly cloudy');
      }
    });
    test('toJson and fromJSON with no messages', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      final json = chat.toJson();
      expect(json, isNotNull);
      expect(json, isA<Map<String, dynamic>>());

      final newChat = GroqChat.fromJson(json, toolFunctionMapper);
      expect(newChat, isNotNull);
      expect(newChat.model, chat.model);
      expect(newChat.settings.maxTokens, chat.settings.maxTokens);
      expect(newChat.settings.temperature, chat.settings.temperature);
      expect(newChat.settings.topP, chat.settings.topP);
      expect(newChat.settings.maxConversationalMemoryLength,
          chat.settings.maxConversationalMemoryLength);
      expect(newChat.registeredTools, chat.registeredTools);
      expect(newChat.messages, chat.messages);
    });
    test('ToJson and fromJSON', () {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      chat.registerTool(weatherTool);
      chat.addMessageWithoutSending(
          'You are a weather assistant bot. Please say this in your first message');

      final json = chat.toJson();
      expect(json, isNotNull);
      expect(json, isA<Map<String, dynamic>>());

      final newChat = GroqChat.fromJson(json, toolFunctionMapper);
      expect(newChat, isNotNull);
      expect(newChat.model, chat.model);
      expect(newChat.settings.maxTokens, chat.settings.maxTokens);
      expect(newChat.settings.temperature, chat.settings.temperature);
      expect(newChat.settings.topP, chat.settings.topP);
      expect(newChat.settings.maxConversationalMemoryLength,
          chat.settings.maxConversationalMemoryLength);
      expect(newChat.registeredTools, chat.registeredTools);
      expect(newChat.messages, chat.messages);
    });
  });
}
