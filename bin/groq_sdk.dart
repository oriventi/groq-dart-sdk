import 'package:groq_sdk/groq_sdk.dart';
import 'package:groq_sdk/models/groq.dart';
import 'package:groq_sdk/models/groq_chat.dart';
import 'package:groq_sdk/models/groq_llm_model.dart';

void main(List<String> arguments) async {
  final groq = Groq('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');
  groq.canUseModel(llama3_8b).then((model) {
    print(model);
  });

  final chat = groq.startNewChat(llama3_8b,
      settings: GroqChatSettings.defaults().copyWith(choicesCount: 2));

  chat.stream.listen((event) {
    if (event is RequestChatEvent) {
      print('Request sent...');
      print(event.message.content);
    } else if (event is ResponseChatEvent) {
      print('Received response: ${event.response.choices.first.message}');
    }
  });

  final (_, usage) = await chat.sendMessage('Explain LLMs to me please.');

  print("Total tokens used: ${usage.totalTokens}");
  print("Total time taken: ${usage.totalTime}");
  print("Rate limit information: ${chat.rateLimitInfo.toString()}");
  print("-------------------");
  await Future.delayed(Duration(seconds: 2));
  await chat.sendMessage('What is the difference between LLM and GPT-3?');
  await Future.delayed(Duration(seconds: 5));
}
