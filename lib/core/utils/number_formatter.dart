import 'package:flutter/services.dart';

/// Parse angka format Indonesia maupun USD dengan return null jika kosong atau tidak valid
double? parseDecimalNullable(String value) {
  if (value.trim().isEmpty) return null;
  String cleaned = value.replaceAll('Rp', '').replaceAll('\$', '').replaceAll(' ', '').trim();
  if (cleaned.isEmpty) return null;

  if (cleaned.contains(',') && cleaned.contains('.')) {
    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');
    if (lastDot > lastComma) {
      cleaned = cleaned.replaceAll(',', '');
    } else {
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    }
  } else if (cleaned.contains(',')) {
    final parts = cleaned.split(',');
    if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
      cleaned = cleaned.replaceAll(',', '');
    } else {
      cleaned = cleaned.replaceAll(',', '.');
    }
  } else if (cleaned.contains('.')) {
    final parts = cleaned.split('.');
    if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
      cleaned = cleaned.replaceAll('.', '');
    }
  }

  return double.tryParse(cleaned);
}

/// Parse angka format Indonesia maupun USD (2,700.50 → 2700.50 atau 4.150,50 → 4150.50)
double parseDecimal(String value) {
  return parseDecimalNullable(value) ?? 0;
}

/// Format angka ke format Indonesia (IDR): pemisah ribuan titik (.), desimal koma (,)
String formatNumber(double value, {int decimals = 2}) {
  if (value.isNaN || value.isInfinite) return '0';
  final isNegative = value < 0;
  final absVal = value.abs();
  final str = absVal.toStringAsFixed(8);
  final parts = str.split('.');
  final integerPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  final decPart = decimals > 0 ? parts[1].substring(0, decimals.clamp(0, parts[1].length)) : '';
  final prefix = isNegative ? '-' : '';
  return decimals > 0 ? '$prefix$integerPart,$decPart' : '$prefix$integerPart';
}

/// Format angka ke format USD: pemisah ribuan koma (,), desimal titik (.)
String formatUsd(double value, {int decimals = 2}) {
  if (value.isNaN || value.isInfinite) return '0.00';
  final isNegative = value < 0;
  final absVal = value.abs();
  final str = absVal.toStringAsFixed(8);
  final parts = str.split('.');
  final integerPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  final decPart = decimals > 0 ? parts[1].substring(0, decimals.clamp(0, parts[1].length)) : '';
  final prefix = isNegative ? '-' : '';
  return decimals > 0 ? '$prefix$integerPart.$decPart' : '$prefix$integerPart';
}

/// Terjemahkan rekomendasi pivot ke Bahasa Indonesia
String formatRecommendation(String recommendation) {
  switch (recommendation) {
    case 'BUY':
      return 'BELI';
    case 'SELL':
      return 'JUAL';
    default:
      return 'NETRAL';
  }
}

/// Formatter input angka IDR real-time: pemisah ribuan titik (.), pemisah desimal koma (,)
class IndonesianNumberInputFormatter extends TextInputFormatter {
  final bool allowFraction;
  final int maxFractionDigits;

  IndonesianNumberInputFormatter({
    this.allowFraction = true,
    this.maxFractionDigits = 3, // Gw set 3 karena emas biasanya 3 digit di belakang koma (misal: 4,100)
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text;
    final isDeletion = newValue.text.length < oldValue.text.length;

    // Autocorrect jika user ngetik titik (.) padahal format Indo pakai koma (,)
    if (!isDeletion && allowFraction && text.contains('.') && !text.contains(',')) {
      final lastDotIndex = text.lastIndexOf('.');
      final afterDot = text.substring(lastDotIndex + 1);
      if (afterDot.length <= maxFractionDigits) {
        final beforeDot = text.substring(0, lastDotIndex).replaceAll('.', '');
        if (RegExp(r'^\d+$').hasMatch(beforeDot)) {
          text = '$beforeDot,$afterDot';
        }
      }
    }

    String integerPart = text;
    String fractionPart = '';
    bool hasComma = text.contains(',');

    if (hasComma) {
      final parts = text.split(',');
      integerPart = parts[0];
      fractionPart = parts.sublist(1).join('');
      if (fractionPart.length > maxFractionDigits) {
        fractionPart = fractionPart.substring(0, maxFractionDigits);
      }
    }

    String digitsOnly = integerPart.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty && !hasComma) {
      return const TextEditingValue(text: '');
    }

    String formattedInteger = digitsOnly.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    String formattedText = formattedInteger;
    if (hasComma) {
      formattedText += ',$fractionPart';
    }

    // ===============================================
    // FIX KURSOR: Pake `text[i]` BUKAN `newValue.text[i]`
    // ===============================================
    int cursorDigitCount = 0;
    int limit = newValue.selection.end.clamp(0, text.length);
    for (int i = 0; i < limit; i++) {
      if (RegExp(r'[\d,]').hasMatch(text[i])) { 
        cursorDigitCount++;
      }
    }

    int newSelectionIndex = formattedText.length;
    int currentCount = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (RegExp(r'[\d,]').hasMatch(formattedText[i])) {
        currentCount++;
      }
      if (currentCount >= cursorDigitCount) {
        newSelectionIndex = i + 1;
        break;
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newSelectionIndex.clamp(0, formattedText.length),
      ),
    );
  }
}

/// Formatter input angka USD real-time: pemisah ribuan koma (,), pemisah desimal titik (.)
class UsdNumberInputFormatter extends TextInputFormatter {
  final bool allowFraction;
  final int maxFractionDigits;

  UsdNumberInputFormatter({
    this.allowFraction = true,
    this.maxFractionDigits = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text;
    final isDeletion = newValue.text.length < oldValue.text.length;

    // Ubah koma desimal menjadi titik jika diketik di posisi desimal
    if (!isDeletion && allowFraction && text.contains(',') && !text.contains('.')) {
      final lastCommaIndex = text.lastIndexOf(',');
      final afterComma = text.substring(lastCommaIndex + 1);
      if (afterComma.length <= maxFractionDigits) {
        final beforeComma = text.substring(0, lastCommaIndex).replaceAll(',', '');
        if (RegExp(r'^\d+$').hasMatch(beforeComma)) {
          text = '$beforeComma.$afterComma';
        }
      }
    }

    String integerPart = text;
    String fractionPart = '';
    bool hasDot = text.contains('.');

    if (hasDot) {
      final parts = text.split('.');
      integerPart = parts[0];
      fractionPart = parts.sublist(1).join('');
      if (fractionPart.length > maxFractionDigits) {
        fractionPart = fractionPart.substring(0, maxFractionDigits);
      }
    }

    String digitsOnly = integerPart.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty && !hasDot) {
      return const TextEditingValue(text: '');
    }

    String formattedInteger = digitsOnly.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    String formattedText = formattedInteger;
    if (hasDot) {
      formattedText += '.$fractionPart';
    }

    // ===============================================
    // FIX KURSOR: Pake `text[i]` BUKAN `newValue.text[i]`
    // ===============================================
    int cursorDigitCount = 0;
    int limit = newValue.selection.end.clamp(0, text.length);
    for (int i = 0; i < limit; i++) {
      if (RegExp(r'[\d\.]').hasMatch(text[i])) { 
        cursorDigitCount++;
      }
    }

    int newSelectionIndex = formattedText.length;
    int currentCount = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (RegExp(r'[\d\.]').hasMatch(formattedText[i])) {
        currentCount++;
      }
      if (currentCount >= cursorDigitCount) {
        newSelectionIndex = i + 1;
        break;
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newSelectionIndex.clamp(0, formattedText.length),
      ),
    );
  }
}

class GoldPriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // =========================
    // 1. INPUT KOSONG
    // =========================
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // =========================
    // 2. AMBIL DIGIT SAJA
    // =========================
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // =========================
    // 3. FORMAT RIBUAN
    // =========================
    final formattedText = digitsOnly.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    // =========================
    // 4. KHUSUS CURSOR
    // =========================
    //
    // Hitung berapa digit yang berada
    // di sebelah kiri cursor pada newValue.
    //
    // Contoh:
    //
    // 4.10|
    // digit di kiri cursor = 3
    //
    // Setelah diformat menjadi:
    //
    // 410|
    //
    // cursor harus berada setelah digit ke-3.
    //
    final cursorOffset = newValue.selection.baseOffset.clamp(
      0,
      newValue.text.length,
    );

    int digitBeforeCursor = 0;

    for (int i = 0; i < cursorOffset; i++) {
      if (_isDigit(newValue.text[i])) {
        digitBeforeCursor++;
      }
    }

    // =========================
    // 5. CARI POSISI CURSOR BARU
    // =========================
    int newCursorOffset = 0;
    int digitCount = 0;

    for (int i = 0; i < formattedText.length; i++) {
      if (_isDigit(formattedText[i])) {
        digitCount++;

        if (digitCount == digitBeforeCursor) {
          newCursorOffset = i + 1;
          break;
        }
      }
    }

    // Kalau cursor berada setelah semua digit,
    // pastikan cursor benar-benar di paling belakang.
    if (digitBeforeCursor >= digitsOnly.length) {
      newCursorOffset = formattedText.length;
    }

    // Kalau cursor berada di paling kiri.
    if (digitBeforeCursor == 0) {
      newCursorOffset = 0;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newCursorOffset,
      ),
    );
  }

  bool _isDigit(String character) {
    return character.codeUnitAt(0) >= 48 &&
        character.codeUnitAt(0) <= 57;
  }
}
