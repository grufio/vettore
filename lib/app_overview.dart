import 'package:flutter/material.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart';

class AppOverviewPage extends StatelessWidget {
  const AppOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: GrufioTabsAppBar(),
        body: Center(
          child: Text('App Content Area'),
        ),
      ),
    );
  }
}
