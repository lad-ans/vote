import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as _io;
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus {
  online, offline, connecting
}

class SocketService with ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.connecting;

  ServerStatus get serverStatus => _serverStatus;

  _io.Socket? _socket;

  _io.Socket get socket => _socket!;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    
    try {

      _socket = _io.io('http://192.168.1.101:3000',
        OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
        );

      _socket!.onConnect((_) {
        _serverStatus = ServerStatus.online;
        notifyListeners();
      });

      _socket!.onDisconnect((_) {
        _serverStatus = ServerStatus.offline;
        notifyListeners();
      });

    } catch (e) {
      e;
    }
  
  }
}