import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ChatRepository {
  final Dio _dio = Dio();

  String get _baseUrl {
    if (kIsWeb) throw Exception('Không hỗ trợ web');

    if (Platform.isAndroid) return 'http://10.0.2.2:5678';
    if (Platform.isIOS) return 'http://localhost:5678';
    return 'http://10.0.2.2:5678';
  }

  Future<Map<String, dynamic>> sendMessage({
    required String userId,
    required String message,
  }) async {
    try {
      http://localhost:5678/webhook/sos-request
      final url = '$_baseUrl/webhook/sos-request-2';

      print('📤 Gửi đến: $url');
      print('📄 Data: userId=$userId, message=$message');

      final response = await _dio.post(
        url,
        data: {
          'userId': userId,
          'message': message,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');
      print('📥 Response data type: ${response.data.runtimeType}');

      // Xử lý response null
      if (response.data == null) {
        throw N8nWorkflowError(
            'Workflow n8n trả về null. Có thể node "Window Buffer Memory" bị lỗi.\n'
                'Vui lòng kiểm tra workflow trong n8n.'
        );
      }

      // Xử lý response string rỗng
      if (response.data is String && response.data.isEmpty) {
        throw N8nWorkflowError('Workflow trả về response rỗng');
      }

      return _parseN8nResponse(response.data);

    } on DioException catch (e) {
      print('❌ Dio error: ${e.type} - ${e.message}');
      if (e.response != null) {
        print('❌ Response error: ${e.response!.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _parseN8nResponse(dynamic responseData) {
    try {
      print('🔍 Parsing response: $responseData');

      // Nếu response là null
      if (responseData == null) {
        throw N8nWorkflowError('Workflow trả về null response');
      }

      // Nếu là Map
      if (responseData is Map<String, dynamic>) {
        print('✅ Response là Map');

        // Kiểm tra có phải error từ n8n không
        if (responseData.containsKey('error')) {
          throw N8nWorkflowError(
              'Lỗi n8n workflow: ${responseData['error']}'
          );
        }

        // Kiểm tra có reply và isComplete không
        if (responseData.containsKey('reply') ||
            responseData.containsKey('isComplete')) {
          print('✅ Có reply/isComplete keys');
          return {
            'reply': responseData['reply'] ?? 'Đã nhận được phản hồi',
            'isComplete': responseData['isComplete'] ?? false,
            'dto': responseData['dto'] ?? {
              'Type': 'other',
              'Title': '',
              'Description': '',
              'Contact': '',
            },
          };
        }

        // Kiểm tra có output không (từ AI Agent)
        if (responseData.containsKey('output')) {
          print('✅ Có output key');
          return _parseOutputString(responseData['output'].toString());
        }

        // Nếu không có key nào quen thuộc, trả về nguyên data
        print('⚠️ Không có key quen thuộc, trả về nguyên data');
        return {
          'reply': 'Đã nhận phản hồi từ hệ thống',
          'isComplete': false,
          'dto': responseData,
        };
      }

      // Nếu là String
      if (responseData is String) {
        print('📝 Response là String');
        return _parseOutputString(responseData);
      }

      // Fallback cho các type khác
      print('⚠️ Response type không xác định: ${responseData.runtimeType}');
      return {
        'reply': 'Đã xử lý yêu cầu của bạn',
        'isComplete': false,
        'dto': null,
      };

    } catch (e) {
      print('❌ Parse error: $e');
      throw Exception('Lỗi parse response: $e');
    }
  }

  Map<String, dynamic> _parseOutputString(String output) {
    try {
      print('📄 Parse output string: $output');

      if (output.isEmpty) {
        return {
          'reply': 'Đã nhận được tin nhắn của bạn',
          'isComplete': false,
          'dto': null,
        };
      }

      // Tìm JSON trong output (format của AI Agent)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(output);

      if (jsonMatch != null) {
        try {
          final jsonStr = jsonMatch.group(0)!;
          print('📊 Found JSON: $jsonStr');

          final jsonData = json.decode(jsonStr);
          print('✅ Parsed JSON: $jsonData');

          final replyText = output.replaceAll(jsonStr, '').trim();

          return {
            'reply': replyText.isNotEmpty ? replyText : 'AI đã xử lý yêu cầu',
            'isComplete': jsonData['isComplete'] ?? false,
            'dto': {
              'Type': jsonData['Type'] ?? 'other',
              'Title': jsonData['Title'] ?? '',
              'Description': jsonData['Description'] ?? '',
              'Contact': jsonData['Contact'] ?? '',
            }
          };
        } catch (e) {
          print('❌ JSON parse error: $e');
          // Nếu không parse được JSON, vẫn trả về output
          return {
            'reply': output,
            'isComplete': false,
            'dto': null,
          };
        }
      }

      // Không có JSON, trả về output nguyên bản
      return {
        'reply': output,
        'isComplete': false,
        'dto': null,
      };

    } catch (e) {
      print('❌ Output parse error: $e');
      return {
        'reply': 'Đã có lỗi xử lý phản hồi',
        'isComplete': false,
        'dto': null,
      };
    }
  }
}

// Custom exception cho lỗi n8n workflow
class N8nWorkflowError implements Exception {
  final String message;
  N8nWorkflowError(this.message);

  @override
  String toString() => message;
}