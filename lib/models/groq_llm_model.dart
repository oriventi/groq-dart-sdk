const String mixtral8_7b = 'mixtral-8x7b-32768';
const String gemma_7b = 'gemma-7b-it';
const String llama3_8b = 'llama3-8b-8192';
const String llama3_70b = 'llama3-70b-8192';

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

  factory GroqLLMModel.fromJson(Map<String, dynamic> json) {
    try {
      return GroqLLMModel(
        modelId: json['id'] as String,
        ownedBy: json['owned_by'] as String,
        isCurrentlyActive: json['active'] as bool,
        contextWindow: json['context_window'] as int,
      );
    } catch (e) {
      throw Exception('Failed to load GroqLLMModel from JSON: $e');
    }
  }

  @override
  String toString() {
    return 'GroqLLMModel{modelId: $modelId, ownedBy: $ownedBy, isCurrentlyActive: $isCurrentlyActive, contextWindow: $contextWindow}';
  }
}
