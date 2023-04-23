/*
Time:2023/4/17
Description:
Author:
*/
import 'package:flutter/material.dart';
import 'package:pub_feed/router.dart';
import 'package:pub_feed/themes.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: Routers.router,
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeMode.system,
    );
  }
}
