import 'package:groq_sdk/models/groq_chat.dart';
import 'package:groq_sdk/models/groq_conversation_item.dart';
import 'package:groq_sdk/models/groq_message.dart';
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

extension GorqToolParameterTypeExtension on GroqToolParameterType {
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
}

extension GroqConversationItemExtension on GroqConversationItem {
  void setResponse(GroqResponse response, GroqUsage usage) {
    this.response = response;
    this.usage = usage;
  }

  void setResponseFromJson(Map<String, dynamic> json) {
    response = GroqParser.groqResponseFromJson(json);
    usage = GroqParser.groqUsageFromChatJson(json);
  }
}

extension GroqMessageExtension on GroqMessage {
  Map<String, dynamic> toJson() {
    final jsonMap = {
      'content': content,
      'role': GroqMessageRoleParser.toId(role),
    };
    if (username != null) {
      jsonMap['user'] = username!;
    }
    return jsonMap;
  }
}
