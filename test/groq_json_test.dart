import 'package:groq_sdk/extensions/groq_json_extensions.dart';
import 'package:groq_sdk/groq_sdk.dart';
import 'package:groq_sdk/utils/groq_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Groq Json Tests', () {
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

    test('Groq Tool Parameter Type - Array', () {
      final type = GroqToolParameterType.array;

      final json = type.toJson();
      final newType = GroqParser.groqToolParameterTypeFromString(json);

      expect(type, newType);
      expect(json, 'array');
    });

    test('Groq Tool Item with Array Parameter - JSON Schema', () {
      final tool = GroqToolItem(
        functionName: 'test_array_tool',
        functionDescription: 'A tool with array parameter',
        parameters: [
          GroqToolParameter(
            parameterName: 'amenities',
            parameterDescription: 'List of required amenities',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['pool', 'gym', 'parking', 'garden'],
          ),
        ],
        function: (args) => {'result': 'success'},
      );

      final json = tool.toJson();

      expect(json['function']['parameters']['properties']['amenities']['type'], 'array');
      expect(json['function']['parameters']['properties']['amenities']['items']['type'], 'string');
      expect(json['function']['parameters']['properties']['amenities']['items']['enum'],
             ['pool', 'gym', 'parking', 'garden']);
      expect(json['function']['parameters']['required'], ['amenities']);
    });

    test('Groq Tool Array Validation - Valid', () {
      final tool = GroqToolItem(
        functionName: 'test_array_tool',
        functionDescription: 'A tool with array parameter',
        parameters: [
          GroqToolParameter(
            parameterName: 'amenities',
            parameterDescription: 'List of required amenities',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['pool', 'gym', 'parking', 'garden'],
          ),
        ],
        function: (args) => {'amenities': args['amenities']},
      );

      final callable = tool.validateAndGetCallable({'amenities': ['pool', 'gym']});
      final result = callable();

      expect(result['amenities'], ['pool', 'gym']);
    });

    test('Groq Tool Array Validation - Invalid Element Type', () {
      final tool = GroqToolItem(
        functionName: 'test_array_tool',
        functionDescription: 'A tool with array parameter',
        parameters: [
          GroqToolParameter(
            parameterName: 'counts',
            parameterDescription: 'List of counts',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.number,
            isRequired: true,
          ),
        ],
        function: (args) => {'result': 'success'},
      );

      expect(
        () => tool.validateAndGetCallable({'counts': [1, 'invalid', 3]}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Groq Tool Array Validation - Invalid Allowed Value', () {
      final tool = GroqToolItem(
        functionName: 'test_array_tool',
        functionDescription: 'A tool with array parameter',
        parameters: [
          GroqToolParameter(
            parameterName: 'amenities',
            parameterDescription: 'List of required amenities',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['pool', 'gym', 'parking'],
          ),
        ],
        function: (args) => {'result': 'success'},
      );

      expect(
        () => tool.validateAndGetCallable({'amenities': ['pool', 'invalid']}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Groq Tool Default Value - JSON Schema', () {
      final tool = GroqToolItem(
        functionName: 'test_default_tool',
        functionDescription: 'A tool with default values',
        parameters: [
          GroqToolParameter(
            parameterName: 'units',
            parameterDescription: 'Temperature units',
            parameterType: GroqToolParameterType.string,
            isRequired: false,
            allowedValues: ['celsius', 'fahrenheit'],
            defaultValue: 'celsius',
          ),
          GroqToolParameter(
            parameterName: 'tags',
            parameterDescription: 'Default tags',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: false,
            defaultValue: ['default', 'test'],
          ),
        ],
        function: (args) => args,
      );

      final json = tool.toJson();

      expect(json['function']['parameters']['properties']['units']['default'], 'celsius');
      expect(json['function']['parameters']['properties']['tags']['default'], ['default', 'test']);
    });

    test('Groq Tool Default Value - Applied When Missing', () {
      final tool = GroqToolItem(
        functionName: 'test_default_tool',
        functionDescription: 'A tool with default values',
        parameters: [
          GroqToolParameter(
            parameterName: 'location',
            parameterDescription: 'Location name',
            parameterType: GroqToolParameterType.string,
            isRequired: true,
          ),
          GroqToolParameter(
            parameterName: 'units',
            parameterDescription: 'Temperature units',
            parameterType: GroqToolParameterType.string,
            isRequired: false,
            defaultValue: 'celsius',
          ),
        ],
        function: (args) => args,
      );

      final callable = tool.validateAndGetCallable({'location': 'London'});
      final result = callable();

      expect(result['location'], 'London');
      expect(result['units'], 'celsius'); // Default applied
    });

    test('Groq Tool Default Value - Not Applied When Provided', () {
      final tool = GroqToolItem(
        functionName: 'test_default_tool',
        functionDescription: 'A tool with default values',
        parameters: [
          GroqToolParameter(
            parameterName: 'units',
            parameterDescription: 'Temperature units',
            parameterType: GroqToolParameterType.string,
            isRequired: false,
            defaultValue: 'celsius',
          ),
        ],
        function: (args) => args,
      );

      final callable = tool.validateAndGetCallable({'units': 'fahrenheit'});
      final result = callable();

      expect(result['units'], 'fahrenheit'); // Provided value used
    });

    test('Groq Tool Default Value - Array Default', () {
      final tool = GroqToolItem(
        functionName: 'test_array_default',
        functionDescription: 'A tool with array default',
        parameters: [
          GroqToolParameter(
            parameterName: 'propertyTypes',
            parameterDescription: 'Property types',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: false,
            allowedValues: ['apartment', 'house', 'villa'],
            defaultValue: ['apartment', 'house', 'villa'],
          ),
        ],
        function: (args) => args,
      );

      final callable = tool.validateAndGetCallable({});
      final result = callable();

      expect(result['propertyTypes'], ['apartment', 'house', 'villa']);
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
