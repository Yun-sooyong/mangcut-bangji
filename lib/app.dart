import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'screens/camera_screen.dart';

class MangcutApp extends StatelessWidget {
  const MangcutApp({super.key, required this.noise});

  final ui.Image? noise;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '망컷방지',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      home: CameraScreen(noise: noise),
    );
  }
}
