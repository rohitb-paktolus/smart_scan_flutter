import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class OcrProcessor {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final Dio _dio = Dio();

  late final String _geminiApiKey;

  static const String _modelId = "gemini-2.5-flash";
  static const String _apiEndpoint =
      "https://generativelanguage.googleapis.com/v1beta/models";

  OcrProcessor() {
    _geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND';

    _dio.options.baseUrl = _apiEndpoint;

    if (kDebugMode && _geminiApiKey == "API_KEY_NOT_FOUND") {
      print("CRITICAL: GEMINI_API_KEY not found in .env or not loaded.");
    }
  }

  // Future<Map<String, String>>
  Future<Map<String, String>> performOcrAndExtractFields(
    Uint8List imageBytes,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/ocr_image_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await tempFile.writeAsBytes(imageBytes);

    final inputImage = InputImage.fromFilePath(tempFile.path);

    final recognizedText = await _textRecognizer.processImage(inputImage);
    await _textRecognizer.close();

    await tempFile.delete();

    // return recognizedText.text;

    return _parseReceiptDataWithGemini(recognizedText.text);
  }

  Future<Map<String, String>> _parseReceiptDataWithGemini(
    String rawText,
  ) async {
    // Ensure the key is available before making the request
    if (_geminiApiKey == "API_KEY_NOT_FOUND") {
      return {
        "Vendor Name": "API Key Error",
        "Total Amount": "N/A",
        "Date": "N/A",
        "Category": "General",
      };
    }

    final url = "$_apiEndpoint/$_modelId:generateContent?key=$_geminiApiKey";

    // Note: 'generationConfig' is the correct field name for the REST API
    final jsonSchema = {
      "type": "object",
      "properties": {
        "vendor_name": {
          "type": "string",
          "description": "The name of the vendor.",
        },
        "total_amount": {
          "type": "string",
          "description": "The final total amount.",
        },
        "date": {
          "type": "string",
          "description": "The date of the transaction.",
        },
        "category": {
          "type": "string",
          "description":
              "The inferred category (e.g., Food, Groceries, Services).",
        },
      },
      "required": ["vendor_name", "total_amount", "date", "category"],
    };

    final requestBody = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": """
You are an expert receipt parser. Analyze the raw OCR text provided below.

1. Extract the required fields (vendor_name, total_amount, date).
2. For the 'all_data_points' array, you MUST itemize ALL other relevant data points found in the receipt (e.g., Subtotal, Tax, Tip, Address, etc.) into separate {key: value} objects.
3. Return the result strictly as a JSON object that conforms to the provided schema.

Raw OCR Text:
---
$rawText
---
""",
            },
          ],
        },
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": jsonSchema,
      },
      "tools": [],
    };

    try {
      if (kDebugMode) print('Requesting Gemini API...');

      final response = await _dio.post(
        url,
        data: requestBody,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      // 4. Decode the response body
      final Map<String, dynamic> apiResponse = response.data;
      if (kDebugMode) print('Gemini API Response Received.');

      // Extract the JSON string from the nested response structure
      final String? jsonText =
          apiResponse["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]
              ?.trim();

      if (jsonText == null || jsonText.isEmpty) {
        throw Exception("Gemini returned no content.");
      }

      // 5. PROCESS THE NEW JSON STRUCTURE
      final Map<String, dynamic> rawJsonMap = jsonDecode(jsonText);
      final Map<String, String> finalResult = {
        // Map JSON keys to user-friendly display keys
        "Vendor Name":
            rawJsonMap['vendor_name']?.toString() ?? 'Scanned Document Vendor',
        "Total Amount": rawJsonMap['total_amount']?.toString() ?? 'N/A',
        "Date": rawJsonMap['date']?.toString() ?? 'N/A',
        "Category": rawJsonMap['category']?.toString() ?? 'General',
      };

      return finalResult;
    } on DioException catch (e) {
      if (kDebugMode) {
        print("Gemini DIO Error: ${e.response?.statusCode} - ${e.message}");
        print("Gemini Response Body: ${e.response?.data}");
      }
      return {
        "Vendor Name": "OCR Failed (DIO Error)",
        "Total Amount": "N/A",
        "Date": "N/A",
        "Category": "General",
      };
    } catch (e) {
      if (kDebugMode) {
        print('General Parsing Error: $e');
      }
      return {
        "Vendor Name": "OCR Failed (Unknown Error)",
        "Total Amount": "N/A",
        "Date": "N/A",
        "Category": "General",
      };
    }
  }

  String _toTitleCase(String snakeCase) {
    if (snakeCase.isEmpty) return snakeCase;

    // 1. Replace underscores with spaces
    final spaced = snakeCase.replaceAll('_', ' ');

    // 2. Capitalize the first letter of each word
    return spaced
        .split(' ')
        .where(
          (word) => word.isNotEmpty,
        ) // Filter out multiple spaces resulting in empty strings
        .map((word) {
          // Capitalize the first letter and keep the rest lowercased
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
