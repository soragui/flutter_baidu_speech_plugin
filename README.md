# Flutter Baidu Speech Recognition Plugin 

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


String _recResult;
StreamSubscription<String> _recCallback;
BaiduSpeechRecognition _speechRecognition = BaiduSpeechRecognition();

// initialize 
_speechRecognition.init().then((value) => print(value));

// For speech recognition result callback 
_recCallback = _speechRecognition.onVoiceRecognition()
      .listen((String result) {

        setState(() {
          if (result != null) {
            _recResult = result;
            print(_recResult);
          }
        });

});

// start long speech recognition 
 _speechRecognition.startLongSpeech().then((value) => print(value)); 

 // start speech recognition 60s long
 _speechRecognition.start().then((value) => print(value));  

// cancel recognition 
 _speechRecognition.cancel().then((value) => print(value));

```

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
