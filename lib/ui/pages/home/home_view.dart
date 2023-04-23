import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pub_feed/ui/pages/home/widgets/HomeAppBar.dart';

import 'home_provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => HomeProvider(),
      builder: (context, child) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final provider = context.read<HomeProvider>();
    return Scaffold(
      appBar: HomeAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: TextField(controller: provider.textEditingController,onSubmitted: (s)=>provider.detectWeibo(),),
      ),
    );
  }
}
