/// Character classes and accent folding for single UTF-16 code units, as Kotlin's `Char` saw them.
library;

final _letter = RegExp(r'\p{L}', unicode: true);
final _digit = RegExp(r'\p{Nd}', unicode: true);
final _whitespace = RegExp(r'\s');

bool isLetterUnit(int unit) {
  if (unit < 0x80) return (unit | 0x20) >= 0x61 && (unit | 0x20) <= 0x7A;
  return _letter.hasMatch(String.fromCharCode(unit));
}

bool isDigitUnit(int unit) {
  if (unit < 0x80) return unit >= 0x30 && unit <= 0x39;
  return _digit.hasMatch(String.fromCharCode(unit));
}

bool isLetterOrDigitUnit(int unit) => isLetterUnit(unit) || isDigitUnit(unit);

bool isWhitespaceUnit(int unit) => _whitespace.hasMatch(String.fromCharCode(unit));

/// Latin letters with diacritics and the base letter each decomposes to (what Unicode NFD keeps
/// once the combining marks are dropped). Letters that don't decompose (ø, ł, æ, ß…) stay as they are.
const _accented =
    'ÀÁÂÃÄÅàáâãäåÇçÈÉÊËèéêëÌÍÎÏìíîïÑñÒÓÔÕÖòóôõöÙÚÛÜùúûüÝýÿ'
    'ĀāĂăĄąĆćĈĉĊċČčĎďĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĨĩĪīĬĭĮįİĴĵĶķĹĺĻļĽľŃńŅņŇň'
    'ŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽž';
const _bases =
    'AAAAAAaaaaaaCcEEEEeeeeIIIIiiiiNnOOOOOoooooUUUUuuuuYyy'
    'AaAaAaCcCcCcCcDdEeEeEeEeEeGgGgGgGgHhIiIiIiIiIJjKkLlLlLlNnNnNn'
    'OoOoOoRrRrRrSsSsSsSsTtTtUuUuUuUuUuUuWwYyYZzZzZz';

final Map<int, int> _baseOf = {
  for (var i = 0; i < _accented.length; i++) _accented.codeUnitAt(i): _bases.codeUnitAt(i),
};

bool _isCombiningMark(int unit) => unit >= 0x0300 && unit <= 0x036F;

/// [text] without accents and in lower case, one output code unit per input code unit (a
/// combining mark becomes U+0000), so match positions stay valid in the original.
String foldPerUnit(String text) => String.fromCharCodes(text.codeUnits.map((unit) {
      if (_isCombiningMark(unit)) return 0;
      final base = _baseOf[unit] ?? unit;
      return String.fromCharCode(base).toLowerCase().codeUnitAt(0);
    }));

/// How search compares text: trimmed, lower case, accents ignored ("telefonica" finds "Telefónica").
String foldForSearch(String text) =>
    foldPerUnit(text.trim()).replaceAll('\u0000', '');

/// Orders text the way people read it: ignoring case and accents, with ñ after n as in Spanish.
int compareForReading(String a, String b) => _sortKey(a).compareTo(_sortKey(b));

String _sortKey(String text) {
  final buffer = StringBuffer();
  for (final unit in text.codeUnits) {
    if (_isCombiningMark(unit)) continue;
    if (unit == 0xF1 || unit == 0xD1) {
      buffer.write('n\u{10FFFF}');
      continue;
    }
    buffer.write(String.fromCharCode(_baseOf[unit] ?? unit).toLowerCase());
  }
  return buffer.toString();
}
