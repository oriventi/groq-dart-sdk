import 'package:groq_sdk/groq_sdk.dart';
import 'package:groq_sdk/models/groq_api.dart';
import 'package:groq_sdk/models/groq_audio_response.dart';
import 'package:groq_sdk/utils/groq_parser.dart';

class Groq {
  ///The API key to use the Groq API \
  ///Obtain it from the Groq website: \
  ///https://console.groq.com/keys \
  ///Can be null if your backend handles authentication
  String? apiKey;

  ///The base URL for the Groq API \
  ///Defaults to 'https://api.groq.com/openai/v1' \
  ///Can be customized to use a different endpoint
  String baseUrl;

  ///Creates a new Groq instance \
  ///[apiKey] is the API key to use the Groq API (optional if backend handles auth) \
  ///[baseUrl] is the base URL for the Groq API (optional, defaults to 'https://api.groq.com/openai/v1') \
  ///You can communicate with the Groq API via a Chat instance \
  ///Example:
  ///```dart
  ///final groq = Groq('EXAMPLE_API_KEY');
  ///final chat = groq.startNewChat(llama3_8b); //use a model id, provided by Groq
  ///final (response, resourceUsage) = await chat.sendMessage('YOUR_MESSAGE');
  ///```
  ///Or with a custom base URL:
  ///```dart
  ///final groq = Groq('EXAMPLE_API_KEY', baseUrl: 'https://custom.api.com/v1');
  ///```
  ///Or without API key (if backend handles auth):
  ///```dart
  ///final groq = Groq(null, baseUrl: 'https://your-backend.com/api/v1');
  ///```
  Groq([this.apiKey, String? baseUrl])
      : baseUrl = baseUrl ?? GroqApi.defaultBaseUrl;

  ///Returns the model metadata from groq with the given model id \
  Future<GroqLLMModel> getModel(String modelId) async {
    return await GroqApi.getModel(modelId, apiKey ?? '', baseUrl: baseUrl);
  }

  ///Returns a list of all model metadatas available in Groq \
  Future<List<GroqLLMModel>> listModels() async {
    return await GroqApi.listModels(apiKey ?? '', baseUrl: baseUrl);
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
  ///`customBaseUrl` is the base URL to use for the chat, defaults to the Groq instance base URL \
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
    String? customBaseUrl,
  }) {
    final specificApiKey = customApiKey ?? apiKey ?? '';
    final specificBaseUrl = customBaseUrl ?? baseUrl;
    return GroqChat(modelId, specificApiKey, settings, specificBaseUrl);
  }

  ///Transcribes the audio file at the given `audioFileUrl`, max 25Mb \
  ///It uses the model with the given `modelId` \
  ///`customApiKey` is the API key to use for the transcription, defaults to the Groq instance API key \
  ///`customBaseUrl` is the base URL to use for the transcription, defaults to the Groq instance base URL \
  ///Returns the transcribed audio response, the usage of the groq resources and the rate limit information \
  ///Example:
  ///```dart
  ///final (response, rateLimit) = await groq.transcribeAudio(
  ///  audioFileUrl: 'YOUR_DIRECTORY/audio.mp3',
  ///  modelId: whisper_large_v3,
  ///  customApiKey: 'EXAMPLE_API_KEY',
  ///);
  ///```
  ///Supported file formats: mp3, mp4, mpeg, mpga, m4a, wav, and webm. \
  Future<(GroqAudioResponse, GroqRateLimitInformation)> transcribeAudio({
    required String audioFileUrl,
    required String modelId,
    String? customApiKey,
    String? customBaseUrl,
    Map<String, String> optionalParameters = const {},
  }) async {
    final specificApiKey = customApiKey ?? apiKey ?? '';
    final specificBaseUrl = customBaseUrl ?? baseUrl;
    return await GroqApi.transcribeAudio(
      filePath: audioFileUrl,
      modelId: modelId,
      apiKey: specificApiKey,
      optionalParameters: optionalParameters,
      baseUrl: specificBaseUrl,
    );
  }

  ///Translates the audio file at the given `audioFileUrl` to ENGLISH, max 25Mb \
  ///It uses the model with the given `modelId` \
  ///`customApiKey` is the API key to use for the translation, defaults to the Groq instance API key \
  ///`customBaseUrl` is the base URL to use for the translation, defaults to the Groq instance base URL \
  ///`temperature` is the randomness of the translation, defaults to 0.5 \
  ///Returns the translated audio response, the usage of the groq resources and the rate limit information \
  ///Example:
  ///```dart
  ///final (response, rateLimit) = await groq.translateAudio(
  ///  audioFileUrl: 'YOUR_DIRECTORY/audio.mp3',
  ///  modelId: whisper_large_v3,
  ///  customApiKey: 'EXAMPLE_API_KEY',
  ///  temperature: 0.4,
  ///);
  ///```
  ///Supported file formats: mp3, mp4, mpeg, mpga, m4a, wav, and webm. \
  Future<(GroqAudioResponse, GroqRateLimitInformation)> translateAudio({
    required String audioFileUrl,
    required String modelId,
    String? customApiKey,
    String? customBaseUrl,
    double temperature = 0.5,
  }) async {
    final specificApiKey = customApiKey ?? apiKey ?? '';
    final specificBaseUrl = customBaseUrl ?? baseUrl;
    return await GroqApi.translateAudio(
      filePath: audioFileUrl,
      modelId: modelId,
      apiKey: specificApiKey,
      temperature: temperature,
      baseUrl: specificBaseUrl,
    );
  }

  ///Checks if the given `text` is harmful \
  ///`customApiKey` is the API key to use for the check, defaults to the Groq instance API key \
  ///`customBaseUrl` is the base URL to use for the check, defaults to the Groq instance base URL \
  ///Returns whether the text is harmful, the harmful category and the rate limit information \
  ///Example:
  ///```dart
  ///final (isHarmful, harmfulCategory, usage, rateLimit) = await groq.isTextHarmful(
  ///  text: 'YOUR_TEXT',
  /// );
  ///
  /// ```
  Future<(bool, GroqLlamaGuardCategory?, GroqUsage, GroqRateLimitInformation?)>
      isTextHarmful({
    required String text,
    String? customApiKey,
    String? customBaseUrl,
  }) async {
    final specificApiKey = customApiKey ?? apiKey ?? '';
    final specificBaseUrl = customBaseUrl ?? baseUrl;
    final chat = GroqChat(GroqModels.llama_guard_3_8b, specificApiKey,
        GroqChatSettings.defaults(), specificBaseUrl);
    final (response, usage) = await chat.sendMessage(text);
    final answerString = response.choices.first.message;
    bool isHarmful = false;
    GroqLlamaGuardCategory? harmfulCategory;
    if (answerString.contains("unsafe")) {
      isHarmful = true;
      final List<String> answerList = answerString.trim().split('\n');
      if (answerList.length < 2) {
        throw GroqException(
            statusCode: 400,
            error: GroqError(
                message: 'Received invalid response', type: 'InvalidResponse'));
      }
      String harmfulCategoryString = answerList[1];
      harmfulCategory =
          GroqParser.groqLlamaGuardCategoryFromString(harmfulCategoryString);
    }
    return (isHarmful, harmfulCategory, usage, chat.rateLimitInfo);
  }
}
