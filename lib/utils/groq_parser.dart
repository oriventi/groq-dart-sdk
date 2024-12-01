import 'dart:convert';

import 'package:groq_sdk/models/groq_llm_model.dart';
import 'package:groq_sdk/models/groq_message.dart';
import 'package:groq_sdk/models/groq_rate_limit_information.dart';
import 'package:groq_sdk/models/groq_response.dart';
import 'package:groq_sdk/models/groq_audio_response.dart';
import 'package:groq_sdk/models/groq_usage.dart';

class GroqParser {
  ///Parses the audio response information from the json
  static GroqAudioResponse audioResponseFromJson(Map<String, dynamic> json) {
    return GroqAudioResponse(
      requestId: json['x_groq']['id'] as String,
      text: json['text'] as String,
      json: json,
    );
  }

  ///Parses the LLM model information from the json
  static GroqLLMModel llmModelFromJson(Map<String, dynamic> json) {
    return GroqLLMModel(
      modelId: json['id'] as String,
      ownedBy: json['owned_by'] as String,
      isCurrentlyActive: json['active'] as bool,
      contextWindow: json['context_window'] as int,
    );
  }

  ///Parses the message information from the json
  static GroqMessage groqMessageFromJson(Map<String, dynamic> json) {
    if (json['tool_calls'] != null && json['tool_calls'].isNotEmpty) {
      //Is tool call
      return GroqMessage(
          content: '',
          isToolCall: true,
          toolCalls: (json['tool_calls'] as List)
              .map((item) => groqToolCallFromJson(item as Map<String, dynamic>))
              .toList(),
          role: GroqMessageRoleParser.tryParse(json['role'] as String) ??
              GroqMessageRole.assistant,
          username: json['user'] as String?);
    }
    return GroqMessage(
      content: json['content'] as String,
      username: json['user'] as String?,
      role: GroqMessageRoleParser.tryParse(json['role'] as String) ??
          GroqMessageRole.user,
    );
  }

  static GroqToolCall groqToolCallFromJson(Map<String, dynamic> json) {
    print(json.toString());
    return GroqToolCall(
      callId: json['id'] as String,
      // role: GroqMessageRoleParser.tryParse(json['role'] as String) ??
      //     GroqMessageRole.user,
      functionName: json['function']['name'] as String,
      arguments: jsonDecode(json['function']['arguments']),
    );
  }

  ///Parses the rate limit information from the headers
  static GroqRateLimitInformation rateLimitInformationFromHeaders(
      Map<String, String> headers) {
    return GroqRateLimitInformation(
      totalRequestsPerDay:
          int.tryParse(headers['x-ratelimit-limit-requests'] ?? '0') ?? 0,
      remainingRequestsToday:
          int.tryParse(headers['x-ratelimit-remaining-requests'] ?? '0') ?? 0,
      totalTokensPerMinute:
          int.tryParse(headers['x-ratelimit-limit-tokens'] ?? '0') ?? 0,
      remainingTokensThisMinute:
          int.tryParse(headers['x-ratelimit-remaining-tokens'] ?? '0') ?? 0,
    );
  }

  ///Parses the choice information from the json
  static GroqChoice groqChoiceFromJson(Map<String, dynamic> json) {
    return GroqChoice(
      messageData: GroqParser.groqMessageFromJson(json["message"]),
      finishReason: json['finish_reason'] as String?,
    );
  }

  ///Parses the response information from the json
  static GroqResponse groqResponseFromJson(Map<String, dynamic> json) {
    return GroqResponse(
      id: json['id'] as String,
      choices: (json['choices'] as List)
          .map(
            (item) =>
                GroqParser.groqChoiceFromJson(item as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created'] as int,
          isUtc: true),
    );
  }

  ///Parses the usage information from the json
  static GroqUsage groqUsageFromChatJson(Map<String, dynamic> json) {
    return GroqUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      // it is stored in json as 0.001 seconds e.g.
      promptTime: Duration(
          milliseconds: ((json['prompt_time'] as double) * 1000).toInt()),
      completionTime: Duration(
          milliseconds: ((json['completion_time'] as double) * 1000).toInt()),
    );
  }

  static GroqUsage groqUsageFromAudioJson(Map<String, dynamic> json) {
    return GroqUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      // it is stored in json as 0.001 seconds e.g.
      promptTime: Duration.zero,
      completionTime: Duration(
          milliseconds: ((json['total_time'] as double) * 1000).toInt()),
    );
  }

  static GroqLlamaGuardCategory? groqLlamaGuardCategoryFromString(
      String category) {
    switch (category) {
      case 'S1':
        return GroqLlamaGuardCategory.violentCrime;
      case 'S2':
        return GroqLlamaGuardCategory.nonViolentCrime;
      case 'S3':
        return GroqLlamaGuardCategory.sexRelatedCrime;
      case 'S4':
        return GroqLlamaGuardCategory.childSexualExploitation;
      case 'S5':
        return GroqLlamaGuardCategory.defamation;
      case 'S6':
        return GroqLlamaGuardCategory.specializedAdvice;
      case 'S7':
        return GroqLlamaGuardCategory.privacy;
      case 'S8':
        return GroqLlamaGuardCategory.intellectualProperty;
      case 'S9':
        return GroqLlamaGuardCategory.indiscriminateWeapons;
      case 'S10':
        return GroqLlamaGuardCategory.hate;
      case 'S11':
        return GroqLlamaGuardCategory.selfHarm;
      case 'S12':
        return GroqLlamaGuardCategory.sexualContent;
      case 'S13':
        return GroqLlamaGuardCategory.elections;
      case 'S14':
        return GroqLlamaGuardCategory.codeInterpreterAbuse;
      default:
        return null;
    }
  }
}
