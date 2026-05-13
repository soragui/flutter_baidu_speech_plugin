# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Analyze the Dart code
dart analyze lib/

# Analyze with the example
cd example && dart analyze lib/

# Format Dart code
dart format lib/

# Run the example app (connect a device/emulator first)
cd example && flutter run
```

There are no tests in this repository.

## Architecture

This is a Flutter plugin that wraps the Baidu Speech Recognition SDK (Android + iOS). It follows the standard Flutter plugin channel pattern:

**Dart API** (`lib/baidu_speech_recognition.dart`):
- Single class `BaiduSpeechRecognition` — the entire public API surface
- All commands go through a `MethodChannel` named `baidu_speech_channel`
- Recognition results/events stream back through an `EventChannel` named `baidu_speech_callback`
- The stream emits JSON strings with `type` (event name) and `value` (payload)
- Event types: `ready`, `start`, `stop`, `cancel`, `finish`, `lfinish`, `end`, `meter`

**Android** (`android/src/main/java/.../BaiduSpeechRecognitionPlugin.java`):
- Implements `MethodCallHandler`, `EventChannel.StreamHandler`, and Baidu's `EventListener`
- Uses Baidu SDK's `EventManager` (created via `EventManagerFactory.create(context, "asr")`)
- Sends ASR commands (`ASR_START`, `ASR_STOP`, `ASR_CANCEL`) with params as JSON
- The `onEvent` callback maps Baidu SDK event constants to the Dart event types
- Requires `bdasr_V3_20180801_d6f298a.jar` (in `android/libs/`) and native `.so` files (in example app's `jniLibs/`)

**iOS** (`ios/Classes/BaiduSpeechRecognitionPlugin.m`):
- Uses Baidu SDK's `BDSEventManager` with delegate callbacks
- Implements `VoiceRecognitionClientWorkStatus` delegate to receive recognition state changes
- Long speech mode sets `BDS_ASR_ENABLE_LONG_SPEECH` and `BDS_ASR_ENABLE_LOCAL_VAD`
- Requires manual SDK download from [Baidu AI](http://ai.baidu.com/sdk#asr) — copy `BDSClientLib/` and `BDSClientResource/` alongside the Flutter project

## Important notes

- The plugin uses the **deprecated v1 Flutter plugin API** (`PluginRegistry.Registrar` on Android, `registerWithRegistrar` on iOS). Upgrading to the v2 embedding would be a significant change.
- Dart SDK constraint: `>=3.0.0 <4.0.0`. Null safety is enabled.
- The iOS implementation contains **hardcoded Baidu API credentials** (API_KEY, SECRET_KEY, APP_ID at the top of the `.m` file). These should never be committed in a real project.
- No tests exist for any layer.
