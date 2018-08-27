import 'dart:async';

import 'package:flutter/services.dart';

class BaiduSpeechRecognition {

 /// Speech recognition callback stream
  Stream<String> _onVoiceRecognitionCallback;

/// Method channel for speech function
  static const MethodChannel _channel =
      const MethodChannel('baidu_speech_channel');

/// Event channel for speech recognition callback
  static const EventChannel _callback =
    const EventChannel('baidu_speech_callback');
 
  /// speech init function
  Future<String> init() => _channel.invokeMethod('speechInit').then((result) => result);
  
  /// start normal speech recognition
  Future<String> start() => _channel.invokeMethod('speechStart').then((result) => result);

  /// start long speech recognition
  Future<String> startLongSpeech() => _channel.invokeMethod('speechStartLong').then((result) => result);

  /// stop speech recognition
  Future<String> stop() => _channel.invokeMethod('speechStop').then((result) => result);

  /// cancel speech recognition
  Future<String> cancel() => _channel.invokeMethod('speechCancel').then((result) => result);

  // 语音 识别 回调函数
  /// For voice recognition status and result callback
  Stream<String> onVoiceRecognition() {

    if (_onVoiceRecognitionCallback == null) {

      _onVoiceRecognitionCallback = _callback
          .receiveBroadcastStream()
          .map((result) => result);

    }

    return _onVoiceRecognitionCallback;

  }
}
