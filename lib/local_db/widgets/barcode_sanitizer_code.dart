class BarcodeSanitizer {
  // Main sanitization method - only this is needed
  static String sanitizeBarcode(String rawValue, String format) {
    String result = rawValue;

    // Common iOS barcode formats with prefixes
    if (rawValue.startsWith("UPCA:")) return rawValue.substring(5);
    if (rawValue.startsWith("UPCE:")) return rawValue.substring(5);
    if (rawValue.startsWith("EAN13:")) return rawValue.substring(6);
    if (rawValue.startsWith("EAN8:")) return rawValue.substring(5);
    if (rawValue.startsWith("CODE128:")) return rawValue.substring(8);
    if (rawValue.startsWith("CODE39:")) return rawValue.substring(7);
    if (rawValue.startsWith("UPC-A:")) return rawValue.substring(6);
    if (rawValue.startsWith("UPC-E:")) return rawValue.substring(6);
    if (rawValue.startsWith("EAN-13:")) return rawValue.substring(7);
    if (rawValue.startsWith("EAN-8:")) return rawValue.substring(6);

    // Convert to EAN-13 - UPC-A
    if ((format == "EAN13" || format == "EAN-13" || format == "EAN_13") && 
        rawValue.length == 13 && rawValue.startsWith('0')) {
      return rawValue.substring(1);
    }

    // Handle GS1 format (starts with ])
    if (rawValue.startsWith("]")) {
      RegExp match = RegExp(r'^\][A-Za-z0-9]+(\d+)');
      Match? matchResult = match.firstMatch(rawValue);
      if (matchResult != null && matchResult.groupCount >= 1) {
        return matchResult.group(1)!;
      }
    }

    // Remove common prefixes (case insensitive)
    List<String> prefixes = ["UPCA", "UPCE", "EAN13", "EAN8", "CODE128", "CODE39"];
    for (String prefix in prefixes) {
      String pattern = '$prefix:';
      if (RegExp(pattern, caseSensitive: false).hasMatch(rawValue)) {
        return rawValue.replaceAll(RegExp(pattern, caseSensitive: false), '');
      }
    }

    return rawValue;
  }
}