
import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:baidu_speech_recognition/baidu_speech_recognition.dart';

void main() => runApp(new MyApp());


class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => new _MyAppState();

}

enum MenuItem { longSpeech }

const String START = 'Speaking ...';
const String STOP  = 'Tap To Speaking ...';

class _MyAppState extends State<MyApp> {


  Map<String, dynamic> _recResult;

  BaiduSpeechRecognition _speechRecognition = BaiduSpeechRecognition();
  ScrollController _controller = ScrollController();

  bool isStart = false;
  bool isLongSpeech = false;
  
  List<String> results = List();

  int meterLevel = 0;
  int iconNum = 0;

  //StreamSubscription<dynamic> _speechEvents;
  String status = STOP;

  final List<String> icons = <String>[

    'assets/images/meter_level_0.png',
    'assets/images/meter_level_1.png',
    'assets/images/meter_level_2.png',
    'assets/images/meter_level_3.png',
    'assets/images/meter_level_4.png',
    'assets/images/meter_level_5.png',
    'assets/images/meter_level_6.png',

  ];


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
  
  Widget _buildRecognitionResultItem(BuildContext context, int index) {
    
    return Column(

        crossAxisAlignment: CrossAxisAlignment.end,

        children: <Widget>[

          Container(

            margin: EdgeInsets.all(5.0),
            padding: EdgeInsets.all(5.0),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              color: Colors.blue
            ),

            child: Text(
                results[index]
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
      status = START;

    } else {

      _speechRecognition.stop().then((value) => print(value));
      isStart = false;
      status = STOP;

    }

    setState(() {

    });

  }

  _onLongSpeechChange(bool value) {

    setState(() {
      isLongSpeech = value;
    });

  }

  _changeVoiceIconNumber() {

    print('Meter Level :$meterLevel');

    if (meterLevel <= 0) {
      iconNum = 0;
    } else if (meterLevel <= 4) {
      iconNum = 1;
    } else if (meterLevel <= 20) {
      iconNum = 2;
    } else if (meterLevel <= 36) {
      iconNum = 3;
    } else if (meterLevel <= 52) {
      iconNum = 4;
    } else if (meterLevel <= 68) {
      iconNum = 5;
    } else {
      iconNum = 6;
    }

  }

  @override
  void initState() {
    super.initState();

    // 初始化
    _speechRecognition.init().then((value) => print(value));

    _speechRecognition.speechRecognitionEvents
      .listen((String value) {

        if (value != null) {

        _recResult = jsonDecode(value);
        print(_recResult);

          setState(() {

            switch (_recResult['type']) {
              case 'meter':
                //print('${_recResult['value']['volume-percent']}');
                Theme.of(context).platform == TargetPlatform.android ?
                    meterLevel = _recResult['value']['volume'] :
                    meterLevel = _recResult['value'];
                break;
              case 'ready':
                status = 'ready...';
                break;
              case 'start':
                status = START;
                break;
              case 'finish':
                print(_recResult['value']['results_recognition'][0]);
                results.add(_recResult['value']['results_recognition'][0]);
                _controller.jumpTo(
                  _controller.position.maxScrollExtent
                );
                isStart = false;
                status = STOP;
                meterLevel = 0;
                break;
              case 'lfinish':
                results.add(_recResult['value']['results_recognition'][0]);
                //isStart = false;
                meterLevel = 0;
                break;
              case 'end':
                meterLevel = 0;
                status = STOP;
                isStart = false;
                break;
              default:
                print(_recResult);
                break;
            }

            _changeVoiceIconNumber();

          });
        }

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

                Expanded(child: ListView.builder(
                  controller: _controller,
                  itemBuilder: _buildRecognitionResultItem,
                  itemCount: results.length,
                  //reverse: true,

                )),

                Container(height: 4.0),

                Material(

                   elevation: 3.0,
                   borderRadius: BorderRadius.all(Radius.circular(4.0)),
                   child: IconButton(
                     onPressed: _startSpeechRecognition,

                     icon: Image(image: AssetImage(icons[iconNum])),
                     //color: Colors.blue,
                     tooltip: 'tap to speaking....',

                   ),

                ),

                Padding(
                  
                  padding: EdgeInsets.all(10.0),
                  
                  child: Text(

                      status

                  ),
                  
                )
                ,

              ],

            )
        ),
      ),
    );
  }
}

