import 'chatmsg.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

typedef MessageHandler = void Function(ChatMsg);

class MessageDispatcher {
  final Map<ServiceType, MessageHandler> _handlers = {};

  void registerHandler(ServiceType serviceType, MessageHandler handler) {
    _handlers[serviceType] = handler;
  }

  void unregisterHandler(ServiceType serviceType) {
    _handlers.remove(serviceType);
  }

  void dispatch(String jsonMessage) {
    try {
      final jsonData = jsonDecode(jsonMessage);
      final chatmsg = ChatMsg.fromJson(jsonData);
      final handler = _handlers[chatmsg.service];
      if (handler != null) {
        handler(chatmsg);
      } else {
        print("No handler for ${chatmsg.service}");
      }
    } catch (e) {
      print("Dispatcher parsing error: $e");
    }
  }
}

class MessageDispatcherProvider extends InheritedWidget {
  final MessageDispatcher dispatcher;

  const MessageDispatcherProvider({
    required this.dispatcher,
    required Widget child,
  }) : super(child: child);

  static MessageDispatcher of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<MessageDispatcherProvider>();
    assert(provider != null, 'No MessageDispatcherProvider found in context');
    return provider!.dispatcher;
  }

  @override
  bool updateShouldNotify(MessageDispatcherProvider oldWidget) {
    return oldWidget.dispatcher != dispatcher;
  }
}
