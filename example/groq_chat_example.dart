import 'package:groq_sdk/groq_sdk.dart';

void main(List<String> arguments) async {
  final groq = Groq('YOUR_API_KEY');

  //Checking model availability
  if (!await groq.canUseModel(llama3_8b)) {
    print('Cannot use model');
    return;
  }

  //Creating a new chat
  final chat = groq.startNewChat(llama3_8b,
      settings: GroqChatSettings.defaults().copyWith(choicesCount: 2));

  //Listening to chat events
  chat.stream.listen((event) {
    if (event is RequestChatEvent) {
      print('Request sent...');
      print(event.message.content);
    } else if (event is ResponseChatEvent) {
      print('Received response: ${event.response.choices.first.message}');
    }
  });

  //Sending a message which will add new data to the listening stream
  final (response, usage) =
      await chat.sendMessage('Explain LLMs to me please.');

  //Printing some information
  print(response.choices.length);
  print("Total tokens used: ${usage.totalTokens}");
  print("Total time taken: ${usage.totalTime}");
  print("Rate limit information: ${chat.rateLimitInfo.toString()}");
  print("-------------------");
  await Future.delayed(Duration(seconds: 2));
  await chat.sendMessage('What is the difference between LLM and GPT-3?');
  await Future.delayed(Duration(seconds: 5));
}
