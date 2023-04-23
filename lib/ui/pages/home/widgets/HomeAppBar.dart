/*
Time:2023/4/20
Description:
Author:
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget{
  final height = 60.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 24,right: 24,top: MediaQuery.of(context).padding.top),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor
      ),
      child: Row(
        children: [
          Image.asset("assets/icon/RSS.png",width: 30,),
          const SizedBox(width: 10),
          Text("PubFeed",style: Theme.of(context).textTheme.titleLarge)
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>  Size.fromHeight(height);

}