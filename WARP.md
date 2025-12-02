# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is the **Groq Dart SDK** - an independent Dart/Flutter library for interacting with the Groq Cloud API. The SDK provides seamless integration with Groq's fast Large Language Models (LLMs), audio transcription, content moderation, and tool usage capabilities.

**Important**: This is not an official Groq package but an independent community project.

## Architecture

### Core Components

- **`Groq`** (`lib/models/groq.dart`) - Main SDK entry point, handles API key management and creates chat instances
- **`GroqChat`** (`lib/models/groq_chat.dart`) - Manages conversational sessions with streaming support, tool registration, and message history
- **`GroqApi`** (`lib/models/groq_api.dart`) - Low-level API wrapper for HTTP communication with Groq services
- **`GroqChatSettings`** - Configuration for chat behavior (temperature, tokens, memory length)

### Key Features Architecture

1. **Chat System**: Event-driven with `StreamController` for real-time message streaming
2. **Tool System**: Dynamic function registration allowing models to call external functions
3. **Memory Management**: Configurable conversational memory with token-aware truncation
4. **Multi-modal Support**: Text chat, audio transcription/translation, content moderation

### Data Flow

```
User → GroqChat.sendMessage() → GroqApi → Groq Cloud API
                    ↓
RequestChatEvent → Stream → ResponseChatEvent
```

## Development Commands

### Setup
```bash
dart pub get                    # Install dependencies
```

### Development
```bash
dart format .                   # Format code
dart analyze                    # Static analysis
dart test                       # Run all tests
dart test test/groq_test.dart   # Run specific test file
```

### Testing
- Tests require `GROQ_API_KEY` environment variable
- Audio tests use `res/test.mp3` test file
- Tests cover model validation, chat functionality, and audio transcription

### CI/CD
- GitHub Actions CI runs on `stable`, `beta`, and `dev` Dart channels
- Automated format checking, analysis, and dependency caching
- Triggered on PRs to `master` branch

## Development Guidelines

### API Key Management
- All API keys should be handled securely via environment variables
- Never hardcode API keys in source code
- Use `Platform.environment['GROQ_API_KEY']` for tests
- API key can be `null` if your backend handles authentication to Groq

### Custom Base URL Support
- The SDK supports custom base URLs for proxies or alternative endpoints
- Default base URL: `https://api.groq.com/openai/v1`
- Set custom base URL via `Groq` constructor: `Groq('API_KEY', 'https://custom.api.com/openai/v1')`
- Can override per-operation using `customBaseUrl` parameter in methods like `startNewChat()`, `transcribeAudio()`, etc.
- For backend-authenticated scenarios: `Groq(null, 'https://your-backend.com/api/v1')`

### Error Handling
- Use `GroqException` for API-related errors with proper error codes and messages
- Implement proper validation in chat settings (temperature 0.0-2.0, positive tokens, etc.)
- Handle tool registration conflicts with assertions

### Streaming Architecture
- All chat interactions use `StreamController<ChatEvent>` for real-time updates
- Events are `RequestChatEvent` and `ResponseChatEvent`
- Always close streams with `dispose()` method

### Tool System
- Tools use `GroqToolItem` with parameter validation
- Function mapping requires proper serialization/deserialization
- Tool calls are validated before execution

### Model Constants
- Use `GroqModels` class constants instead of hardcoded model IDs
- Verify model availability with `canUseModel()` before use
- Support for text models, Whisper audio models, and Llama Guard moderation

### Memory Management
- `maxConversationalMemoryLength` controls context size
- Implement proper token counting for usage tracking
- Support message history serialization via `toJson()/fromJson()`

## Package Structure

- `lib/models/` - Core data models and API wrappers
- `lib/utils/` - Utility functions (auth, parsing)
- `lib/extensions/` - Dart extensions for JSON handling  
- `test/` - Test suites with API integration tests
- `example/` - Usage examples for chat and transcription