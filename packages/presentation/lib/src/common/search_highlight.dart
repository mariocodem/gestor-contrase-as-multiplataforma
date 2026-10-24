import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/painting.dart';

/// [text] with every match of [query] set in bold, matched the way the vault search matches
/// (ignoring case and accents), so a row found through its username shows why it is there.
TextSpan highlightMatches(String text, String query, {TextStyle? style}) {
  final needle = foldForSearch(query);
  if (needle.isEmpty) return TextSpan(text: text, style: style);
  // One folded unit per original one keeps match positions valid in [text].
  final folded = foldPerUnit(text);
  final spans = <TextSpan>[];
  var from = 0;
  while (true) {
    final at = folded.indexOf(needle, from);
    if (at < 0) break;
    if (at > from) spans.add(TextSpan(text: text.substring(from, at)));
    spans.add(TextSpan(text: text.substring(at, at + needle.length), style: const TextStyle(fontWeight: FontWeight.w700)));
    from = at + needle.length;
  }
  if (from < text.length) spans.add(TextSpan(text: text.substring(from)));
  return TextSpan(style: style, children: spans);
}
