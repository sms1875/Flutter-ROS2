class Service {
  final String name;

  Service({required this.name});

  Map<String, dynamic> callService(Map<String, dynamic> args) {
    return {
      "op": "call_service",
      "service": name,
      "args": args,
    };
  }
}

class Topic {
  final String name;
  final String messageType;

  Topic({required this.name, required this.messageType});

  Map<String, dynamic> publishMessage(Map<String, dynamic> msg) {
    return {
      "op": "publish",
      "topic": name,
      "msg": msg,
    };
  }
}
