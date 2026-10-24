import 'package:boveda_domain/boveda_domain.dart';
import 'package:test/test.dart';

void main() {
  test('folding keeps one code unit per input unit, so positions stay valid', () {
    const text = 'Telefónica Ñu';
    expect(foldPerUnit(text), 'telefonica nu');
    expect(foldPerUnit(text).length, text.length);
  });

  test('decomposed accents fold too', () {
    expect(foldForSearch('Telefónica'), 'telefonica');
  });
}
