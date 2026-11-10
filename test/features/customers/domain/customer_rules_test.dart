import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/customers/domain/customer_number.dart';
import 'package:field_service_tracker/features/customers/domain/customer_validator.dart';
import 'package:flutter_test/flutter_test.dart';

CustomerDraft _draft({
  String number = 'FST-0100',
  String first = 'Ayşe',
  String last = 'Yılmaz',
  String? phone,
  String? address,
}) => CustomerDraft(
  customerNumber: number,
  firstName: first,
  lastName: last,
  phone: phone,
  address: address,
);

void main() {
  group('CustomerNumber.normalize', () {
    test('removes whitespace and uppercases', () {
      expect(CustomerNumber.normalize(' fst - 0001 '), 'FST-0001');
      expect(CustomerNumber.normalize('fst-0001'), 'FST-0001');
      expect(CustomerNumber.normalize('FST-0001'), 'FST-0001');
    });

    test('maps both Turkish i letters to ASCII I', () {
      expect(CustomerNumber.normalize('ist-1'), 'IST-1');
      expect(CustomerNumber.normalize('ıst-1'), 'IST-1');
    });

    test('format allows ASCII codes only', () {
      expect(CustomerNumber.isValidFormat('FST-0001'), isTrue);
      expect(CustomerNumber.isValidFormat('A/12.3_4'), isTrue);
      expect(CustomerNumber.isValidFormat('ŞB-1'), isFalse);
      expect(CustomerNumber.isValidFormat('-A1'), isFalse);
    });
  });

  group('CustomerValidator', () {
    test('accepts a minimal valid customer', () {
      expect(CustomerValidator.validate(_draft()).isValid, isTrue);
    });

    test('requires names and number after trimming', () {
      final result = CustomerValidator.validate(
        _draft(number: '   ', first: '  ', last: '\t'),
      );
      expect(result.errors, {
        CustomerField.customerNumber: ValidationError.required,
        CustomerField.firstName: ValidationError.required,
        CustomerField.lastName: ValidationError.required,
      });
    });

    test('limits lengths', () {
      final result = CustomerValidator.validate(
        _draft(number: 'X' * 21, first: 'a' * 51, address: 'b' * 251),
      );
      expect(
        result.errorFor(CustomerField.customerNumber),
        ValidationError.tooLong,
      );
      expect(result.errorFor(CustomerField.firstName), ValidationError.tooLong);
      expect(result.errorFor(CustomerField.address), ValidationError.tooLong);
    });

    test('rejects Turkish letters in the customer number', () {
      expect(
        CustomerValidator.validate(_draft(number: 'ŞUBE-1'))
            .errorFor(CustomerField.customerNumber),
        ValidationError.invalidFormat,
      );
    });

    test('phone is optional but must look like a phone number', () {
      expect(CustomerValidator.validate(_draft(phone: '  ')).isValid, isTrue);
      expect(
        CustomerValidator.validate(_draft(phone: '0500 000 00 01')).isValid,
        isTrue,
      );
      expect(
        CustomerValidator.validate(_draft(phone: '+90 (500) 000-0001')).isValid,
        isTrue,
      );
      for (final invalid in ['12345', 'abc 000 00 00', '0' * 16]) {
        expect(
          CustomerValidator.validate(_draft(phone: invalid))
              .errorFor(CustomerField.phone),
          ValidationError.invalidFormat,
          reason: invalid,
        );
      }
    });
  });

  group('CustomerDraft.normalized', () {
    test('trims, collapses spaces and nulls blank optionals', () {
      final normalized = _draft(
        number: ' fst 7 ',
        first: '  Ali   Rıza ',
        phone: ' ',
        address: '  ',
      ).normalized();
      expect(normalized.customerNumber, 'FST7');
      expect(normalized.firstName, 'Ali Rıza');
      expect(normalized.phone, isNull);
      expect(normalized.address, isNull);
    });

    test('search key contains folded names and number', () {
      expect(
        _draft(number: 'fst-9', first: 'Şeyma', last: 'Çelik').searchKey,
        'seyma celik fst-9',
      );
    });
  });
}
