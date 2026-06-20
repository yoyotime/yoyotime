import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

Future<String?> showVoiceInputDialog(BuildContext context, {String hint = '请说话...'}) async {
  final speech = stt.SpeechToText();
  final available = await speech.initialize(
    onError: (_) {},
    onStatus: (_) {},
  );

  if (!available) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('语音识别不可用，请检查权限')),
    );
    return null;
  }

  if (!context.mounted) return null;

  String recognized = '';
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      speech.listen(
        onResult: (result) {
          recognized = result.recognizedWords;
        },
        localeId: 'zh_CN',
        listenFor: const Duration(seconds: 10),
      );

      return StatefulBuilder(
        builder: (context, setInnerState) {
          return AlertDialog(
            title: const Text('语音输入'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(hint),
                const SizedBox(height: 8),
                Text(
                  recognized.isEmpty ? '正在聆听...' : recognized,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await speech.stop();
                  if (ctx.mounted) Navigator.pop(ctx, recognized);
                },
                child: const Text('完成'),
              ),
            ],
          );
        },
      );
    },
  ).then((result) async {
    await speech.stop();
    return result;
  });
}
