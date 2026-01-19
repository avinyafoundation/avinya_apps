import 'dart:convert';
import 'package:gallery/avinya/maintenance/lib/services/api_key.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiTranslator {
  // 1. FIXED: Use a 2026 stable model name
  static final _model = GenerativeModel(
    model: 'gemini-2.0-flash-lite', // Highest free quota for 2026
    apiKey: ApiKey.googleGenerativeAIKey,
  );

  static final Map<String, String> _cache = {};
  static bool _isBatching = false;

  // This method now safely waits if a batch is already running
  static Future<String> translate(String text) async {
    if (text.isEmpty) return "";

    // 1. Check Cache first
    if (_cache.containsKey(text)) return _cache[text]!;

    // 2. If it's not in cache and we aren't batching,
    // it means this card was missed. Fallback to individual (carefully).
    try {
      final prompt = "Translate to simple Sinhala: $text";
      final response = await _model.generateContent([Content.text(prompt)]);
      final result = response.text ?? text;
      _cache[text] = result;
      return result;
    } catch (e) {
      return text;
    }
  }

  static Future<void> translateBatch(List<String> texts) async {
    // 1. IMPROVED FILTER: Only translate what we truly don't have.
    final textsToTranslate = texts
        .where((t) => t.trim().isNotEmpty && !_cache.containsKey(t))
        .toSet() // Removes duplicate titles
        .toList();

    // 2. IF CACHE IS FULL, STOP IMMEDIATELY.
    // This prevents the API from being hit during a screen refresh.
    if (textsToTranslate.isEmpty) {
      print("Gemini: All items found in cache. 0 API calls made.");
      return;
    }

    // 3. Batch is running
    _isBatching = true;
    print("Gemini: Sending batch of ${textsToTranslate.length} items...");

    final prompt = """
      Act as a professional translator localizing content for maintenance workers in Sri Lanka.

      TASK:
      Translate the following list of maintenance tasks into colloquial, spoken Sinhala (as used in daily conversation).

      GUIDELINES:
      1. Tone: Informal and direct. Avoid bookish/formal words (e.g., use 'හදන්න' instead of 'ප්‍රතිසංස්කරණය කරන්න').
      2. Technical Terms: Keep common English terms as-is or transliterate them if they are used locally (e.g., 'AC', 'Generator', 'Washroom', 'Sink', 'Lift').
      3. Format: Return ONLY a valid JSON object where the keys are the original English strings and the values are the Sinhala translations.
      4. Do not use any English letters in translated words.

      EXAMPLES:
      - "Fix the leak in the washroom" -> "වොෂ් රූම් එකේ වතුර ලීක් එක හදන්න"
      - "AC is not cooling" -> "AC එක සීතල වෙන්නේ නෑ"
      - "Repair the broken sink" -> "කැඩිච්ච සින්ක් එක හදන්න"

      TEXTS TO TRANSLATE:
      ${jsonEncode(textsToTranslate)}
      """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;
      if (responseText == null) return;

      final cleanJson =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> translations = jsonDecode(cleanJson);

      translations.forEach((key, value) {
        _cache[key] = value.toString();
      });
    } catch (e) {
      print("Batch Error: $e");
    } finally {
      _isBatching = false;
    }
  }

  static String getCachedTranslation(String text) {
    return _cache[text] ?? text;
  }
}
