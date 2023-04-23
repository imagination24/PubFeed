/*
Time:2023/4/17
Description:
Author:
*/
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pub_feed/ui/pages/home/home_view.dart';

class RouterPath{
  static const home = "/Home";
}

class Routers {

  static final GoRouter router = GoRouter(
      initialLocation: RouterPath.home,
      routes: [
        GoRoute(path: RouterPath.home,builder: (BuildContext context,GoRouterState state)=>HomePage())
      ]);
}