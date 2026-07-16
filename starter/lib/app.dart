import 'package:flutter/material.dart';

class WorkerRestCalendarApp extends StatelessWidget {
  const WorkerRestCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '工作日历',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3478F6)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1116),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D96FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(child: Center(child: Text('工作日历 · Starter'))),
      ),
    );
  }
}
