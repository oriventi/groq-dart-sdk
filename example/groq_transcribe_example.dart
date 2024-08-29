import 'package:groq_sdk/groq_sdk.dart';

void main(List<String> arguments) async {
  final groq = Groq('YOU_API_KEY');

  //Checking model availability
  if (!await groq.canUseModel(GroqModels.whisper_large_v3)) {
    print('Cannot use model');
    return;
  }

  //Sending an audio file for transcription
  final (response, rateLimitInfo) = await groq.transcribeAudio(
      audioFileUrl: 'res/audio.m4a', modelId: GroqModels.whisper_large_v3);

  //Printing some received information
  print('Transcription: ${response.text}');
  print(
      'Rate limit remaining Tokens: ${rateLimitInfo.remainingTokensThisMinute}');
}
