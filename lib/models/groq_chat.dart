// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:groq_sdk/extensions/groq_json_extensions.dart';
import 'package:groq_sdk/models/chat_event.dart';
import 'package:groq_sdk/models/groq_api.dart';
import 'package:groq_sdk/models/groq_conversation_item.dart';
import 'package:groq_sdk/models/groq_message.dart';
import 'package:groq_sdk/models/groq_rate_limit_information.dart';
import 'package:groq_sdk/models/groq_response.dart';
import 'package:groq_sdk/models/groq_tool_use_item.dart';
import 'package:groq_sdk/models/groq_usage.dart';
import 'package:groq_sdk/utils/groq_parser.dart';

class GroqChatSettings {
  ///Conversational memory length. \
  ///The number of previous messages to include in the model's context. \
  ///A higher value will result in more context-aware responses. \
  ///Example:
  ///```dart
  /////1 means the last request and response are included
  ///final settings = GroqChatSettings.defaults().copyWith(maxConversationalMemoryLength: 1);
  ///```
  ///Default: `1024`
  final int maxConversationalMemoryLength;

  ///Controls `randomness` of responses. \
  ///A lower temperature leads to more predictable outputs while a higher temperature results
  ///in more varies and sometimes more creative outputs.
  ///Default: `1.0`
  final double temperature;

  ///The maximum number of tokens that can be generated in the chat completion. \
  ///The total length of input tokens and generated tokens is limited by the model's context length.
  ///Default: `8192`
  final int maxTokens;

  ///A method of text generation where a model will only consider the most probable
  ///next tokens that make up the probability p. 0.5 means half of all
  ///likelihood-weighted options are considered.
  ///Default: `1.0`
  final double topP;

  ///A stop sequence is a predefined or user-specified text string that signals an AI to stop generating content, \
  ///ensuring its responses remain focused and concise.
  ///Default: `null`
  final String? stop;

  ///GroqChatSettings constructor
  ///[temperature] controls randomness of responses. \
  ///[maxTokens] maximum number of tokens that can be generated in the chat completion. \
  ///[topP] method of text generation where a model will only consider the most probable next tokens that make up the probability p. \
  ///[stream] user server-side events to send the completion in small deltas rather than in a single batch after all processing has finished. \
  ///[choicesCount] how many chat completion choices to generate for each input message. \
  ///[stop] a stop sequence is a predefined or user-specified text string that signals an AI to stop generating content. \
  ///[maxConversationalMemoryLength] conversational memory length. The number of previous messages to include in the model's context. A higher value will result in more context-aware responses. Default: 1024 \
  ///Throws an assertion error if the temperature is not between 0.0 and 2.0, maxTokens is less than or equal to 0, topP is not between 0.0 and 1.0, or choicesCount is less than or equal to 0.
  ///Default values: temperature: 1.0, maxTokens: 8192, topP: 1.0, stream: false, choicesCount: 1, stop: null, maxConversationalMemoryLength: 1024
  GroqChatSettings({
    this.temperature = 1.0,
    this.maxTokens = 8192,
    this.topP = 1.0,
    this.stop,
    this.maxConversationalMemoryLength = 1024,
  }) {
    assert(temperature >= 0.0 && temperature <= 2.0,
        'Temperature must be between 0.0 and 2.0');
    assert(maxTokens > 0, 'Max tokens must be greater than 0');
    assert(topP >= 0.0 && topP <= 1.0, 'Top P must be between 0.0 and 1.0');
    assert(maxConversationalMemoryLength > 0,
        'Max conversational memory length must be greater than 0');
    // assert(choicesCount > 0, 'Choices count must be greater than 0');
  }

  ///Default GroqChatSettings constructor
  ///Default values: temperature: 1.0, maxTokens: 8192, topP: 1.0, stream: false, choicesCount: 1, stop: null, maxConversationalMemoryLength: 1024
  ///Returns a GroqChatSettings object with default values
  const GroqChatSettings.defaults()
      : temperature = 1,
        maxTokens = 8192,
        topP = 1.0,
        stop = null,
        maxConversationalMemoryLength = 1024;

  ///Returns a copy of the current GroqChatSettings object with the new values
  ///[temperature] controls randomness of responses. \
  ///[maxTokens] maximum number of tokens that can be generated in the chat completion. \
  ///[topP] method of text generation where a model will only consider the most probable next tokens that make up the probability p. \
  ///[stream] user server-side events to send the completion in small deltas rather than in a single batch after all processing has finished. \
  ///[choicesCount] how many chat completion choices to generate for each input message. \
  ///[stop] a stop sequence is a predefined or user-specified text string that signals an AI to stop generating content.
  ///[maxConversationalMemoryLength] conversational memory length. The number of previous messages to include in the model's context. A higher value will result in more context-aware responses.
  ///Example:
  ///```dart
  ///final newSettings = settings.copyWith(temperature: 0.5);
  ///```
  GroqChatSettings copyWith({
    double? temperature,
    int? maxTokens,
    double? topP,
    bool? stream,
    String? stop,
    int? choicesCount,
    int? maxConversationalMemoryLength,
  }) {
    return GroqChatSettings(
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      stop: stop ?? this.stop,
      maxConversationalMemoryLength:
          maxConversationalMemoryLength ?? this.maxConversationalMemoryLength,
    );
  }

  @override
  int get hashCode =>
      temperature.hashCode ^
      maxTokens.hashCode ^
      topP.hashCode ^
      stop.hashCode ^
      maxConversationalMemoryLength.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroqChatSettings &&
        other.temperature == temperature &&
        other.maxTokens == maxTokens &&
        other.topP == topP &&
        other.stop == stop &&
        other.maxConversationalMemoryLength == maxConversationalMemoryLength;
  }
}

class GroqChat {
  late String _model;
  late String _apiKey;
  late String _baseUrl;

  @Deprecated("GroqConversationItem is deprecated, use GroqChatItem instead")
  final List<GroqConversationItem> _conversationItems = [];
  List<ChatEvent> _chatItems = [];
  late GroqChatSettings _settings;
  GroqRateLimitInformation? _rateLimitInfo;
  final StreamController<ChatEvent> _streamController =
      StreamController.broadcast();
  List<GroqToolItem> _registeredTools = [];

  ///GroqChat constructor
  ///[model] the model id
  ///[apiKey] the api key
  ///[settings] the chat settings
  ///[baseUrl] the base URL for the Groq API (optional, defaults to 'https://api.groq.com/openai/v1')
  GroqChat(this._model, this._apiKey, this._settings, [String? baseUrl]) {
    _baseUrl = baseUrl ?? GroqApi.defaultBaseUrl;
  }

  ///Closes the stream
  void dispose() {
    _streamController.close();
  }

  ///Returns the model id
  String get model => _model;

  ///Returns the current chat settings
  GroqChatSettings get settings => _settings;

  ///Returns the chat as a stream
  ///Example:
  ///```dart
  ///chat.stream.listen((event) {
  ///   if (event is RequestChatEvent) {
  ///     print(event.request.message.message);
  ///   } else if (event is ResponseChatEvent) {
  ///     print(event.response.choices.first.message);
  ///     print(event.usage.totalTokens);
  ///  }
  ///});
  ///```
  Stream<ChatEvent> get stream => _streamController.stream;

  ///Returns the rate limit information
  ///```dart
  ///final rateLimitInfo = chat.rateLimitInfo;
  ///print(rateLimitInfo.remainingTokens); //prints the remaining tokens for this day
  ///```
  ///Returns null if the rate limit information is not available
  GroqRateLimitInformation? get rateLimitInfo => _rateLimitInfo;

  ///Switches the model of the current conversation dynamically
  ///[modelId] the new model id
  ///It is also possible to switch the model during the conversation
  ///Example:
  ///```dart
  ///chat.switchModel(GroqModels.llama3-8b); //use a model id, provided by Groq
  ///```
  void switchModel(String modelId) => _model = modelId;

  ///Switches the settings of the current conversation dynamically
  ///[settings] the new chat settings
  ///It is also possible to switch the settings during the conversation
  ///Example:
  ///```dart
  ///chat.switchSettings(GroqChatSettings.defaults());
  ///```
  void switchSettings(GroqChatSettings settings) => _settings = settings;

  // returns a list of all messages in the conversation
  // it is a list of GroqMessage objects and switches from request to response

  @Deprecated("allMessages is deprecated, use messages instead")

  ///Returns a list of all messages in the conversation
  ///It is a list of GroqConversationItem objects and switches from request to response
  ///Example:
  ///```dart
  ///final conversation = chat.allMessages;
  ///print(conversation.first.request.message); //prints the first message in the conversation
  ///print(conversation.first.response.choices.first.message); //prints the first response in the conversation
  ///```
  List<GroqConversationItem> get allMessages => _conversationItems;

  ///Returns a list of all messages in the conversation
  ///It is a list of ChatEvents, which can either be requests or responses
  List<ChatEvent> get messages => _chatItems;

  @Deprecated("Use userMessageContents instead")

  ///Returns a list of all messages content in the conversation
  ///It is a list of strings and switches from request to response
  ///Example:
  ///```dart
  ///final conversation = chat.allMessagesContent;
  ///print(conversation.first); //prints the first message in the conversation
  ///print(conversation[1]); //prints the first response in the conversation
  ///```
  List<String> get allMessagesContent {
    List<String> messages = [];
    for (final item in _conversationItems) {
      messages.add(item.request.content);
      if (item.response != null) {
        messages.add(item.response!.choices.first.message);
      }
    }
    return messages;
  }

  ///Returns a List of Strings of all messages between the user and the model
  ///Assistant messages and tool use messages are not included
  ///Example:
  ///```dart
  ///final messages = chat.userMessageContent;
  ///print(messages.first); //prints the first user message in the conversation
  ///```
  List<String> get userMessageContents {
    List<String> messages = [];
    for (final item in _chatItems) {
      if (item is RequestChatEvent) {
        if (item.message.role == GroqMessageRole.user) {
          messages.add(item.message.content);
        }
      } else if (item is ResponseChatEvent) {
        if (item.response.choices.isNotEmpty &&
            !item.response.choices.first.messageData.isToolCall) {
          messages.add(item.response.choices.first.message);
        }
      }
    }
    return messages;
  }

  ///Registers a tool to the chat, which always can be called by the model.
  ///[tool] the tool to register
  ///Example:
  ///```dart
  /// final weatherTool = GroqToolItem(
  ///   functionName: 'get_weather',
  ///   functionDescription: 'Get weather information for a specified location',
  ///   parameters: [
  ///     GroqToolParameter(
  ///       parameterName: 'location',
  ///       parameterDescription: 'City or location name',
  ///       parameterType: GroqToolParameterType.string,
  ///       isRequired: true,
  ///     ),
  ///     GroqToolParameter(
  ///       parameterName: 'units',
  ///       parameterDescription: 'Temperature units (metric or imperial)',
  ///       parameterType: GroqToolParameterType.string,
  ///       isRequired: false,
  ///       allowedValues: ['metric', 'imperial'],
  ///     ),
  ///   ],
  ///   function: (args) {
  ///     final location = args['location'] as String;
  ///     final units = args['units'] as String? ?? 'metric';
  ///     return {
  ///       'location': location,
  ///       'temperature': units == 'metric' ? 22 : 71.6,
  ///       'units': units,
  ///     };
  ///   },
  /// );
  /// chat.registerTool(weatherTool);
  ///```
  void registerTool(GroqToolItem tool) {
    //assert that the tool is not already registered
    assert(
        !_registeredTools
            .any((element) => element.functionName == tool.functionName),
        'Tool with the name ${tool.functionName} is already registered');
    _registeredTools.add(tool);
  }

  ///Unregisters a tool from the chat
  ///[toolName] the name of the tool to unregister
  ///Example:
  ///```dart
  ///chat.unregisterTool('toolName');
  ///```
  void unregisterTool(String toolName) {
    _registeredTools.removeWhere((element) => element.functionName == toolName);
  }

  ///Registers multiple tools to the chat
  ///[tools] the tools to register
  void registerTools(List<GroqToolItem> tools) {
    _registeredTools.addAll(tools);
  }

  ///Clears all registered tools from the chat and registers the new tools
  ///Example:
  ///```dart
  ///chat.setTools([tool1, tool2]);
  ///```
  void setTools(List<GroqToolItem> tools) {
    _registeredTools.clear();
    _registeredTools.addAll(tools);
  }

  /// Validates and returns the registered tool function with the given arguments.
  ///[toolCall] the tool call usually returned from the GroqMessage object.
  ///returns the `callable function`, if the tool is registered.
  ///Throws an exception if the tool is not found.
  Function getToolCallable(GroqToolCall toolCall) {
    GroqToolItem? tool;
    try {
      tool = _registeredTools.firstWhere((element) {
        print('element.functionName: ${element.functionName}');
        print('toolCall.functionName: ${toolCall.functionName}');
        return element.functionName == toolCall.functionName;
      });
    } catch (e) {
      throw Exception('Tool not found');
    }
    final response = tool.validateAndGetCallable(toolCall.arguments);
    return response;
  }

  ///Returns the registered tools in the chat
  ///Example:
  ///```dart
  ///final tools = chat.registeredTools;
  ///print(tools.first.functionName); //prints the first tool name
  ///```
  ///Returns an empty list if no tools are registered
  List<GroqToolItem> get registeredTools => _registeredTools;

  ///Returns the latest response in the conversation
  ///```dart
  ///final response = chat.latestResponse;
  ///print(response.choices.first.message); //prints the latest response in the conversation
  ///```
  GroqResponse? get latestResponse =>
      _chatItems.whereType<ResponseChatEvent>().lastOrNull?.response;

  ///Returns the latest resource usage in the conversation
  ///```dart
  ///final usage = chat.latestUsage;
  ///print(usage.totalTokens); //prints the total tokens used in the latest response
  ///```
  GroqUsage? get latestUsage =>
      _chatItems.whereType<ResponseChatEvent>().lastOrNull?.usage;

  ///Returns the total tokens used in the conversation
  ///```dart
  ///final totalTokens = chat.totalTokens;
  ///print(totalTokens); //prints the total tokens used in the conversation
  ///```
  int get totalTokens {
    if (_chatItems.isEmpty) return 0;
    return _chatItems.fold(0, (previousValue, element) {
      if (element is RequestChatEvent) {
        return previousValue;
      }

      return previousValue + ((element as ResponseChatEvent).usage.totalTokens);
    });
  }

  ///Adds a new message to the chat without sending it to the model or expecting a response.
  ///This is useful for assistant messages or passive instructions to the model.
  ///[prompt] the message content
  ///[role] the message role, usually assistant
  ///Example:
  ///```dart
  ///chat.addMessageWithoutSending('You are a chatbot for a software support service.', role: GroqMessageRole.assistant);
  ///```
  void addMessageWithoutSending(
    String prompt, {
    GroqMessageRole role = GroqMessageRole.assistant,
  }) {
    final request = GroqMessage(content: prompt, role: role);
    _chatItems.add(RequestChatEvent(request));
    _conversationItems.add(GroqConversationItem(_model, request));
  }

  ///Sends a new request message to the chat
  ///[prompt] the message content
  ///[role] the message role **DO NOT USE assistant**, it is reserved for the AI
  ///[username] the username of the message sender (optional)
  ///[expectJSON] whether to expect a JSON response or not. You need to explain the JSON structure
  ///in the prompt for this feature
  ///Returns a tuple of the response and the resource usage
  ///Example:
  ///```dart
  ///final (response, usage) = await chat.sendMessage('Explain the concept of a chatbot');
  ///print(response.choices.first.message); //prints the response message
  ///print(usage.totalTokens); //prints the total tokens used in the response
  ///```
  Future<(GroqResponse, GroqUsage)> sendMessage(
    String prompt, {
    GroqMessageRole role = GroqMessageRole.user,
    String? username,
    bool expectJSON = false,
  }) async {
    final request =
        GroqMessage(content: prompt, role: role, username: username);
    _streamController.add(RequestChatEvent(request));
    _chatItems.add(RequestChatEvent(request));
    final item = GroqConversationItem(_model, request);
    GroqResponse response;
    GroqUsage usage;
    GroqRateLimitInformation rateLimitInfo;
    try {
      (response, usage, rateLimitInfo) = await GroqApi.getNewChatCompletion(
        apiKey: _apiKey,
        chat: this,
        expectJSON: expectJSON,
        baseUrl: _baseUrl,
      );
    } catch (e) {
      _streamController.addError(e);
      rethrow;
    }
    _rateLimitInfo = rateLimitInfo;
    item.setResponse(response, usage);
    _chatItems.add(ResponseChatEvent(response, usage));
    _conversationItems.add(item);
    _streamController.add(ResponseChatEvent(response, usage));
    return (response, usage);
  }

  /// Converts the `GroqChat` object into a JSON-compatible `Map<String, dynamic>`.
  ///
  /// This method serializes the `GroqChat` instance into a JSON object by
  /// converting its fields to key-value pairs that are compatible with JSON.
  Map<String, dynamic> toJson() {
    return {
      'model': _model,
      'apiKey': _apiKey,
      'baseUrl': _baseUrl,
      'settings': _settings.toJson(),
      'chatItems': _chatItems.map((e) => e.toJson()).toList(),
      'rateLimitInfo': _rateLimitInfo?.toJson(),
      'registeredTools': _registeredTools.map((e) => e.toChatJson()).toList(),
    };
  }

  /// Creates a `GroqChat` instance from a JSON object.
  ///
  /// This factory constructor initializes a `GroqChat` object by deserializing
  /// the provided JSON data. The function `functionNameToFunction` is used to
  /// map string identifiers in the JSON to their corresponding function objects.
  /// The parameter given in the `functionNameToFunction` is the function name, which is used in the `GroqToolItem`.
  /// Enabling the proper deserialization of registered tools.
  /// Example:
  /// ```dart
  ///  var groqChat = GroqChat.fromJson(json, (name) {
  ///   if (name == 'exampleFunction') return exampleFunction;
  ///   if (name == 'anotherFunction') return anotherFunction;
  ///   throw ArgumentError('Unknown function name: $name');
  /// });
  /// ```
  GroqChat.fromJson(Map<String, dynamic> json,
      Function(Map<String, dynamic>) Function(String) functionNameToFunction) {
    _model = json['model'] as String;
    _apiKey = json['apiKey'] as String;
    _baseUrl = json['baseUrl'] as String? ?? GroqApi.defaultBaseUrl;
    _settings = GroqParser.settignsFromJson(json['settings']);
    _chatItems = (json['chatItems'] as List<dynamic>)
        .map((item) =>
            GroqParser.chatEventFromJson(item as Map<String, dynamic>))
        .toList();
    for (final item in _chatItems) {
      if (item is RequestChatEvent) {
        _conversationItems.add(GroqConversationItem(_model, item.message));
      } else if (item is ResponseChatEvent) {
        _conversationItems.last.setResponse(item.response, item.usage);
      }
    }
    if (json['rateLimitInfo'] != null) {
      _rateLimitInfo =
          GroqParser.rateLimitInformationFromJson(json['rateLimitInfo']);
    }

    _registeredTools = (json['registeredTools'] as List)
        .map((item) =>
            GroqParser.groqToolItemFromChatJson(item, functionNameToFunction))
        .toList();
  }
}
