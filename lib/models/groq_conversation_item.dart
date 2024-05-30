import 'package:groq_sdk/models/groq_message.dart';
import 'package:groq_sdk/models/groq_response.dart';
import 'package:groq_sdk/models/groq_usage.dart';

class GroqConversationItem {
  final String _model;
  final GroqMessage _request;
  GroqResponse? response;
  GroqUsage? usage;

  GroqConversationItem(this._model, this._request);

  String get model => _model;

  GroqMessage get request => _request;

  void setResponse(GroqResponse response, GroqUsage usage) {
    this.response = response;
    this.usage = usage;
  }

  void setResponseFromJson(Map<String, dynamic> json) {
    response = GroqResponse.fromJson(json);
    usage = GroqUsage.fromJson(json);
  }
}
