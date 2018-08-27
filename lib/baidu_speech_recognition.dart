import 'dart:async';

import 'package:flutter/services.dart';

class BaiduSpeechRecognition {

  Stream<String> _onVoiceRecognitionCallback;

  static const MethodChannel _channel =
      const MethodChannel('baidu_speech_channel');

  static const EventChannel _callback =
    const EventChannel('baidu_speech_callback');

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<String> init() => _channel.invokeMethod('speechInit').then((result) => result);

  Future<String> start() => _channel.invokeMethod('speechStart').then((result) => result);

  Future<String> startLongSpeech() => _channel.invokeMethod('speechStartLong').then((result) => result);

  Future<String> stop() => _channel.invokeMethod('speechStop').then((result) => result);

  Future<String> cancel() => _channel.invokeMethod('speechCancel').then((result) => result);

  // 语音 识别 回调函数
  Stream<String> onVoiceRecognition() {

    if (_onVoiceRecognitionCallback == null) {

      _onVoiceRecognitionCallback = _callback
          .receiveBroadcastStream()
          .map((result) => result);

    }

    return _onVoiceRecognitionCallback;

  }
}
