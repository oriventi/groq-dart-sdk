class GroqUsage {
  ///The number of tokens used in the prompt
  final int promptTokens;

  ///The number of tokens used in the completion
  final int completionTokens;

  ///The time taken in the prompt
  final Duration promptTime;

  ///The time taken in the completion
  final Duration completionTime;

  ///The usage of the groq resources \
  ///It contains the number of tokens used in the prompt and completion \
  ///It also contains the time taken in the prompt and completion \
  ///It is used for chats and audio responses \
  ///Audio responses just have a completion time, prompt tokens and completion tokens
  GroqUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.promptTime,
    required this.completionTime,
  });

  ///Returns the total tokens used in the prompt and completion
  int get totalTokens => promptTokens + completionTokens;

  ///Returns the total time taken in the prompt and completion
  Duration get totalTime => promptTime + completionTime;
}
