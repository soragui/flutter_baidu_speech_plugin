# Flutter Baidu Speech Recognition Plugin 

[![pub](https://img.shields.io/pub/v/baidu_speech_recognition.svg?style=flat-square)](https://pub.dartlang.org/packages/baidu_speech_recognition)

A speech recognition plugin for flutter using BaiduSDK.See the changelog for more information about the function.


## TODO

- [x] iOS support
- [ ] Android support

## Getting Started

Add this to your package's pubspec.yaml file:
```yaml
dependencies:
    baidu_speech_recognition: x.x.x
```

### Basic Usage

```dart
import 'package:baidu_speech_recognition_example/speech_app.dart';

BaiduSpeechRecognition _speechRecognition = BaiduSpeechRecognition();

// initialize 
_speechRecognition.init().then((value) => print(value));
 
// start long speech recognition 
 _speechRecognition.startLongSpeech().then((value) => print(value)); 

 // start speech recognition 60s long
 _speechRecognition.start().then((value) => print(value));  

// cancel recognition 
 _speechRecognition.cancel().then((value) => print(value));
  
```

### The Callback Listener
You can add a listener :
```dart
_speechRecognitoin.speechRecognitionEvents
      .listen((String value) {
        // TODO do somethig with the value
      }
```

The return value is a JSON String :
```json
{
  "type": "The recognition result type",
  "value": "The result"
}
```
the `type` have the following value:

| type | desc |
|---|---|
|start|start speaking...|
|stop|stop speaking. and return the last result|
|cancel|cancel the last recognition|
|finish|return the last recognition|
|lfinish|long speech return|
|end|end speaking...|
|meter|return volume meter level|

### For iOS developer
Go to [百度ASR](http://ai.baidu.com/sdk#asr) download SDK for iOS,then copy BDSClientLib and BDSClientResource to the same directory of you flutter project,the file structure like this:
```bash
----------------
  |
  |--Your FLutter Projcet/
  |
  |--BDSClientLib/
  |
  |--BDSCLientResource/
```

Then open your iOS projcet on Xcode and add the baidu speech SDK library and some resource.

Add **BDSClientLib/libBaiduSpeechSDK.a** to you project group as "create groups",

Add BDSClientResource/ASR/BDSClientResources to your project group as "create folder references",

Add BDSClientResource/ASR/BDSClientEASRResources to your project group as "create groups".

Add the follow framework to your project:

| Framework | Desc |
| --------- | ---- |
| libc++.tbd | For c/c++ func support |
| libz.1.2.5.tbd | For gzip support |
| libsqlite3.0.tbd | For sqlite support |
| libiconv.2.4.0.tbd | Some utility |

Finally add Microphone Usage privacy to your info.plist file.
