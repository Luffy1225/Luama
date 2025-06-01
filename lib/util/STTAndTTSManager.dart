import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class STTAndTTSManager {
  bool _isRecording = false;
  String _recognizedText = '';
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  // 對外通知辨識結果
  Function(String)? _onResultExternal;
  // 對外通知辨識狀態：listening / notListening / done
  Function(String)? _onStatusExternal;

  /// Getter for recognized text
  String get recognizedText => _recognizedText;

  /// Getter for recording state
  bool get isRecording => _isRecording;

  /// Constructor
  STTAndTTSManager() {
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  /// 設定狀態回呼（外部 UI 可透過此偵測 start/stop）
  void setOnStatusCallback(Function(String)? callback) {
    _onStatusExternal = callback;
  }

  /// 設定辨識文字回呼
  void setOnResultCallback(Function(String)? callback) {
    _onResultExternal = callback;
  }

  /// 初始化語音辨識模組
  Future<bool> init() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("語音狀態變化: $status");
        _isRecording = status == "listening"; // 自動更新狀態
        if (_onStatusExternal != null) {
          _onStatusExternal!(status);
        }
      },
      onError: (error) {
        print("語音辨識錯誤: $error");
        _isRecording = false;
        if (_onStatusExternal != null) {
          _onStatusExternal!("error");
        }
      },
    );

    if (!available) {
      print("語音辨識初始化失敗");
    }
    return available;
  }

  /// 開始語音辨識
  Future<void> startListening({String localeId = "zh-TW"}) async {
    await _flutterTts.stop();
    if (_isRecording) return;

    await _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        // 只有在最終結果才觸發 callback
        if (result.finalResult && _onResultExternal != null) {
          _onResultExternal!(_recognizedText);
        }
      },
      localeId: localeId,
    );
  }

  /// 停止語音辨識
  Future<void> stopListening() async {
    if (!_isRecording) return;
    await _speech.stop();
    _isRecording = false;
  }

  /// 說出指定文字
  Future<void> speak(String text) async {
    await _flutterTts.setLanguage("zh-TW");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  /// 說出指定文字
  Future<void> Stopspeak() async {
    await _flutterTts.stop();
  }

  /// 朗讀最後辨識文字
  Future<void> speakRecognizedText() async {
    if (_recognizedText.isNotEmpty) {
      await speak(_recognizedText);
    }
  }
}
