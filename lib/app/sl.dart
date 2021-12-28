import 'package:get_it/get_it.dart';

import 'services/socket_service.dart';

class SL {
  
  static final GetIt getIt = GetIt.instance;

  static void init() {
    getIt.registerSingleton<SocketService>(
      SocketService(), 
      dispose: (value) async {
        value.dispose();
      },
    );
  }
}