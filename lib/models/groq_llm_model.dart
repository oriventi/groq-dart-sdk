const String mixtral8_7b = 'mixtral-8x7b-32768';
const String gemma_7b = 'gemma-7b-it';
const String llama3_8b = 'llama3-8b-8192';
const String llama3_70b = 'llama3-70b-8192';
// ignore: constant_identifier_names
const String whisper_large_v3 = 'whisper-large-v3';

class GroqLLMModel {
  final String modelId;
  final String ownedBy;
  final bool isCurrentlyActive;
  final int contextWindow;

  GroqLLMModel({
    required this.modelId,
    required this.ownedBy,
    required this.isCurrentlyActive,
    required this.contextWindow,
  });

  @override
  String toString() {
    return 'GroqLLMModel{modelId: $modelId, ownedBy: $ownedBy, isCurrentlyActive: $isCurrentlyActive, contextWindow: $contextWindow}';
  }
}
