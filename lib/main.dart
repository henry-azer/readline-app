import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await di.init();
  
  runApp(
    MultiProvider(
      providers: di.providers,
      child: const ReadItApp(),
    ),
  );
}
