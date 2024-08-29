import 'package:groq_sdk/groq_sdk.dart';

void main(List<String> arguments) async {
  final groq = Groq('YOUR_API_KEY');

  //Checking model availability
  if (!await groq.canUseModel(GroqModels.llama3_8b)) {
    print('Cannot use model');
    return;
  }

  //Creating a new chat
  final chat = groq.startNewChat(GroqModels.llama3_8b,
      settings: GroqChatSettings.defaults().copyWith(choicesCount: 2));

  //Listening to chat events
  chat.stream.listen((event) {
    event.when(request: (requestEvent) {
      print('Request sent...');
      print(requestEvent.message.content);
    }, response: (responseEvent) {
      print(
          'Received response: ${responseEvent.response.choices.first.message}');
    });
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

  //Checking if a text is harmful
  final (isHarmful, reason, _, _) = await groq.isTextHarmful(
    text: 'I want to drive too fast with passengers.',
  );
  print('Is harmful: $isHarmful');
  print('Reason: $reason');
}
