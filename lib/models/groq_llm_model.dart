//These are deprecated

// ignore_for_file: constant_identifier_names

@Deprecated('Use GroqModels.mixtral8_7b instead')
const String mixtral8_7b = 'mixtral-8x7b-32768';
@Deprecated('Use GroqModels.gemma_7b instead')
const String gemma_7b = 'gemma-7b-it';
@Deprecated('Use GroqModels.llama3_8b instead')
const String llama3_8b = 'llama3-8b-8192';
@Deprecated('Use GroqModels.llama3_70b instead')
const String llama3_70b = 'llama3-70b-8192';
@Deprecated('Use GroqModels.whisper_large_v3 instead')
const String whisper_large_v3 = 'whisper-large-v3';

///GroqModels holds a list of available models
class GroqModels {
  static const String whisper_large_v3 = 'whisper-large-v3';
  static const String distil_whisper_large_v3_en = 'distil-whisper-large-v3-en';
  static const String whisper_large_v3_turbo = 'whisper-large-v3-turbo';
  static const String mixtral8_7b = 'mixtral-8x7b-32768';
  static const String gemma_7b = 'gemma-7b-it';
  static const String gemma2_9b = 'gemma2-9b-it';
  static const String llama3_8b = 'llama3-8b-8192';
  static const String llama3_70b = 'llama3-70b-8192';
  static const String llama31_70b_versatile = 'llama-3.1-70b-versatile';
  static const String llama31_8b_instant = 'llama-3.1-8b-instant';
  static const String llama3_groq_70b_tool_use_preview =
      'llama3-groq-70b-8192-tool-use-preview';
  static const String llama3_groq_8b_tool_use_preview =
      'llama3-groq-8b-8192-tool-use-preview';
  static const String llama_guard_3_8b = 'llama-guard-3-8b';
  static const String llama_32_1b_preview = 'llama-3.2-1b-preview';
  static const String llama_32_3b_preview = 'llama-3.2-3b-preview';
  static const String llama_32_11b_vision_preview =
      'llama-3.2-11b-vision-preview';
  static const String llama_32_90b_vision_preview =
      'llama-3.2-90b-vision-preview';
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

enum GroqLlamaGuardCategory {
  violentCrime,
  nonViolentCrime,
  sexRelatedCrime,
  childSexualExploitation,
  defamation,
  specializedAdvice,
  privacy,
  intellectualProperty,
  indiscriminateWeapons,
  hate,
  selfHarm,
  sexualContent,
  elections,
  codeInterpreterAbuse,
}
