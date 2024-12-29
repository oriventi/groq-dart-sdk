import 'dart:io';

import 'package:groq_sdk/groq_sdk.dart';
import 'package:groq_sdk/models/groq_audio_response.dart';
import 'package:test/test.dart';

void main() {
  group('Groq Instance Tests', () {
    final String apiKey = Platform.environment['GROQ_API_KEY'] ?? '';
    final groq = Groq(apiKey);
    GroqLLMModel? gemmaModel;

    test('Get Model with gemma2', () async {
      final model = await groq.getModel(GroqModels.gemma2_9b);
      expect(model, isNotNull);
      expect(model.modelId, GroqModels.gemma2_9b);
      expect(model.contextWindow, 8192);
      expect(model.ownedBy, 'Google');
      gemmaModel = model;
    });
    test('Get Model with invalid Id', () async {
      expect(groq.getModel('invalid_id'), throwsException);
    });
    test('List Models', () async {
      final models = await groq.listModels();
      expect(models, isNotEmpty);
      expect(models.first, isA<GroqLLMModel>());
    });
    test('Can Use Model with gemma2', () async {
      final canUseModel = await groq.canUseModel(GroqModels.gemma2_9b);
      expect(canUseModel, gemmaModel!.isCurrentlyActive);
    });
    test('Can Use Model with invalid Id', () async {
      final canUseModel = await groq.canUseModel('invalid_id');
      expect(canUseModel, isFalse);
    });
    test('Start new Chat with gemma2', () async {
      final chat = groq.startNewChat(GroqModels.gemma2_9b);
      expect(chat, isNotNull);
      expect(chat.model, GroqModels.gemma2_9b);
      expect(chat.settings, GroqChatSettings.defaults());
    });
    test('Transcribe Audio', () async {
      final (audioResponse, rateLimitInfo) = await groq.transcribeAudio(
          audioFileUrl: 'res/test.mp3', modelId: GroqModels.whisper_large_v3);
      expect(audioResponse, isA<GroqAudioResponse>());
      expect(audioResponse.text.toLowerCase().contains('appointment'), isTrue);
      expect(rateLimitInfo, isA<GroqRateLimitInformation>());
    });
    test('Transcribe Audio with invalid model', () async {
      expect(
          groq.transcribeAudio(
              audioFileUrl: 'res/test.mp3', modelId: 'invalid_model'),
          throwsException);
    });
    test('Is Text harmful', () async {
      final (isHarmful, category, usage, rateLimit) =
          await groq.isTextHarmful(text: 'This is a test message');
      expect(isHarmful, isFalse);
      expect(category, isNull);
      expect(usage, isA<GroqUsage>());
      expect(rateLimit, isA<GroqRateLimitInformation>());
    });
  });
}
