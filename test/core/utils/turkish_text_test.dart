import 'package:field_service_tracker/core/utils/turkish_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TurkishText.toLower / toUpper', () {
    test('handles dotted and dotless i', () {
      expect(TurkishText.toLower('IŞIK'), 'ışık');
      expect(TurkishText.toLower('İSTANBUL'), 'istanbul');
      expect(TurkishText.toUpper('istanbul'), 'İSTANBUL');
      expect(TurkishText.toUpper('ılık'), 'ILIK');
    });
  });

  group('TurkishText.searchKey', () {
    test('folds case and Turkish letters to ASCII', () {
      expect(TurkishText.searchKey('ŞAHİN'), 'sahin');
      expect(TurkishText.searchKey('şahin'), 'sahin');
      expect(TurkishText.searchKey('Çelik Öztürk Ğ Ü'), 'celik ozturk g u');
      expect(TurkishText.searchKey('Işık'), 'isik');
    });

    test('trims and collapses whitespace', () {
      expect(TurkishText.searchKey('  Ömer   Öztürk \n'), 'omer ozturk');
      expect(TurkishText.searchKey('   '), '');
    });

    test('drops combining dot from non-Turkish lowercasing', () {
      // "İ".toLowerCase() in Dart yields "i̇" (i + U+0307).
      expect(TurkishText.searchKey('İ'.toLowerCase()), 'i');
    });

    test('searchTokens splits into normalized words', () {
      expect(TurkishText.searchTokens(' Ahmet  YILMAZ '), ['ahmet', 'yilmaz']);
      expect(TurkishText.searchTokens(''), isEmpty);
    });
  });

  group('TurkishText.compare', () {
    test('sorts in Turkish alphabetical order', () {
      final names = ['Yılmaz', 'Çelik', 'Can', 'Demir', 'Öztürk', 'Ozan']
        ..sort(TurkishText.compare);
      expect(names, ['Can', 'Çelik', 'Demir', 'Ozan', 'Öztürk', 'Yılmaz']);
    });

    test('puts dotless ı before dotted i and ignores case', () {
      final names = ['İnce', 'Işık', 'ilker']..sort(TurkishText.compare);
      expect(names.first, 'Işık');
      expect(TurkishText.compare('şahin', 'ŞAHİN'), 0);
    });

    test('shorter prefix sorts first', () {
      expect(TurkishText.compare('Kara', 'Karaca'), lessThan(0));
    });
  });
}
