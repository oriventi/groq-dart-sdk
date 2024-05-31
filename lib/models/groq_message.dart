enum GroqMessageRole {
  system,
  user,
  assistant,
}

class GroqMessageRoleParser {
  static GroqMessageRole? tryParse(String role) {
    switch (role) {
      case 'system':
        return GroqMessageRole.system;
      case 'user':
        return GroqMessageRole.user;
      case 'assistant':
        return GroqMessageRole.assistant;
      default:
        return null;
    }
  }

  static String toId(GroqMessageRole role) {
    switch (role) {
      case GroqMessageRole.system:
        return 'system';
      case GroqMessageRole.user:
        return 'user';
      case GroqMessageRole.assistant:
        return 'assistant';
    }
  }
}

class GroqMessage {
  final String content;
  final String? username;
  final GroqMessageRole role;

  GroqMessage({
    required this.content,
    this.role = GroqMessageRole.user,
    this.username,
  });

  @override
  String toString() {
    return 'GroqMessage{content: $content, username: $username, role: $role}';
  }
}
