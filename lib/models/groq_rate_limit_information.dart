class GroqRateLimitInformation {
  ///The total number of requests allowed per day
  int totalRequestsPerDay;

  ///The number of requests remaining for the day
  int remainingRequestsToday;

  ///The total number of tokens allowed per minute
  int totalTokensPerMinute;

  ///The number of tokens remaining for the minute
  int remainingTokensThisMinute;

  ///Information about the current rate limit of the Groq API
  GroqRateLimitInformation({
    required this.totalRequestsPerDay,
    required this.remainingRequestsToday,
    required this.totalTokensPerMinute,
    required this.remainingTokensThisMinute,
  });

  ///Creates a GroqRateLimitInformation from the headers of a http response
  factory GroqRateLimitInformation.fromHeaders(Map<String, String> headers) {
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

  @override
  String toString() {
    return 'GroqRateLimitInformation{totalRequestsPerDay: $totalRequestsPerDay, remainingRequestsPerDay: $remainingRequestsToday, totalTokensPerMinute: $totalTokensPerMinute, remainingTokensPerMinute: $remainingTokensThisMinute}';
  }
}
