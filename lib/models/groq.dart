import 'package:groq_sdk/models/groq_api.dart';
import 'package:groq_sdk/models/groq_chat.dart';
import 'package:groq_sdk/models/groq_llm_model.dart';

class Groq {
  ///The API key to use the Groq API \
  ///Obtain it from the Groq website: \
  ///https://console.groq.com/keys
  String apiKey;

  ///Creates a new Groq instance \
  ///[apiKey] is the API key to use the Groq API \
  ///You can communicate with the Groq API via a Chat instance \
  ///Example:
  ///```dart
  ///final groq = Groq('EXAMPLE_API_KEY');
  ///final chat = groq.startNewChat(llama3_8b); //use a model id, provided by Groq
  ///final (response, resourceUsage) = await chat.sendMessage('YOUR_MESSAGE');
  ///```
  Groq(this.apiKey);

  ///Returns the model metadata from groq with the given model id
  Future<GroqLLMModel> getModel(String modelId) async {
    return await GroqApi.getModel(modelId, apiKey);
  }

  ///Returns a list of all model metadatas available in Groq
  Future<List<GroqLLMModel>> listModels() async {
    return await GroqApi.listModels(apiKey);
  }

  ///Returns whether the model with the given model id can be used \
  ///It returns true if the model is currently active and false otherwise \
  ///Example:
  ///```dart
  ///if (await groq.canUseModel(llama3_8b)) {
  ///  final chat = groq.startNewChat(llama3_8b);
  ///}
  ///```
  Future<bool> canUseModel(String modelId) async {
    try {
      final model = await getModel(modelId);
      return model.isCurrentlyActive;
    } catch (e) {
      return false;
    }
  }

  ///Returns a new chat instance with the given model id \
  ///`modelId` is the model id to use for the chat \
  ///`settings` are the chat settings, defaults to GroqChatSettings.defaults() \
  ///`customApiKey` is the API key to use for the chat, defaults to the Groq instance API key \
  ///Example:
  ///```dart
  /// final chat = groq.startNewChat(llama3_8b);
  /// final (response, resourceUsage) = await chat.sendMessage('YOUR_MESSAGE');
  /// ```
  /// Or use the chat as a stream:
  /// ```dart
  /// chat.stream.listen((event) {
  ///   if (event is RequestChatEvent) {
  ///     print(event.request.message.message);
  ///   } else if (event is ResponseChatEvent) {
  ///     print(event.response.choices.first.message);
  ///     print(event.usage.totalTokens);
  ///   }
  /// });
  /// ```
  GroqChat startNewChat(
    String modelId, {
    GroqChatSettings settings = const GroqChatSettings.defaults(),
    String? customApiKey,
  }) {
    final specificApiKey = customApiKey ?? apiKey;
    return GroqChat(modelId, specificApiKey, settings);
  }
}
