# Flutter Baidu Speech Recognition Plugin 

[![pub](https://img.shields.io/pub/v/baidu_speech_recognition.svg?style=flat-square)](https://pub.dartlang.org/packages/baidu_speech_recognition)

A speech recognition plugin for flutter using BaiduSDK.See the changelog for more information about the function.

## Getting Started

Add this to your package's pubspec.yaml file:
```yaml
dependencies:
    baidu_speech_recognition: 0.1.3
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
|ready|ready to speaking...|
|start|detect start speaking...|
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

Add **BDSClientResource/ASR/BDSClientResources** to your project group as "create folder references",

Add **BDSClientResource/ASR/BDSClientEASRResources** to your project group as "create groups".

Add the follow framework to your project:

| Framework | Desc |
| --------- | ---- |
| libc++.tbd | For c/c++ func support |
| libz.1.2.5.tbd | For gzip support |
| libsqlite3.0.tbd | For sqlite support |
| libiconv.2.4.0.tbd | Some utility |

Finally add Microphone Usage privacy to your info.plist file.

#### Project Setting
Open you project with xcode and go to Pods, select the baidu_speech_recognition TARGETS, then select the Build Settings Tab, Change Mach-O Type to **Static Library**.Then go to the Build Phases, make sure all the Headers are Public.

If you have any problem or Error Please make a [issue](https://github.com/soragui/flutter_baidu_speech_plugin/issues).


### For Android developer

First [become](https://ai.baidu.com/docs#/Begin/top) a baidu Developer

The Follow the [guide](https://ai.baidu.com/docs#/ASR-Android-SDK/55389ffa) to add some permission and file you need

