import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'painting/filter_renderer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final noise = await createNoiseImage();
  runApp(MangcutApp(noise: noise));
}
