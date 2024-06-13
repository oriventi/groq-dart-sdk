import 'dart:async';

import 'package:groq_sdk/extensions/groq_json_extensions.dart';
import 'package:groq_sdk/models/chat_event.dart';
import 'package:groq_sdk/models/groq_api.dart';
import 'package:groq_sdk/models/groq_conversation_item.dart';
import 'package:groq_sdk/models/groq_message.dart';
import 'package:groq_sdk/models/groq_rate_limit_information.dart';
import 'package:groq_sdk/models/groq_response.dart';
import 'package:groq_sdk/models/groq_usage.dart';

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
}

class GroqChat {
  String _model;
  final String _apiKey;
  final List<GroqConversationItem> _conversationItems = [];
  GroqChatSettings _settings;
  GroqRateLimitInformation? _rateLimitInfo;
  final StreamController<ChatEvent> _streamController =
      StreamController.broadcast();

  ///GroqChat constructor
  ///[model] the model id
  ///[apiKey] the api key
  ///[settings] the chat settings
  GroqChat(this._model, this._apiKey, this._settings);

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

  ///Returns a list of all messages in the conversation
  ///It is a list of GroqMessage objects and switches from request to response
  ///Example:
  ///```dart
  ///final conversation = chat.allMessages;
  ///print(conversation.first.request.message); //prints the first message in the conversation
  ///print(conversation.first.response.choices.first.message); //prints the first response in the conversation
  ///```
  List<GroqConversationItem> get allMessages => _conversationItems;

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

  ///Returns the latest response in the conversation
  ///```dart
  ///final response = chat.latestResponse;
  ///print(response.choices.first.message); //prints the latest response in the conversation
  ///```
  GroqResponse? get latestResponse => _conversationItems.last.response;

  ///Returns the latest resource usage in the conversation
  ///```dart
  ///final usage = chat.latestUsage;
  ///print(usage.totalTokens); //prints the total tokens used in the latest response
  ///```
  GroqUsage? get latestUsage => _conversationItems.last.usage;

  ///Returns the total tokens used in the conversation
  ///```dart
  ///final totalTokens = chat.totalTokens;
  ///print(totalTokens); //prints the total tokens used in the conversation
  ///```
  int get totalTokens {
    if (_conversationItems.isEmpty) return 0;
    return _conversationItems.fold(
        0,
        (previousValue, element) =>
            previousValue + (element.usage?.totalTokens ?? 0));
  }

  ///Sends a new request message to the chat
  ///[prompt] the message content
  ///[role] the message role **DO NOT USE assistant**, it is reserved for the AI
  ///[username] the username of the message sender (optional)
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
  }) async {
    final request =
        GroqMessage(content: prompt, role: role, username: username);
    _streamController.add(RequestChatEvent(request));
    final item = GroqConversationItem(_model, request);
    GroqResponse response;
    GroqUsage usage;
    GroqRateLimitInformation rateLimitInfo;
    try {
      (response, usage, rateLimitInfo) = await GroqApi.getNewChatCompletion(
        apiKey: _apiKey,
        prompt: request,
        chat: this,
      );
    } catch (e) {
      _streamController.addError(e);
      rethrow;
    }
    _rateLimitInfo = rateLimitInfo;
    item.setResponse(response, usage);
    _conversationItems.add(item);
    _streamController.add(ResponseChatEvent(response, usage));
    return (response, usage);
  }
}

///User server-side events to send the completion in small deltas rather than
///in a single batch after all processing has finished. \
///This reduces the time to first token received.
///Default: `false`
//TODO: Implement stream feature
// final bool stream;

///How many chat completion choices to generate for each input message. \
///Note that you will be `charged` based on the number of generated tokens across all of the choices. \
///Keep `n` as `1` to minimize costs. \
///Default: `1`
//TODO: Implement choicesCount feature
// final int choicesCount;
