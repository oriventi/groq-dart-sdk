import 'dart:convert';

import 'package:groq_sdk/extensions/groq_json_extensions.dart';
import 'package:groq_sdk/models/groq_chat.dart';
import 'package:groq_sdk/models/groq_conversation_item.dart';
import 'package:groq_sdk/models/groq_exceptions.dart';
import 'package:groq_sdk/models/groq_llm_model.dart';
import 'package:groq_sdk/models/groq_message.dart';
import 'package:groq_sdk/models/groq_rate_limit_information.dart';
import 'package:groq_sdk/models/groq_response.dart';
import 'package:groq_sdk/models/groq_audio_response.dart';
import 'package:groq_sdk/models/groq_usage.dart';
import 'package:groq_sdk/utils/auth_http.dart';
import 'package:groq_sdk/utils/groq_parser.dart';
import 'package:http/http.dart' as http;

class GroqApi {
  static const String _chatCompletionUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _getModelBaseUrl =
      'https://api.groq.com/openai/v1/models';
  static const String _getAudioTranscriptionUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';
  static const String _getAudioTranslationUrl =
      'https://api.groq.com/openai/v1/audio/translations';

  ///Returns the model metadata from groq with the given model id
  static Future<GroqLLMModel> getModel(String modelId, String apiKey) async {
    final response =
        await AuthHttp.get(url: '$_getModelBaseUrl/$modelId', apiKey: apiKey);
    if (response.statusCode == 200) {
      return GroqParser.llmModelFromJson(json.decode(response.body));
    } else {
      throw GroqException.fromResponse(response);
    }
  }

  ///Returns a list of all model metadatas available in Groq
  static Future<List<GroqLLMModel>> listModels(String apiKey) async {
    final response = await AuthHttp.get(url: _getModelBaseUrl, apiKey: apiKey);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> jsonList = jsonData['data'] as List<dynamic>;
      return jsonList.map((json) => GroqParser.llmModelFromJson(json)).toList();
    } else {
      throw GroqException.fromResponse(response);
    }
  }

  ///Returns a new chat instance with the given model id
  static Future<(GroqResponse, GroqUsage, GroqRateLimitInformation)>
      getNewChatCompletion({
    required String apiKey,
    required GroqMessage prompt,
    required GroqChat chat,
  }) async {
    final Map<String, dynamic> jsonMap = {};
    List<Map<String, dynamic>> messages = [];
    List<GroqConversationItem> allMessages = chat.allMessages;
    if (chat.allMessages.length > chat.settings.maxConversationalMemoryLength) {
      allMessages.removeRange(
          0, allMessages.length - chat.settings.maxConversationalMemoryLength);
    }
    for (final message in allMessages) {
      messages.add(message.request.toJson());
      messages.add(message.response!.choices.first.messageData.toJson());
    }
    messages.add(prompt.toJson());
    jsonMap['messages'] = messages;
    jsonMap['model'] = chat.model;
    jsonMap.addAll(chat.settings.toJson());
    final response = await AuthHttp.post(
        url: _chatCompletionUrl, apiKey: apiKey, body: jsonMap);
    //Rate Limit information
    final rateLimitInfo =
        GroqParser.rateLimitInformationFromHeaders(response.headers);
    if (response.statusCode < 300) {
      final Map<String, dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      final GroqResponse groqResponse =
          GroqParser.groqResponseFromJson(jsonData);
      final GroqUsage groqUsage =
          GroqParser.groqUsageFromChatJson(jsonData["usage"]);
      return (groqResponse, groqUsage, rateLimitInfo);
    } else if (response.statusCode == 429) {
      throw GroqRateLimitException(
        retryAfter: Duration(
          seconds: int.tryParse(response.headers['retry-after'] ?? '0') ?? 0,
        ),
      );
    } else {
      throw GroqException.fromResponse(response);
    }
  }

  ///transcribes the audio file at the given path using the model with the given model id
  static Future<(GroqAudioResponse, GroqRateLimitInformation)> transcribeAudio({
    required String apiKey,
    required String filePath,
    required String modelId,
  }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(_getAudioTranscriptionUrl));

    request.headers['Authorization'] = 'Bearer $apiKey';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    request.fields['model'] = modelId;

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();

    final jsonBody = json.decode(responseBody);
    if (response.statusCode == 200) {
      final audioResponse = GroqParser.audioResponseFromJson(jsonBody);
      print(jsonBody);
      // final usage =
      //     GroqParser.groqUsageFromAudioJson(jsonBody['x_groq']['usage']);
      final rateLimitInfo =
          GroqParser.rateLimitInformationFromHeaders(response.headers);
      return (audioResponse, rateLimitInfo);
    } else {
      throw GroqException(
          statusCode: response.statusCode, error: GroqError.fromJson(jsonBody));
    }
  }

  ///Translates the audio file at the given file path to text
  static Future<(GroqAudioResponse, GroqRateLimitInformation)> translateAudio({
    required String apiKey,
    required String filePath,
    required String modelId,
    required double temperature,
  }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(_getAudioTranslationUrl));

    request.headers['Authorization'] = 'Bearer $apiKey';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    request.fields['model'] = modelId;
    request.fields['temperature'] = temperature.toString();

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();

    final jsonBody = json.decode(responseBody);
    if (response.statusCode == 200) {
      final audioResponse = GroqParser.audioResponseFromJson(jsonBody);
      final rateLimitInfo =
          GroqParser.rateLimitInformationFromHeaders(response.headers);
      return (audioResponse, rateLimitInfo);
    } else {
      throw GroqException(
          statusCode: response.statusCode, error: GroqError.fromJson(jsonBody));
    }
  }
}
