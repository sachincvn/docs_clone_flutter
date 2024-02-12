import 'package:docs_clone_flutter/common/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  io.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = io.io(Constants.apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoconnect': false,
    });

    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}
