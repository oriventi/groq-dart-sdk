//These are deprecated

@Deprecated('Use GroqModels.mixtral8_7b instead')
const String mixtral8_7b = 'mixtral-8x7b-32768';
@Deprecated('Use GroqModels.gemma_7b instead')
const String gemma_7b = 'gemma-7b-it';
@Deprecated('Use GroqModels.llama3_8b instead')
const String llama3_8b = 'llama3-8b-8192';
@Deprecated('Use GroqModels.llama3_70b instead')
const String llama3_70b = 'llama3-70b-8192';
@Deprecated('Use GroqModels.whisper_large_v3 instead')
// ignore: constant_identifier_names
const String whisper_large_v3 = 'whisper-large-v3';

///GroqModels holds a list of available models
class GroqModels {
  static const String mixtral8_7b = 'mixtral-8x7b-32768';
  static const String gemma_7b = 'gemma-7b-it';
  static const String gemma2_9b = 'gemma2-9b-it';
  static const String llama3_8b = 'llama3-8b-8192';
  static const String llama3_70b = 'llama3-70b-8192';
// ignore: constant_identifier_names
  static const String whisper_large_v3 = 'whisper-large-v3';
}

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
