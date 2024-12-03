import 'dart:convert';

import 'package:groq_sdk/models/chat_event.dart';
import 'package:groq_sdk/models/groq_chat.dart';
import 'package:groq_sdk/models/groq_conversation_item.dart';
import 'package:groq_sdk/models/groq_message.dart';
import 'package:groq_sdk/models/groq_rate_limit_information.dart';
import 'package:groq_sdk/models/groq_response.dart';
import 'package:groq_sdk/models/groq_tool_use_item.dart';
import 'package:groq_sdk/models/groq_usage.dart';
import 'package:groq_sdk/utils/groq_parser.dart';

extension GroqChatSettingsExtension on GroqChatSettings {
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'max_tokens': maxTokens,
      'top_p': topP,
      // 'unknown': choicesCount,
      // 'stream': stream,
      'stop': stop,
    };
  }
}

extension ChatEventExtension on ChatEvent {
  Map<String, dynamic> toJson() {
    if (this is RequestChatEvent) {
      return {
        'type': 'request',
        'message': (this as RequestChatEvent).message.toJson(),
      };
    } else if (this is ResponseChatEvent) {
      final res = this as ResponseChatEvent;
      return {
        'type': 'response',
        'message': res.response.toJson(),
        'usage': res.usage.toJson(),
      };
    }

    return {
      'type': 'undefined',
    };
  }
}

extension GroqToolParameterTypeExtension on GroqToolParameterType {
  String toJson() {
    switch (this) {
      case GroqToolParameterType.string:
        return 'string';
      case GroqToolParameterType.number:
        return 'number';
      case GroqToolParameterType.boolean:
        return 'boolean';
    }
  }
}

extension GroqToolUseExtension on GroqToolItem {
  Map<String, dynamic> toJson() {
    return {
      'type': 'function',
      'function': {
        'name': functionName,
        'description': functionDescription,
        'parameters': {
          'type': 'object',
          'properties': [
            ...parameters.map((parameter) {
              return {
                'type': parameter.parameterType.toJson(),
                'description': parameter.parameterDescription,
                if (parameter.allowedValues.isNotEmpty)
                  'enum': parameter.allowedValues,
              };
            }),
          ],
          'required': parameters
              .where((parameter) => parameter.isRequired)
              .map((parameter) => parameter.parameterName)
              .toList(),
        },
      }
    };
  }

  Map<String, dynamic> toChatJson() {
    return {
      'functionName': functionName,
      'functionDescription': functionDescription,
      // 'function': functionToStringId(function),
      'parameters': parameters.map((parameter) {
        return {
          'name': parameter.parameterName,
          'description': parameter.parameterDescription,
          'type': parameter.parameterType.toJson(),
          'allowedValues': parameter.allowedValues,
          'isRequired': parameter.isRequired,
        };
      }).toList(),
    };
  }
}

extension GroqResponseExtension on GroqResponse {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'choices': choices.map((choice) => choice.toJson()).toList(),
      'created': createdAt.millisecondsSinceEpoch,
    };
  }
}

extension GroqConversationItemExtension on GroqConversationItem {
  void setResponse(GroqResponse response, GroqUsage usage) {
    this.response = response;
    this.usage = usage;
  }

  void setResponseFromJson(Map<String, dynamic> json) {
    response = GroqParser.groqResponseFromJson(json);
    usage = GroqParser.groqUsageFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      "model": model,
      "request": request.toJson(),
      "response": response?.toJson(),
      "usage": usage?.toJson()
    };
  }
}

extension GroqUsageExtension on GroqUsage {
  Map<String, dynamic> toJson() {
    return {
      'promptTokens': promptTokens,
      'completionTokens': completionTokens,
      'promptTime': promptTime.inMilliseconds,
      'completionTime': completionTime.inMilliseconds,
    };
  }
}

extension GroqChoiceExtension on GroqChoice {
  Map<String, dynamic> toJson() {
    return {
      'message': messageData.toJson(),
      'finish_reason': finishReason,
    };
  }
}

extension GroqRateLimitInformationExtension on GroqRateLimitInformation {
  Map<String, dynamic> toJson() {
    return {
      'totalRequestsPerDay': totalRequestsPerDay,
      'remainingRequestsToday': remainingRequestsToday,
      'totalTokensPerMinute': totalTokensPerMinute,
      'remainingTokensThisMinute': remainingTokensThisMinute,
    };
  }
}

extension GroqToolCallExtension on GroqToolCall {
  Map<String, dynamic> toJson() {
    return {
      'id': callId,
      'type': 'function',
      'function': {
        'name': functionName,
        'arguments': jsonEncode(arguments),
      },
    };
  }
}

extension GroqMessageExtension on GroqMessage {
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'content': content,
      'role': GroqMessageRoleParser.toId(role),
    };
    if (toolCalls.isNotEmpty) {
      jsonMap['tool_calls'] =
          toolCalls.map((toolCall) => toolCall.toJson()).toList();
    }
    if (username != null) {
      jsonMap['username'] = username!;
    }
    return jsonMap;
  }
}
