## Groq Dart SDK
A powerful Dart client library for interacting with the Groq Cloud API, empowering you to easily harness the capabilities of state-of-the-art Large Language Models (LLMs) within your Dart and Flutter applications. 


## Features
- **Intuitive Chat Interface:**  Seamlessly create and manage chat sessions with Groq's LLMs.
- **Streaming Support:** Receive chat responses in real time with streaming functionality.
- **Model Management:** Retrieve metadata about available Groq models and dynamically switch between them.
- **Customization:**  Configure chat settings to fine-tune responses (temperature, max tokens, etc.).
- **Resource Usage Tracking:** Get detailed insights into token usage and request/response times.
- **Rate Limit Information:** Stay informed about your Groq API usage limits.
- **Future-proof:** Easily support new Groq models as they become available.
- **Audio Transcription:** Transcribe audio files into text using Groq's powerful Whisper models.
- **Audio Translation:** Translate audio files directly into english.

## Getting Started
1. Obtain a Groq API Key:
    - Visit the Groq Cloud console to create your API key: https://console.groq.com/keys

2. Install the Groq Dart SDK:
    - Add `groq_sdk` to your `pubspec.yaml` file:
        ```yaml
        dependencies:
            groq_sdk: ^0.0.7 # add the latest version here
        ```
    - Run `dart pub get`.

## Usage

### Creating a new chat
This initiates a new chat session with the specified model, optionally customizing settings like temperature and max tokens.
```dart
final groq = Groq('YOUR_GROQ_API_KEY');
//Start a chat with default settings
if(!await groq.canUseModel(GroqModels.llama3_8b)) return;

final chat = groq.startNewChat(GroqModels.llama3_8b);

//Start a chat with custom settings
final customChat = groq.startNewChat(GroqModels.llama3_70b, settings: GroqChatSettings(
    temperature: 0.8, //More creative responses
    maxTokens: 512, //shorter responses
));
```

### Listening to a chat stream
This allows you to process each message (both user requests and model responses) as they are sent and received in real-time.
```dart
final chat = groq.startNewChat(GroqModels.llama3_8b);

chat.stream.listen((event) {
    event.when(request: (requestEvent) {
      //Listen for user prompts
      print('Request sent...');
      print(requestEvent.message.content);
    }, response: (responseEvent) {
      //Listen for llm responses
      print(
          'Received response: ${responseEvent.response.choices.first.message}');
    });
  });
```

### Sending a Message
Sends a message to the model and awaits the response. The usage object provides details about token consumption and timing. It also sends a request and either a response or an error to the chat's `stream`.
You can additionally retrieve the response and usage via the return values of `sendMessage`
```dart
final (response, usage) = await chat.sendMessage('Explain LLMs to me please');
print(response.choices.first.message);
```

### Switching models and settings
This allows you to dynamically change the language model used in the chat session.
```dart
chat.switchModel(GroqModels.mixtral8_7b); //Also available during a running chat
```

### Accessing Rate Limit Information
Provides information about the remaining API calls and tokens you can use within your current rate limit period.
```dart
final rateLimitInfo = chat.rateLimitInfo;
print(rateLimitInfo.remainingRequestsToday);
```

### Retrieving Resource Usage Information
This gives you the token usage details (prompt tokens, completion tokens, total tokens) for the most recent response. It also gives you response times and prompt times
```dart
final latestUsage = chat.latestResponse.usage;
print(latestUsage.totalTokens);
```

### Total Usage for the entire chat
Calculates the cumulative token usage for all requests and responses within the current chat session.
```dart
final totalTokensUsed = chat.totalTokens;
print('Total tokens used in this chat: $totalTokensUsed');
```

### Audio Transcription
Transcribe audio files using Groq's supported `whisper-large-v3` model (or other available models). Replace `'./path/to/your/audio.mp3'` with the actual path to your audio file.
```dart
final groq = Groq('YOUR_GROQ_API_KEY');

try {
  final (transcriptionResult, usage, rateLimitInformation) = await groq.transcribeAudio(
    filePath: './path/to/your/audio.mp3', // Adjust file path as needed
  );
  print(transcriptionResult.text); // The transcribed text
} on GroqException catch (e) {
  print('Error transcribing audio: $e');
}
```


## Constants
Instead of looking up the standard models, you can use the ids via provided constants in `GroqModels`:
```dart
const String mixtral8_7b = 'mixtral-8x7b-32768';
const String gemma_7b = 'gemma-7b-it';
const String llama3_8b = 'llama3-8b-8192';
const String llama3_70b = 'llama3-70b-8192';
const String whisper_large_v3 = 'whisper-large-v3';
```
You can use these constants directly when starting a new chat or switching models:
```dart
final chat = groq.startNewChat(GroqModels.mixtral8_7b);
```

## Chat Settings

| Parameter                   | Description                                               | Default |
|-----------------------------|-----------------------------------------------------------|:-------:|
|maxConversationalMemoryLength|The number of previous messages to include in the context for the model's response. Higher values provide more context-aware responses.|1024|
|temperature|Controls the randomness of responses (0.0 - deterministic, 2.0 - very random).|1.0|
|maxTokens|Maximum number of tokens allowed in the generated response.|8192|
|topP|	Controls the nucleus sampling probability mass (0.0 - narrow focus, 1.0 - consider all options).	|1.0|
|stop|Optional stop sequence(s) to terminate response generation.|null|

## Important Notes:
- Replace `"YOUR_GROQ_API_KEY"` with your actual Groq API key, obtained from the Groq Cloud console: https://console.groq.com/keys
- The Groq Cloud console is your central hub for managing API keys, exploring documentation, and accessing other Groq Cloud features: https://console.groq.com/
- Multiple choices in GroqResponses are not supported yet.
