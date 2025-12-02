import 'package:groq_sdk/groq_sdk.dart';

void main(List<String> arguments) async {
  // Example 1: Using the default Groq API endpoint
  final groqDefault = Groq('YOUR_API_KEY');

  // Example 2: Using a custom base URL (e.g., for a proxy or custom endpoint)
  final groqCustom = Groq('YOUR_API_KEY', 'https://custom.api.com/openai/v1');

  // Example 3: Without API key (backend handles authentication)
  final groqBackendAuth = Groq(null, 'https://your-backend.com/api/v1');

  // Start a chat with the custom base URL
  final chat = groqCustom.startNewChat(
    GroqModels.llama3_8b,
    settings: GroqChatSettings.defaults(),
  );

  // Send a message using the custom endpoint
  final (response, usage) = await chat.sendMessage('Hello, world!');
  print('Response: ${response.choices.first.message}');
  print('Total tokens: ${usage.totalTokens}');

  // Example with backend authentication (no API key needed)
  final backendChat = groqBackendAuth.startNewChat(GroqModels.llama3_8b);
  final (backendResponse, backendUsage) =
      await backendChat.sendMessage('Hello from backend!');
  print('Backend Response: ${backendResponse.choices.first.message}');

  // You can also override the base URL per operation
  // For example, transcription with a different custom base URL
  final (audioResponse, rateLimit) = await groqDefault.transcribeAudio(
    audioFileUrl: 'path/to/audio.mp3',
    modelId: GroqModels.whisper_large_v3,
    customBaseUrl: 'https://another-custom.api.com/openai/v1',
  );
  print('Transcription: ${audioResponse.text}');
}
