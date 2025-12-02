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

    test('Groq Tool Item with Array Parameter - JSON Schema with oneOf', () {
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
      final amenitiesSchema =
          json['function']['parameters']['properties']['amenities'];

      // Should have oneOf with two options
      expect(amenitiesSchema['oneOf'], isNotNull);
      expect(amenitiesSchema['oneOf'].length, 2);

      // First option: single string
      expect(amenitiesSchema['oneOf'][0]['type'], 'string');
      expect(amenitiesSchema['oneOf'][0]['enum'],
          ['pool', 'gym', 'parking', 'garden']);

      // Second option: array of strings
      expect(amenitiesSchema['oneOf'][1]['type'], 'array');
      expect(amenitiesSchema['oneOf'][1]['items']['type'], 'string');
      expect(amenitiesSchema['oneOf'][1]['items']['enum'],
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

      final callable = tool.validateAndGetCallable({
        'amenities': ['pool', 'gym']
      });
      final result = callable();

      expect(result['amenities'], ['pool', 'gym']);
    });

    test('Groq Tool Array Validation - Invalid Element Type Filtered', () {
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
        function: (args) => args,
      );

      // Invalid elements should be filtered out, keeping only valid ones
      final callable = tool.validateAndGetCallable({
        'counts': [1, 'invalid', 3]
      });
      final result = callable();

      expect(result['counts'], [1, 3]);
    });

    test('Groq Tool Array Validation - Invalid Allowed Value Filtered', () {
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
        function: (args) => args,
      );

      // Invalid values should be filtered out, keeping only valid ones
      final callable = tool.validateAndGetCallable({
        'amenities': ['pool', 'invalid']
      });
      final result = callable();

      expect(result['amenities'], ['pool']);
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

      expect(json['function']['parameters']['properties']['units']['default'],
          'celsius');
      expect(json['function']['parameters']['properties']['tags']['default'],
          ['default', 'test']);
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

    test('Groq Tool Required Parameter with Default - Applied When Missing',
        () {
      final tool = GroqToolItem(
        functionName: 'test_required_default',
        functionDescription: 'A tool with required param having default',
        parameters: [
          GroqToolParameter(
            parameterName: 'dealType',
            parameterDescription: 'Sale or rent',
            parameterType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['sale', 'rent'],
            defaultValue: 'sale',
          ),
        ],
        function: (args) => args,
      );

      // Should not throw error even though required param is missing
      final callable = tool.validateAndGetCallable({});
      final result = callable();

      expect(result['dealType'], 'sale');
    });

    test('Groq Tool Required Parameter with Default - Not in Schema Required',
        () {
      final tool = GroqToolItem(
        functionName: 'test_required_default_schema',
        functionDescription: 'A tool with required param having default',
        parameters: [
          GroqToolParameter(
            parameterName: 'location',
            parameterDescription: 'Location name',
            parameterType: GroqToolParameterType.string,
            isRequired: true,
          ),
          GroqToolParameter(
            parameterName: 'dealType',
            parameterDescription: 'Sale or rent',
            parameterType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['sale', 'rent'],
            defaultValue: 'sale',
          ),
        ],
        function: (args) => args,
      );

      final json = tool.toJson();

      // location should be in required (no default)
      // dealType should NOT be in required (has default)
      expect(json['function']['parameters']['required'], ['location']);
    });

    test('Groq Tool Required Parameter with Default - User Value Overrides',
        () {
      final tool = GroqToolItem(
        functionName: 'test_required_default',
        functionDescription: 'A tool with required param having default',
        parameters: [
          GroqToolParameter(
            parameterName: 'dealType',
            parameterDescription: 'Sale or rent',
            parameterType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['sale', 'rent'],
            defaultValue: 'sale',
          ),
        ],
        function: (args) => args,
      );

      final callable = tool.validateAndGetCallable({'dealType': 'rent'});
      final result = callable();

      expect(result['dealType'], 'rent'); // User-provided value used
    });

    test('Groq Tool Required Parameter without Default - Throws Error', () {
      final tool = GroqToolItem(
        functionName: 'test_required_no_default',
        functionDescription: 'A tool with required param without default',
        parameters: [
          GroqToolParameter(
            parameterName: 'location',
            parameterDescription: 'Location name',
            parameterType: GroqToolParameterType.string,
            isRequired: true,
          ),
        ],
        function: (args) => args,
      );

      // Should throw error because required param is missing and has no default
      expect(
        () => tool.validateAndGetCallable({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Groq Tool Required Array Parameter with Default', () {
      final tool = GroqToolItem(
        functionName: 'test_required_array_default',
        functionDescription: 'A tool with required array param having default',
        parameters: [
          GroqToolParameter(
            parameterName: 'propertyTypes',
            parameterDescription: 'Property types',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['apartment', 'house', 'villa'],
            defaultValue: ['apartment', 'house'],
          ),
        ],
        function: (args) => args,
      );

      final callable = tool.validateAndGetCallable({});
      final result = callable();

      expect(result['propertyTypes'], ['apartment', 'house']);
    });

    test('Groq Tool Array Auto-Wrap - Single String Value', () {
      final tool = GroqToolItem(
        functionName: 'test_array_autowrap',
        functionDescription: 'A tool that auto-wraps non-array values',
        parameters: [
          GroqToolParameter(
            parameterName: 'tags',
            parameterDescription: 'Tags',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['tag1', 'tag2', 'tag3'],
          ),
        ],
        function: (args) => args,
      );

      // Provide a single string instead of an array
      final callable = tool.validateAndGetCallable({'tags': 'tag1'});
      final result = callable();

      expect(result['tags'], ['tag1']); // Should be auto-wrapped
    });

    test('Groq Tool Array Auto-Wrap - Single Number Value', () {
      final tool = GroqToolItem(
        functionName: 'test_array_autowrap_number',
        functionDescription: 'A tool that auto-wraps non-array values',
        parameters: [
          GroqToolParameter(
            parameterName: 'scores',
            parameterDescription: 'Scores',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.number,
            isRequired: true,
          ),
        ],
        function: (args) => args,
      );

      // Provide a single number instead of an array
      final callable = tool.validateAndGetCallable({'scores': 42});
      final result = callable();

      expect(result['scores'], [42]); // Should be auto-wrapped
    });

    test('Groq Tool Array Auto-Wrap - Already Array', () {
      final tool = GroqToolItem(
        functionName: 'test_array_no_wrap',
        functionDescription: 'A tool that checks arrays are not double-wrapped',
        parameters: [
          GroqToolParameter(
            parameterName: 'tags',
            parameterDescription: 'Tags',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['tag1', 'tag2', 'tag3'],
          ),
        ],
        function: (args) => args,
      );

      // Provide an array - should not be wrapped
      final callable = tool.validateAndGetCallable({
        'tags': ['tag1', 'tag2']
      });
      final result = callable();

      expect(result['tags'], ['tag1', 'tag2']); // Should remain as is
    });

    test('Groq Tool Array Auto-Wrap - Validates After Wrapping', () {
      final tool = GroqToolItem(
        functionName: 'test_array_autowrap_validate',
        functionDescription: 'A tool that validates after auto-wrapping',
        parameters: [
          GroqToolParameter(
            parameterName: 'tags',
            parameterDescription: 'Tags',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['tag1', 'tag2', 'tag3'],
          ),
        ],
        function: (args) => args,
      );

      // Provide invalid value - should fail validation even after wrapping
      expect(
        () => tool.validateAndGetCallable({'tags': 'invalid_tag'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Groq Tool Array Filter - Removes Invalid Elements', () {
      final tool = GroqToolItem(
        functionName: 'test_array_filter',
        functionDescription: 'A tool that filters invalid array elements',
        parameters: [
          GroqToolParameter(
            parameterName: 'tags',
            parameterDescription: 'Tags',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['tag1', 'tag2', 'tag3'],
          ),
        ],
        function: (args) => args,
      );

      // Mix of valid and invalid values
      final callable = tool.validateAndGetCallable({
        'tags': ['tag1', 'invalid', 'tag2', 'bad']
      });
      final result = callable();

      // Should keep only valid values
      expect(result['tags'], ['tag1', 'tag2']);
    });

    test('Groq Tool Array Filter - Uses Default When All Invalid', () {
      final tool = GroqToolItem(
        functionName: 'test_array_filter_default',
        functionDescription:
            'A tool that uses default when all elements filtered',
        parameters: [
          GroqToolParameter(
            parameterName: 'tags',
            parameterDescription: 'Tags',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['tag1', 'tag2', 'tag3'],
            defaultValue: ['tag1'],
          ),
        ],
        function: (args) => args,
      );

      // All invalid values
      final callable = tool.validateAndGetCallable({
        'tags': ['invalid1', 'invalid2']
      });
      final result = callable();

      // Should use default
      expect(result['tags'], ['tag1']);
    });

    test('Groq Tool Array Filter - Throws Error When Required With No Default',
        () {
      final tool = GroqToolItem(
        functionName: 'test_array_filter_error',
        functionDescription:
            'A tool that throws error when filtered array is empty',
        parameters: [
          GroqToolParameter(
            parameterName: 'tags',
            parameterDescription: 'Tags',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: true,
            allowedValues: ['tag1', 'tag2', 'tag3'],
          ),
        ],
        function: (args) => args,
      );

      // All invalid values, no default, required
      expect(
        () => tool.validateAndGetCallable({
          'tags': ['invalid1', 'invalid2']
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Groq Tool Array Filter - Removes Optional Param When Empty', () {
      final tool = GroqToolItem(
        functionName: 'test_array_filter_optional',
        functionDescription:
            'A tool that removes optional param when filtered empty',
        parameters: [
          GroqToolParameter(
            parameterName: 'tags',
            parameterDescription: 'Tags',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.string,
            isRequired: false,
            allowedValues: ['tag1', 'tag2', 'tag3'],
          ),
        ],
        function: (args) => args,
      );

      // All invalid values, optional, no default
      final callable = tool.validateAndGetCallable({
        'tags': ['invalid1', 'invalid2']
      });
      final result = callable();

      // Should not contain the parameter
      expect(result.containsKey('tags'), false);
    });

    test('Groq Tool Array Filter - Filters Wrong Type Elements', () {
      final tool = GroqToolItem(
        functionName: 'test_array_filter_type',
        functionDescription: 'A tool that filters wrong type elements',
        parameters: [
          GroqToolParameter(
            parameterName: 'scores',
            parameterDescription: 'Scores',
            parameterType: GroqToolParameterType.array,
            itemType: GroqToolParameterType.number,
            isRequired: true,
          ),
        ],
        function: (args) => args,
      );

      // Mix of numbers and strings
      final callable = tool.validateAndGetCallable({
        'scores': [10, 'invalid', 20, 'bad', 30]
      });
      final result = callable();

      // Should keep only numbers
      expect(result['scores'], [10, 20, 30]);
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
