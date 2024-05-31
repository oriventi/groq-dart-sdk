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

  @override
  String toString() {
    return 'GroqRateLimitInformation{totalRequestsPerDay: $totalRequestsPerDay, remainingRequestsPerDay: $remainingRequestsToday, totalTokensPerMinute: $totalTokensPerMinute, remainingTokensPerMinute: $remainingTokensThisMinute}';
  }
}
