import 'package:dio/dio.dart';

class TelegramService {
  static Future<bool> sendDirectAlert({
    required String botToken,
    required String chatId,
    required String message,
  }) async {
    try {
      final dio = Dio();
      final url = 'https://api.telegram.org/bot$botToken/sendMessage';
      final response = await dio.post(url, data: {
        'chat_id': chatId,
        'text': message,
        'parse_mode': 'HTML',
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

