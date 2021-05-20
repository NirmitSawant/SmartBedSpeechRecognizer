import 'dart:collection';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  String text = "Press the button and start speaking";
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, HighlightedWord> _highlights = {
      'eat': HighlightedWord(
        onTap: () => createAlertDialog(context, "Eating Mode"),
        textStyle: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
      'sleep': HighlightedWord(
        onTap: () => createAlertDialog(context, "Sleeping Mode"),
        textStyle: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      )
    };
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_off),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextHighlight(
            text: text,
            enableCaseSensitive: true,
            words: _highlights as LinkedHashMap<String, HighlightedWord>,
            textStyle: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}

createAlertDialog(BuildContext context, String title) {
  return showDialog(
      context: context,
      builder: (context) {
        bool manuallyClosed = false;
        Future.delayed(Duration(seconds: 20)).then((_) {
          if (!manuallyClosed) {
            Navigator.of(context).pop();
          }
        });
        if (title == "Eating Mode") {
          return AlertDialog(
            title: Text(title),
            content: Image.asset(
              "lib/assets/eatmode.gif",
              height: 400.0,
              width: 300.0,
            ),
          );
        } else {
          return AlertDialog(
            title: Text(title),
            content: Image.asset(
              "lib/assets/sleepmode.gif",
              height: 400.0,
              width: 300.0,
            ),
          );
        }
      });
}
