package com.kinezhou.baiduspeechrecognition;

import android.content.Context;
import android.util.Log;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.baidu.speech.EventListener;
import com.baidu.speech.EventManager;
import com.baidu.speech.EventManagerFactory;
import com.baidu.speech.asr.SpeechConstant;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.LinkedHashMap;
import java.util.Map;

/** BaiduSpeechRecognitionPlugin */
public class BaiduSpeechRecognitionPlugin implements MethodCallHandler ,
        EventChannel.StreamHandler, EventListener{
  /** Plugin registration. */

  private static final String TAG = "CALLBACK";

  private static final String METHOD_CHANNEL_NAME = "baidu_speech_channel";
  private static final String STREAM_CHANNEL_NAME = "baidu_speech_callback";

  private static final String SPEECH_INIT_METHOD = "speechInit";
  private static final String SPEECH_LONG_METHOD = "speechStartLong";
  private static final String SPEECH_START_METHOD = "speechStart";
  private static final String SPEECH_STOP_METHOD = "speechStop";
  private static final String SPEECH_CANCEL_METHOD = "speechCancel";

  private Map<String, Object> params = new LinkedHashMap<>();
  private Map<String, Object> result = new LinkedHashMap<>();

  private EventManager asr;
  private EventSink eventSink;
  private EventListener eventListener;

  private BaiduSpeechRecognitionPlugin(Context context) {

    asr = EventManagerFactory.create(context, "asr");
    asr.registerListener(this);

  }

  public static void registerWith(Registrar registrar) {

      // Using the same plugin instance ...
      BaiduSpeechRecognitionPlugin plugin = new BaiduSpeechRecognitionPlugin(registrar.context());

      final MethodChannel channel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL_NAME);
      channel.setMethodCallHandler(plugin);

      final EventChannel callback = new EventChannel(registrar.messenger(), STREAM_CHANNEL_NAME);
      callback.setStreamHandler(plugin);

  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {

      switch (call.method) {

          case SPEECH_INIT_METHOD:
              init();
              result.success("speech.init call");
              break;
          case SPEECH_LONG_METHOD:
              startLongSpeech();
              result.success("speech.long call");
              break;
          case SPEECH_START_METHOD:
              start();
              result.success("speech.start call");
              break;
          case SPEECH_STOP_METHOD:
              stop();
              result.success("speech.stop call");
              break;
          case SPEECH_CANCEL_METHOD:
              cancel();
              result.success("speech.cancel call");
              break;

          default:
              result.notImplemented();
              break;

      }

  }

  /**
   *  百度 语音 识别 Flutter Plugin API
   */

  private void init() {


  }

  private void start() {

    String event = SpeechConstant.ASR_START; // 替换成测试的event

    params.put(SpeechConstant.ACCEPT_AUDIO_VOLUME, true);
    params.put(SpeechConstant.NLU, "enable");
    params.put(SpeechConstant.VAD, SpeechConstant.VAD_DNN);
    params.put(SpeechConstant.PROP ,20000);
    params.put(SpeechConstant.PID, 1537); // 中文输入法模型，有逗号

    String json  = new JSONObject(params).toString();

    asr.send(event, json, null, 0, 0);
  }

  private void startLongSpeech() {


    Map<String, Object> params = new LinkedHashMap<>();
    String event;
    event = SpeechConstant.ASR_START; // 替换成测试的event

    params.put(SpeechConstant.ACCEPT_AUDIO_VOLUME, true);

    params.put(SpeechConstant.NLU, "enable");
    params.put(SpeechConstant.VAD_ENDPOINT_TIMEOUT, 0); // 长语音
    params.put(SpeechConstant.VAD, SpeechConstant.VAD_DNN);
    params.put(SpeechConstant.PROP ,20000);
    params.put(SpeechConstant.PID, 1537); // 中文输入法模型，有逗号

    String json  = new JSONObject(params).toString(); // 这里可以替换成你需要测试的json

    asr.send(event, json, null, 0, 0);
  }

  /**
   *
   */
  private void stop() {
    asr.send(SpeechConstant.ASR_STOP, null, null, 0, 0); //
  }

  /**
   *
   */
  private void cancel() {
    asr.send(SpeechConstant.ASR_CANCEL, null, null, 0, 0); //
  }

  /**
   *  Stream handle 回调 函数
   * @param o
   * @param eventSink
   */
  @Override
  public void onListen(Object o, final EventSink eventSink) {
      Log.i(TAG, "onListen");
      //eventListener = createSpeechEventListener(eventSink);
      this.eventSink = eventSink;

  }

  @Override
  public void onCancel(Object o) {
    asr.unregisterListener(eventListener);
  }

  @Override
  public void onEvent(String name, String params, byte[] data, int offset, int length) {

      result.clear();

      switch (name) {

          case SpeechConstant.CALLBACK_EVENT_ASR_READY:
              Log.i(TAG, "Ready");
              result.put("type", "ready");
              eventSink.success(new JSONObject(result).toString());
              break;

          case SpeechConstant.CALLBACK_EVENT_ASR_BEGIN:
              Log.i("CALLBACK", "Begin");
              result.put("type", "start");
              eventSink.success(new JSONObject(result).toString());
              break;

          case SpeechConstant.CALLBACK_EVENT_ASR_CANCEL:
              Log.i(TAG, "Cancel");
              result.put("type", "cancel");
              eventSink.success(new JSONObject(result).toString());
              break;

          case SpeechConstant.CALLBACK_EVENT_ASR_EXIT:
              Log.i(TAG, "stop");
              eventSink.success(new JSONObject(result).toString());
              break;

          case SpeechConstant.CALLBACK_EVENT_ASR_END:
              Log.i(TAG, "End");
              result.put("type", "end");
              eventSink.success(new JSONObject(result).toString());
              break;
          case SpeechConstant.CALLBACK_EVENT_ASR_PARTIAL:
              Log.i("CALLBACK", params);
              result.put("type", "finish");
              try {
                  JSONObject json = new JSONObject(params);
                  result.put("value", json);
              } catch (JSONException e) {
                  e.printStackTrace();
              }
              eventSink.success(new JSONObject(result).toString());
              break;
          case SpeechConstant.CALLBACK_EVENT_ASR_FINISH:
              Log.i(TAG, "Finish");

              break;

          case SpeechConstant.CALLBACK_EVENT_ASR_LONG_SPEECH:
              Log.i(TAG, "LFinish");
              result.put("type", "lfinish");

              eventSink.success(new JSONObject(result).toString());

          case SpeechConstant.CALLBACK_EVENT_ASR_VOLUME:
              Log.i(TAG, "onVolume");
              result.put("type", "meter");
              try {
                  JSONObject json = new JSONObject(params);
                  result.put("value", json);
              } catch (JSONException e) {
                  e.printStackTrace();
              }
              eventSink.success(new JSONObject(result).toString());
              break;
          default:
              eventSink.success("DEFAULT:");
              break;
      }
  }

}
