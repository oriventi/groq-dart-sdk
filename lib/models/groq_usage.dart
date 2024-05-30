class GroqUsage {
  final int promptTokens;
  final int completionTokens;
  final Duration promptTime;
  final Duration completionTime;

  ///The usage of the groq resources \
  ///It contains the number of tokens used in the prompt and completion \
  ///It also contains the time taken in the prompt and completion
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

  factory GroqUsage.fromJson(Map<String, dynamic> json) {
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
}
