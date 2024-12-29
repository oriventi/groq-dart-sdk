![Codecov](https://codecov.io/gh/oriventi/groq-dart-sdk/branch/main/graph/badge.svg) [![All Contributors](https://img.shields.io/github/all-contributors/oriventi/groq-dart-sdk?color=ee8449&style=flat-square)](#contributors)

<a href="https://groq.com" target="_blank" rel="noopener noreferrer">
  <img
    src="https://groq.com/wp-content/uploads/2024/03/PBG-mark1-color.svg"
    alt="Powered by Groq for fast inference."
    width="200" height="100"
  />
</a>

## Groq Dart SDK

A powerful Dart client library for interacting with the Groq Cloud API, empowering you to easily harness the capabilities of state-of-the-art Large Language Models (LLMs) within your Dart and Flutter applications.

> **Note:** This is an independent project and not an official package maintained by Groq. For official resources, please visit [groq.com](https://groq.com).

## Features

- **Intuitive Chat Interface:** Seamlessly create and manage chat sessions with Groq's LLMs.
<!-- - **Streaming Support:** Receive chat responses in real time with streaming functionality. -->
- **Model Management:** Retrieve metadata about available Groq models and dynamically switch between them.
- **Customization:** Configure chat settings to fine-tune responses (temperature, max tokens, etc.).
- **Tool Use:** Let the model invoke functions to retrieve additional data or perform tasks.
- **Resource Usage Tracking:** Get detailed insights into token usage and request/response times.
- **Rate Limit Information:** Stay informed about your Groq API usage limits.
- **Future-proof:** Easily support new Groq models as they become available.
- **Audio Transcription:** Transcribe audio files into text using Groq's powerful Whisper models.
- **Audio Translation:** Translate audio files directly into english.
- **Content Moderation:** Easily check if texts are harmful.

## Getting Started

1. Obtain a Groq API Key:

   - Visit the Groq Cloud console to create your API key: https://console.groq.com/keys

2. Install the Groq Dart SDK:
   - Add `groq_sdk` to your `pubspec.yaml` file:
     ```yaml
     dependencies:
       groq_sdk: ^0.1.0 # add the latest version here
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

### Retrieving a JSON response

You can request the model to return a response in JSON format by setting the `expectJSON` parameter to `true` when sending a message. For this feature you need to explain the JSON structure in the prompt.

```dart
final (response, usage) = await chat.sendMessage(
  'Is the following city name a capital? Answer in a json format with the key "capital", which takes a bool as value: New York',
  expectJSON: true,
);
```

It will return

```json
{
  "capital": false
}
```

### Switching models and settings

This allows you to dynamically change the language model used in the chat session.

```dart
chat.switchModel(GroqModels.mixtral8_7b); //Also available during a running chat
```

### Tool Use

The Groq SDK allows you to register tools that can be invoked dynamically during a chat. Tools encapsulate specific functionality and can accept parameters to customize their behavior.

The following example demonstrates how to create a weather tool, register it in a chat, and handle a tool call dynamically.

```dart
// Define the weather tool
final weatherTool = GroqToolItem(
  functionName: 'get_weather',
  functionDescription: 'Get weather information for a specified location',
  parameters: [
    GroqToolParameter(
      parameterName: 'location',
      parameterDescription: 'City or location name',
      parameterType: GroqToolParameterType.string,
      isRequired: true,
    ),
    GroqToolParameter(
      parameterName: 'units',
      parameterDescription: 'Temperature units (metric or imperial)',
      parameterType: GroqToolParameterType.string,
      isRequired: false,
      allowedValues: ['metric', 'imperial'],
    ),
  ],
  function: (args) {
      final location = args['location'] as String;
      final units = args['units'] as String? ?? 'metric';
      return MyWeatherApi.getWeather(location, units);
  },
);

final chat = groq.startNewChat(GroqModels.llama3_groq_70b_tool_use_preview);

// Register the tool with the chat
chat.registerTool(weatherTool);

// Send a message to the chat and handle tool calls
final (response, usage) = await chat.sendMessage(
  'What is the weather in Boston like (in metric units)?',
);

final message = response.choices.first.messageData;

// Handle tool calls dynamically
if (message.isToolCall) {
    for (final toolCall in message.toolCalls) {
      print('Tool call: ${toolCall.functionName}');
      final retrieveWeatherInBoston = chat.getToolCallable(toolCall);
      print('Weather result: ${retrieveWeatherInBoston()}');
    }
  }
```

- `weatherTool` specifies the `get_weather` function, requiring a location parameter and an optional `units` parameter, which can only have specific values or null.
- The `registerTool` method adds the tool to the chat, making it available for invocation.
- When the model makes a tool call (`isToolCall` is true), retrieve the callable function using `chat.getToolCallable` and execute it as you want.

The output of the above example should look something like this:

```yaml
Tool call: get_weather
Weather result: {location: Boston, temperature: 22, units: metric}
Tool call: get_weather
Weather result: {location: Boston, temperature: 71.6, units: imperial}
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
  final (transcriptionResult, rateLimitInformation) = await groq.transcribeAudio(
    filePath: './path/to/your/audio.mp3', // Adjust file path as needed
  );
  print(transcriptionResult.text); // The transcribed text
} on GroqException catch (e) {
  print('Error transcribing audio: $e');
}
```

### Content Moderation

Easily check if a text is harmful using the isTextHarmful method. It analyzes the text and returns whether it's harmful, the harmful category, and usage details.

```dart
final (isHarmful, harmfulCategory, usage, rateLimit) = await groq.isTextHarmful(
  text: 'YOUR_TEXT',
);

if (isHarmful) {
  print('Harmful content detected: $harmfulCategory');
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
static const String llama31_70b_versatile = 'llama-3.1-70b-versatile';
static const String llama31_8b_instant = 'llama-3.1-8b-instant';
static const String llama3_groq_70b_tool_use_preview =
    'llama3-groq-70b-8192-tool-use-preview';
static const String llama3_groq_8b_tool_use_preview =
    'llama3-groq-8b-8192-tool-use-preview';
static const String llama_guard_3_8b = 'llama-guard-3-8b';
```

You can use these constants directly when starting a new chat or switching models:

```dart
final chat = groq.startNewChat(GroqModels.mixtral8_7b);
```

## Chat Settings

| Parameter                     | Description                                                                                                                             | Default |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | :-----: |
| maxConversationalMemoryLength | The number of previous messages to include in the context for the model's response. Higher values provide more context-aware responses. |  1024   |
| temperature                   | Controls the randomness of responses (0.0 - deterministic, 2.0 - very random).                                                          |   1.0   |
| maxTokens                     | Maximum number of tokens allowed in the generated response.                                                                             |  8192   |
| topP                          | Controls the nucleus sampling probability mass (0.0 - narrow focus, 1.0 - consider all options).                                        |   1.0   |
| stop                          | Optional stop sequence(s) to terminate response generation.                                                                             |  null   |

## Important Notes:

- Replace `"YOUR_GROQ_API_KEY"` with your actual Groq API key, obtained from the Groq Cloud console: https://console.groq.com/keys
- The Groq Cloud console is your central hub for managing API keys, exploring documentation, and accessing other Groq Cloud features: https://console.groq.com/
- Multiple choices in GroqResponses are not supported yet.

## Contributors

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/m41w4r3exe"><img src="https://avatars.githubusercontent.com/u/33025255?v=4?s=100" width="100px;" alt="m41w4r3exe"/><br /><sub><b>m41w4r3exe</b></sub></a><br /><a href="#bug-m41w4r3exe" title="Bug reports">🐛</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://allcontributors.org/) specification. Contributions of any kind welcome!
