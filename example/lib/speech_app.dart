
import 'package:flutter/material.dart';

import 'package:baidu_speech_recognition/baidu_speech_recognition.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => new _MyAppState();

}

enum MenuItem { longSpeech }

class _MyAppState extends State<MyApp> {


  String _recResult;

  StreamSubscription<String> _recCallback;

  BaiduSpeechRecognition _speechRecognition = BaiduSpeechRecognition();

  bool isStart = false;
  bool isLongSpeech = false;

  Widget _buildPopupMenu() {
    return new PopupMenuButton<MenuItem>(
      onSelected: (MenuItem result) async {
        switch (result) {
          case MenuItem.longSpeech:
            _onLongSpeechChange(!isLongSpeech);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
         PopupMenuItem<MenuItem>(
          value: MenuItem.longSpeech,
          child: Row(
            children: <Widget>[
              Checkbox(
                value: isLongSpeech,
                onChanged: _onLongSpeechChange,
              ),

              Text('长语音识别'),
            ],
          ),
        )
      ],
    );
  }

  _startSpeechRecognition() {

    if (!isStart) {

      if (isLongSpeech) {
        _speechRecognition.startLongSpeech().then((value) => print(value));
      } else {
        _speechRecognition.start().then((value) => print(value));
      }
      isStart = true;

    } else {

      _speechRecognition.cancel().then((value) => print(value));
      isStart = false;

    }

    setState(() {

    });

  }

  _onLongSpeechChange(bool value) {

    setState(() {
      isLongSpeech = value;
    });

  }

  @override
  void initState() {
    super.initState();

    // 初始化
    _speechRecognition.init().then((value) => print(value));

    _recCallback = _speechRecognition.onVoiceRecognition()
      .listen((String result) {

        setState(() {
          if (result != null) {
            _recResult = result;
            print(_recResult);
          }
        });

    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(

          title: const Text('Baidu Speech Plugin'),

          actions: <Widget>[

            _buildPopupMenu()

          ],


        ),

        body: new Container(

          padding: EdgeInsets.all(10.0),

          child:  Column(

            children: <Widget>[

              Expanded(child: Container()),

              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: _startSpeechRecognition,
                  child: Text(
                    isStart ? '取消' : '开始',
                  ),
                ),
              )

            ],

          )
        ),
      ),
    );
  }
}