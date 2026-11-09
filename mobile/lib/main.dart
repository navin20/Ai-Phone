import 'package:flutter/material.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ai Phone',
      home: const MyHomePage(title: 'Ai Phone'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.purple),
      body: Center(
      
              child: MJPEGStreamScreen(streamUrl: "http://localhost:8000/video_test", showLiveIcon: false, fit:BoxFit.cover,height:1000.0,width: 1000.0,),
        ),
      );
  }
}
