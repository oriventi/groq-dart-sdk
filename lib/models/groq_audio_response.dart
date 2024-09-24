class GroqAudioResponse {
  final String requestId;
  final String text;
  final Map<String, dynamic> json;

  GroqAudioResponse({
    required this.requestId,
    required this.text,
    required this.json,
  });
}
