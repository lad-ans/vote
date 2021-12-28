
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vote_app/app/services/socket_service.dart';

import 'pages/home_page.dart';

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SocketService>(
          create: (_) => SocketService(),
        )
      ],
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Material App',
          initialRoute: 'home',
          routes: {
            'home': (_) => const HomePage(),
          },
        );
      }
    );
  }
}