// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerNumberMeta = const VerificationMeta(
    'customerNumber',
  );
  @override
  late final GeneratedColumn<String> customerNumber = GeneratedColumn<String>(
    'customer_number',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchKeyMeta = const VerificationMeta(
    'searchKey',
  );
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerNumber,
    firstName,
    lastName,
    phone,
    address,
    searchKey,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_number')) {
      context.handle(
        _customerNumberMeta,
        customerNumber.isAcceptableOrUnknown(
          data['customer_number']!,
          _customerNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNumberMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('search_key')) {
      context.handle(
        _searchKeyMeta,
        searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {customerNumber},
  ];
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_number'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      searchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final int id;
  final String customerNumber;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? address;
  final String searchKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CustomerRow({
    required this.id,
    required this.customerNumber,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.address,
    required this.searchKey,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_number'] = Variable<String>(customerNumber);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['search_key'] = Variable<String>(searchKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      customerNumber: Value(customerNumber),
      firstName: Value(firstName),
      lastName: Value(lastName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      searchKey: Value(searchKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<int>(json['id']),
      customerNumber: serializer.fromJson<String>(json['customerNumber']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      searchKey: serializer.fromJson<String>(json['searchKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerNumber': serializer.toJson<String>(customerNumber),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'searchKey': serializer.toJson<String>(searchKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomerRow copyWith({
    int? id,
    String? customerNumber,
    String? firstName,
    String? lastName,
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    String? searchKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CustomerRow(
    id: id ?? this.id,
    customerNumber: customerNumber ?? this.customerNumber,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    searchKey: searchKey ?? this.searchKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      customerNumber: data.customerNumber.present
          ? data.customerNumber.value
          : this.customerNumber,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('customerNumber: $customerNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('searchKey: $searchKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerNumber,
    firstName,
    lastName,
    phone,
    address,
    searchKey,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.customerNumber == this.customerNumber &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.searchKey == this.searchKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<int> id;
  final Value<String> customerNumber;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String> searchKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.customerNumber = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String customerNumber,
    required String firstName,
    required String lastName,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    required String searchKey,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : customerNumber = Value(customerNumber),
       firstName = Value(firstName),
       lastName = Value(lastName),
       searchKey = Value(searchKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomerRow> custom({
    Expression<int>? id,
    Expression<String>? customerNumber,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? searchKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerNumber != null) 'customer_number': customerNumber,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (searchKey != null) 'search_key': searchKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<String>? customerNumber,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String>? searchKey,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      customerNumber: customerNumber ?? this.customerNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      searchKey: searchKey ?? this.searchKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerNumber.present) {
      map['customer_number'] = Variable<String>(customerNumber.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('customerNumber: $customerNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('searchKey: $searchKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, DeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serialNumberMeta = const VerificationMeta(
    'serialNumber',
  );
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
    'serial_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String>
  installedAt = GeneratedColumn<String>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CalendarDate>($DevicesTable.$converterinstalledAt);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    model,
    serialNumber,
    installedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('serial_number')) {
      context.handle(
        _serialNumberMeta,
        serialNumber.isAcceptableOrUnknown(
          data['serial_number']!,
          _serialNumberMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      serialNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_number'],
      ),
      installedAt: $DevicesTable.$converterinstalledAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}installed_at'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterinstalledAt =
      const CalendarDateConverter();
}

class DeviceRow extends DataClass implements Insertable<DeviceRow> {
  final int id;
  final int customerId;
  final String model;
  final String? serialNumber;
  final CalendarDate installedAt;
  final DateTime createdAt;
  const DeviceRow({
    required this.id,
    required this.customerId,
    required this.model,
    this.serialNumber,
    required this.installedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || serialNumber != null) {
      map['serial_number'] = Variable<String>(serialNumber);
    }
    {
      map['installed_at'] = Variable<String>(
        $DevicesTable.$converterinstalledAt.toSql(installedAt),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      model: Value(model),
      serialNumber: serialNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(serialNumber),
      installedAt: Value(installedAt),
      createdAt: Value(createdAt),
    );
  }

  factory DeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceRow(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      model: serializer.fromJson<String>(json['model']),
      serialNumber: serializer.fromJson<String?>(json['serialNumber']),
      installedAt: serializer.fromJson<CalendarDate>(json['installedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'model': serializer.toJson<String>(model),
      'serialNumber': serializer.toJson<String?>(serialNumber),
      'installedAt': serializer.toJson<CalendarDate>(installedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DeviceRow copyWith({
    int? id,
    int? customerId,
    String? model,
    Value<String?> serialNumber = const Value.absent(),
    CalendarDate? installedAt,
    DateTime? createdAt,
  }) => DeviceRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    model: model ?? this.model,
    serialNumber: serialNumber.present ? serialNumber.value : this.serialNumber,
    installedAt: installedAt ?? this.installedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  DeviceRow copyWithCompanion(DevicesCompanion data) {
    return DeviceRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      model: data.model.present ? data.model.value : this.model,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('installedAt: $installedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, customerId, model, serialNumber, installedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.model == this.model &&
          other.serialNumber == this.serialNumber &&
          other.installedAt == this.installedAt &&
          other.createdAt == this.createdAt);
}

class DevicesCompanion extends UpdateCompanion<DeviceRow> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<String> model;
  final Value<String?> serialNumber;
  final Value<CalendarDate> installedAt;
  final Value<DateTime> createdAt;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.model = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DevicesCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required String model,
    this.serialNumber = const Value.absent(),
    required CalendarDate installedAt,
    required DateTime createdAt,
  }) : customerId = Value(customerId),
       model = Value(model),
       installedAt = Value(installedAt),
       createdAt = Value(createdAt);
  static Insertable<DeviceRow> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<String>? model,
    Expression<String>? serialNumber,
    Expression<String>? installedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (model != null) 'model': model,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (installedAt != null) 'installed_at': installedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DevicesCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<String>? model,
    Value<String?>? serialNumber,
    Value<CalendarDate>? installedAt,
    Value<DateTime>? createdAt,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      installedAt: installedAt ?? this.installedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<String>(
        $DevicesTable.$converterinstalledAt.toSql(installedAt.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('installedAt: $installedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceRecordsTable extends MaintenanceRecords
    with TableInfo<$MaintenanceRecordsTable, MaintenanceRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String>
  maintenanceDate =
      GeneratedColumn<String>(
        'maintenance_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>(
        $MaintenanceRecordsTable.$convertermaintenanceDate,
      );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String>
  nextMaintenanceDate =
      GeneratedColumn<String>(
        'next_maintenance_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>(
        $MaintenanceRecordsTable.$converternextMaintenanceDate,
      );
  static const VerificationMeta _priceKurusMeta = const VerificationMeta(
    'priceKurus',
  );
  @override
  late final GeneratedColumn<int> priceKurus = GeneratedColumn<int>(
    'price_kurus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    maintenanceDate,
    nextMaintenanceDate,
    priceKurus,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('price_kurus')) {
      context.handle(
        _priceKurusMeta,
        priceKurus.isAcceptableOrUnknown(data['price_kurus']!, _priceKurusMeta),
      );
    } else if (isInserting) {
      context.missing(_priceKurusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
      maintenanceDate: $MaintenanceRecordsTable.$convertermaintenanceDate
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}maintenance_date'],
            )!,
          ),
      nextMaintenanceDate: $MaintenanceRecordsTable
          .$converternextMaintenanceDate
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}next_maintenance_date'],
            )!,
          ),
      priceKurus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_kurus'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MaintenanceRecordsTable createAlias(String alias) {
    return $MaintenanceRecordsTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $convertermaintenanceDate =
      const CalendarDateConverter();
  static TypeConverter<CalendarDate, String> $converternextMaintenanceDate =
      const CalendarDateConverter();
}

class MaintenanceRecordRow extends DataClass
    implements Insertable<MaintenanceRecordRow> {
  final int id;
  final int deviceId;
  final CalendarDate maintenanceDate;
  final CalendarDate nextMaintenanceDate;
  final int priceKurus;
  final String? notes;
  final DateTime createdAt;
  const MaintenanceRecordRow({
    required this.id,
    required this.deviceId,
    required this.maintenanceDate,
    required this.nextMaintenanceDate,
    required this.priceKurus,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<int>(deviceId);
    {
      map['maintenance_date'] = Variable<String>(
        $MaintenanceRecordsTable.$convertermaintenanceDate.toSql(
          maintenanceDate,
        ),
      );
    }
    {
      map['next_maintenance_date'] = Variable<String>(
        $MaintenanceRecordsTable.$converternextMaintenanceDate.toSql(
          nextMaintenanceDate,
        ),
      );
    }
    map['price_kurus'] = Variable<int>(priceKurus);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MaintenanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceRecordsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      maintenanceDate: Value(maintenanceDate),
      nextMaintenanceDate: Value(nextMaintenanceDate),
      priceKurus: Value(priceKurus),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory MaintenanceRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceRecordRow(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      maintenanceDate: serializer.fromJson<CalendarDate>(
        json['maintenanceDate'],
      ),
      nextMaintenanceDate: serializer.fromJson<CalendarDate>(
        json['nextMaintenanceDate'],
      ),
      priceKurus: serializer.fromJson<int>(json['priceKurus']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<int>(deviceId),
      'maintenanceDate': serializer.toJson<CalendarDate>(maintenanceDate),
      'nextMaintenanceDate': serializer.toJson<CalendarDate>(
        nextMaintenanceDate,
      ),
      'priceKurus': serializer.toJson<int>(priceKurus),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MaintenanceRecordRow copyWith({
    int? id,
    int? deviceId,
    CalendarDate? maintenanceDate,
    CalendarDate? nextMaintenanceDate,
    int? priceKurus,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => MaintenanceRecordRow(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    maintenanceDate: maintenanceDate ?? this.maintenanceDate,
    nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
    priceKurus: priceKurus ?? this.priceKurus,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  MaintenanceRecordRow copyWithCompanion(MaintenanceRecordsCompanion data) {
    return MaintenanceRecordRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      maintenanceDate: data.maintenanceDate.present
          ? data.maintenanceDate.value
          : this.maintenanceDate,
      nextMaintenanceDate: data.nextMaintenanceDate.present
          ? data.nextMaintenanceDate.value
          : this.nextMaintenanceDate,
      priceKurus: data.priceKurus.present
          ? data.priceKurus.value
          : this.priceKurus,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRecordRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('maintenanceDate: $maintenanceDate, ')
          ..write('nextMaintenanceDate: $nextMaintenanceDate, ')
          ..write('priceKurus: $priceKurus, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    maintenanceDate,
    nextMaintenanceDate,
    priceKurus,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceRecordRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.maintenanceDate == this.maintenanceDate &&
          other.nextMaintenanceDate == this.nextMaintenanceDate &&
          other.priceKurus == this.priceKurus &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MaintenanceRecordsCompanion
    extends UpdateCompanion<MaintenanceRecordRow> {
  final Value<int> id;
  final Value<int> deviceId;
  final Value<CalendarDate> maintenanceDate;
  final Value<CalendarDate> nextMaintenanceDate;
  final Value<int> priceKurus;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const MaintenanceRecordsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.maintenanceDate = const Value.absent(),
    this.nextMaintenanceDate = const Value.absent(),
    this.priceKurus = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MaintenanceRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int deviceId,
    required CalendarDate maintenanceDate,
    required CalendarDate nextMaintenanceDate,
    required int priceKurus,
    this.notes = const Value.absent(),
    required DateTime createdAt,
  }) : deviceId = Value(deviceId),
       maintenanceDate = Value(maintenanceDate),
       nextMaintenanceDate = Value(nextMaintenanceDate),
       priceKurus = Value(priceKurus),
       createdAt = Value(createdAt);
  static Insertable<MaintenanceRecordRow> custom({
    Expression<int>? id,
    Expression<int>? deviceId,
    Expression<String>? maintenanceDate,
    Expression<String>? nextMaintenanceDate,
    Expression<int>? priceKurus,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (maintenanceDate != null) 'maintenance_date': maintenanceDate,
      if (nextMaintenanceDate != null)
        'next_maintenance_date': nextMaintenanceDate,
      if (priceKurus != null) 'price_kurus': priceKurus,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MaintenanceRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? deviceId,
    Value<CalendarDate>? maintenanceDate,
    Value<CalendarDate>? nextMaintenanceDate,
    Value<int>? priceKurus,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return MaintenanceRecordsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      maintenanceDate: maintenanceDate ?? this.maintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      priceKurus: priceKurus ?? this.priceKurus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (maintenanceDate.present) {
      map['maintenance_date'] = Variable<String>(
        $MaintenanceRecordsTable.$convertermaintenanceDate.toSql(
          maintenanceDate.value,
        ),
      );
    }
    if (nextMaintenanceDate.present) {
      map['next_maintenance_date'] = Variable<String>(
        $MaintenanceRecordsTable.$converternextMaintenanceDate.toSql(
          nextMaintenanceDate.value,
        ),
      );
    }
    if (priceKurus.present) {
      map['price_kurus'] = Variable<int>(priceKurus.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('maintenanceDate: $maintenanceDate, ')
          ..write('nextMaintenanceDate: $nextMaintenanceDate, ')
          ..write('priceKurus: $priceKurus, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FilterReplacementsTable extends FilterReplacements
    with TableInfo<$FilterReplacementsTable, FilterReplacementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FilterReplacementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _maintenanceRecordIdMeta =
      const VerificationMeta('maintenanceRecordId');
  @override
  late final GeneratedColumn<int> maintenanceRecordId = GeneratedColumn<int>(
    'maintenance_record_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES maintenance_records (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FilterType, String> filterType =
      GeneratedColumn<String>(
        'filter_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FilterType>(
        $FilterReplacementsTable.$converterfilterType,
      );
  @override
  List<GeneratedColumn> get $columns => [id, maintenanceRecordId, filterType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'filter_replacements';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilterReplacementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('maintenance_record_id')) {
      context.handle(
        _maintenanceRecordIdMeta,
        maintenanceRecordId.isAcceptableOrUnknown(
          data['maintenance_record_id']!,
          _maintenanceRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maintenanceRecordIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {maintenanceRecordId, filterType},
  ];
  @override
  FilterReplacementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilterReplacementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      maintenanceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}maintenance_record_id'],
      )!,
      filterType: $FilterReplacementsTable.$converterfilterType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}filter_type'],
        )!,
      ),
    );
  }

  @override
  $FilterReplacementsTable createAlias(String alias) {
    return $FilterReplacementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FilterType, String, String> $converterfilterType =
      const EnumNameConverter<FilterType>(FilterType.values);
}

class FilterReplacementRow extends DataClass
    implements Insertable<FilterReplacementRow> {
  final int id;
  final int maintenanceRecordId;
  final FilterType filterType;
  const FilterReplacementRow({
    required this.id,
    required this.maintenanceRecordId,
    required this.filterType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['maintenance_record_id'] = Variable<int>(maintenanceRecordId);
    {
      map['filter_type'] = Variable<String>(
        $FilterReplacementsTable.$converterfilterType.toSql(filterType),
      );
    }
    return map;
  }

  FilterReplacementsCompanion toCompanion(bool nullToAbsent) {
    return FilterReplacementsCompanion(
      id: Value(id),
      maintenanceRecordId: Value(maintenanceRecordId),
      filterType: Value(filterType),
    );
  }

  factory FilterReplacementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilterReplacementRow(
      id: serializer.fromJson<int>(json['id']),
      maintenanceRecordId: serializer.fromJson<int>(
        json['maintenanceRecordId'],
      ),
      filterType: $FilterReplacementsTable.$converterfilterType.fromJson(
        serializer.fromJson<String>(json['filterType']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'maintenanceRecordId': serializer.toJson<int>(maintenanceRecordId),
      'filterType': serializer.toJson<String>(
        $FilterReplacementsTable.$converterfilterType.toJson(filterType),
      ),
    };
  }

  FilterReplacementRow copyWith({
    int? id,
    int? maintenanceRecordId,
    FilterType? filterType,
  }) => FilterReplacementRow(
    id: id ?? this.id,
    maintenanceRecordId: maintenanceRecordId ?? this.maintenanceRecordId,
    filterType: filterType ?? this.filterType,
  );
  FilterReplacementRow copyWithCompanion(FilterReplacementsCompanion data) {
    return FilterReplacementRow(
      id: data.id.present ? data.id.value : this.id,
      maintenanceRecordId: data.maintenanceRecordId.present
          ? data.maintenanceRecordId.value
          : this.maintenanceRecordId,
      filterType: data.filterType.present
          ? data.filterType.value
          : this.filterType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilterReplacementRow(')
          ..write('id: $id, ')
          ..write('maintenanceRecordId: $maintenanceRecordId, ')
          ..write('filterType: $filterType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, maintenanceRecordId, filterType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilterReplacementRow &&
          other.id == this.id &&
          other.maintenanceRecordId == this.maintenanceRecordId &&
          other.filterType == this.filterType);
}

class FilterReplacementsCompanion
    extends UpdateCompanion<FilterReplacementRow> {
  final Value<int> id;
  final Value<int> maintenanceRecordId;
  final Value<FilterType> filterType;
  const FilterReplacementsCompanion({
    this.id = const Value.absent(),
    this.maintenanceRecordId = const Value.absent(),
    this.filterType = const Value.absent(),
  });
  FilterReplacementsCompanion.insert({
    this.id = const Value.absent(),
    required int maintenanceRecordId,
    required FilterType filterType,
  }) : maintenanceRecordId = Value(maintenanceRecordId),
       filterType = Value(filterType);
  static Insertable<FilterReplacementRow> custom({
    Expression<int>? id,
    Expression<int>? maintenanceRecordId,
    Expression<String>? filterType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (maintenanceRecordId != null)
        'maintenance_record_id': maintenanceRecordId,
      if (filterType != null) 'filter_type': filterType,
    });
  }

  FilterReplacementsCompanion copyWith({
    Value<int>? id,
    Value<int>? maintenanceRecordId,
    Value<FilterType>? filterType,
  }) {
    return FilterReplacementsCompanion(
      id: id ?? this.id,
      maintenanceRecordId: maintenanceRecordId ?? this.maintenanceRecordId,
      filterType: filterType ?? this.filterType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (maintenanceRecordId.present) {
      map['maintenance_record_id'] = Variable<int>(maintenanceRecordId.value);
    }
    if (filterType.present) {
      map['filter_type'] = Variable<String>(
        $FilterReplacementsTable.$converterfilterType.toSql(filterType.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilterReplacementsCompanion(')
          ..write('id: $id, ')
          ..write('maintenanceRecordId: $maintenanceRecordId, ')
          ..write('filterType: $filterType')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $MaintenanceRecordsTable maintenanceRecords =
      $MaintenanceRecordsTable(this);
  late final $FilterReplacementsTable filterReplacements =
      $FilterReplacementsTable(this);
  late final Index idxCustomersSearchKey = Index(
    'idx_customers_search_key',
    'CREATE INDEX idx_customers_search_key ON customers (search_key)',
  );
  late final Index idxDevicesCustomerId = Index(
    'idx_devices_customer_id',
    'CREATE INDEX idx_devices_customer_id ON devices (customer_id)',
  );
  late final Index idxMaintenanceRecordsDeviceDate = Index(
    'idx_maintenance_records_device_date',
    'CREATE INDEX idx_maintenance_records_device_date ON maintenance_records (device_id, maintenance_date)',
  );
  late final CustomersDao customersDao = CustomersDao(this as AppDatabase);
  late final DevicesDao devicesDao = DevicesDao(this as AppDatabase);
  late final MaintenanceDao maintenanceDao = MaintenanceDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    devices,
    maintenanceRecords,
    filterReplacements,
    idxCustomersSearchKey,
    idxDevicesCustomerId,
    idxMaintenanceRecordsDeviceDate,
  ];
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  required String customerNumber,
  required String firstName,
  required String lastName,
  Value<String?> phone,
  Value<String?> address,
  required String searchKey,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  Value<String> customerNumber,
  Value<String> firstName,
  Value<String> lastName,
  Value<String?> phone,
  Value<String?> address,
  Value<String> searchKey,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DevicesTable, List<DeviceRow>> _devicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.devices,
    aliasName: 'customers__id__devices__customer_id',
  );

  $$DevicesTableProcessedTableManager get devicesRefs {
    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_devicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerNumber => $composableBuilder(
    column: $table.customerNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> devicesRefs(
    Expression<bool> Function($$DevicesTableFilterComposer f) f,
  ) {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerNumber => $composableBuilder(
    column: $table.customerNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerNumber => $composableBuilder(
    column: $table.customerNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get searchKey =>
      $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> devicesRefs<T extends Object>(
    Expression<T> Function($$DevicesTableAnnotationComposer a) f,
  ) {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (CustomerRow, $$CustomersTableReferences),
          CustomerRow,
          PrefetchHooks Function({bool devicesRefs})
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> customerNumber = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> searchKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                customerNumber: customerNumber,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                address: address,
                searchKey: searchKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String customerNumber,
                required String firstName,
                required String lastName,
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                required String searchKey,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CustomersCompanion.insert(
                id: id,
                customerNumber: customerNumber,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                address: address,
                searchKey: searchKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, CustomerRow>(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({devicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (devicesRefs) db.devices],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (devicesRefs)
                    await $_getPrefetchedDataByColumns<
                      CustomerRow,
                      $CustomersTable,
                      DeviceRow,
                      $DevicesTable
                    >(
                      currentTable: table,
                      referencedTable: $$CustomersTableReferences
                          ._devicesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomersTableReferences(db, table, p0).devicesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'customer_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (CustomerRow, $$CustomersTableReferences),
      CustomerRow,
      PrefetchHooks Function({bool devicesRefs})
    >;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  required int customerId,
  required String model,
  Value<String?> serialNumber,
  required CalendarDate installedAt,
  required DateTime createdAt,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  Value<int> customerId,
  Value<String> model,
  Value<String?> serialNumber,
  Value<CalendarDate> installedAt,
  Value<DateTime> createdAt,
});

final class $$DevicesTableReferences
    extends BaseReferences<_$AppDatabase, $DevicesTable, DeviceRow> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('devices__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MaintenanceRecordsTable,
    List<MaintenanceRecordRow>
  >
  _maintenanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceRecords,
        aliasName: 'devices__id__maintenance_records__device_id',
      );

  $$MaintenanceRecordsTableProcessedTableManager get maintenanceRecordsRefs {
    final manager = $$MaintenanceRecordsTableTableManager(
      $_db,
      $_db.maintenanceRecords,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> maintenanceRecordsRefs(
    Expression<bool> Function($$MaintenanceRecordsTableFilterComposer f) f,
  ) {
    final $$MaintenanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRecords,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CalendarDate, String> get installedAt =>
      $composableBuilder(
        column: $table.installedAt,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> maintenanceRecordsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceRecords,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          DeviceRow,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (DeviceRow, $$DevicesTableReferences),
          DeviceRow,
          PrefetchHooks Function({bool customerId, bool maintenanceRecordsRefs})
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String?> serialNumber = const Value.absent(),
                Value<CalendarDate> installedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                customerId: customerId,
                model: model,
                serialNumber: serialNumber,
                installedAt: installedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                required String model,
                Value<String?> serialNumber = const Value.absent(),
                required CalendarDate installedAt,
                required DateTime createdAt,
              }) => DevicesCompanion.insert(
                id: id,
                customerId: customerId,
                model: model,
                serialNumber: serialNumber,
                installedAt: installedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevicesTable, DeviceRow>(table),
                  $$DevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({customerId = false, maintenanceRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (maintenanceRecordsRefs) db.maintenanceRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customerId,
                            referencedTable: $$DevicesTableReferences
                                ._customerIdTable(db),
                            referencedColumn: $$DevicesTableReferences
                                ._customerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (maintenanceRecordsRefs)
                        await $_getPrefetchedDataByColumns<
                          DeviceRow,
                          $DevicesTable,
                          MaintenanceRecordRow,
                          $MaintenanceRecordsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._maintenanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceRecordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      DeviceRow,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (DeviceRow, $$DevicesTableReferences),
      DeviceRow,
      PrefetchHooks Function({bool customerId, bool maintenanceRecordsRefs})
    >;
typedef $$MaintenanceRecordsTableCreateCompanionBuilder =
    MaintenanceRecordsCompanion Function({
      Value<int> id,
      required int deviceId,
      required CalendarDate maintenanceDate,
      required CalendarDate nextMaintenanceDate,
      required int priceKurus,
      Value<String?> notes,
      required DateTime createdAt,
    });
typedef $$MaintenanceRecordsTableUpdateCompanionBuilder =
    MaintenanceRecordsCompanion Function({
      Value<int> id,
      Value<int> deviceId,
      Value<CalendarDate> maintenanceDate,
      Value<CalendarDate> nextMaintenanceDate,
      Value<int> priceKurus,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$MaintenanceRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceRecordsTable,
          MaintenanceRecordRow
        > {
  $$MaintenanceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$AppDatabase db) =>
      db.devices.createAlias('maintenance_records__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $FilterReplacementsTable,
    List<FilterReplacementRow>
  >
  _filterReplacementsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.filterReplacements,
    aliasName:
        'maintenance_records__id__filter_replacements__maintenance_record_id',
  );

  $$FilterReplacementsTableProcessedTableManager get filterReplacementsRefs {
    final manager =
        $$FilterReplacementsTableTableManager(
          $_db,
          $_db.filterReplacements,
        ).filter(
          (f) => f.maintenanceRecordId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _filterReplacementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MaintenanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordsTable> {
  $$MaintenanceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get maintenanceDate => $composableBuilder(
    column: $table.maintenanceDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get nextMaintenanceDate => $composableBuilder(
    column: $table.nextMaintenanceDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get priceKurus => $composableBuilder(
    column: $table.priceKurus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> filterReplacementsRefs(
    Expression<bool> Function($$FilterReplacementsTableFilterComposer f) f,
  ) {
    final $$FilterReplacementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.filterReplacements,
      getReferencedColumn: (t) => t.maintenanceRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FilterReplacementsTableFilterComposer(
            $db: $db,
            $table: $db.filterReplacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MaintenanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordsTable> {
  $$MaintenanceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maintenanceDate => $composableBuilder(
    column: $table.maintenanceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextMaintenanceDate => $composableBuilder(
    column: $table.nextMaintenanceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceKurus => $composableBuilder(
    column: $table.priceKurus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordsTable> {
  $$MaintenanceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get maintenanceDate =>
      $composableBuilder(
        column: $table.maintenanceDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<CalendarDate, String>
  get nextMaintenanceDate => $composableBuilder(
    column: $table.nextMaintenanceDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceKurus => $composableBuilder(
    column: $table.priceKurus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> filterReplacementsRefs<T extends Object>(
    Expression<T> Function($$FilterReplacementsTableAnnotationComposer a) f,
  ) {
    final $$FilterReplacementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.filterReplacements,
          getReferencedColumn: (t) => t.maintenanceRecordId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FilterReplacementsTableAnnotationComposer(
                $db: $db,
                $table: $db.filterReplacements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MaintenanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceRecordsTable,
          MaintenanceRecordRow,
          $$MaintenanceRecordsTableFilterComposer,
          $$MaintenanceRecordsTableOrderingComposer,
          $$MaintenanceRecordsTableAnnotationComposer,
          $$MaintenanceRecordsTableCreateCompanionBuilder,
          $$MaintenanceRecordsTableUpdateCompanionBuilder,
          (MaintenanceRecordRow, $$MaintenanceRecordsTableReferences),
          MaintenanceRecordRow,
          PrefetchHooks Function({bool deviceId, bool filterReplacementsRefs})
        > {
  $$MaintenanceRecordsTableTableManager(
    _$AppDatabase db,
    $MaintenanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
                Value<CalendarDate> maintenanceDate = const Value.absent(),
                Value<CalendarDate> nextMaintenanceDate = const Value.absent(),
                Value<int> priceKurus = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MaintenanceRecordsCompanion(
                id: id,
                deviceId: deviceId,
                maintenanceDate: maintenanceDate,
                nextMaintenanceDate: nextMaintenanceDate,
                priceKurus: priceKurus,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deviceId,
                required CalendarDate maintenanceDate,
                required CalendarDate nextMaintenanceDate,
                required int priceKurus,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
              }) => MaintenanceRecordsCompanion.insert(
                id: id,
                deviceId: deviceId,
                maintenanceDate: maintenanceDate,
                nextMaintenanceDate: nextMaintenanceDate,
                priceKurus: priceKurus,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MaintenanceRecordsTable, MaintenanceRecordRow>(
                    table,
                  ),
                  $$MaintenanceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({deviceId = false, filterReplacementsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (filterReplacementsRefs) db.filterReplacements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (deviceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.deviceId,
                            referencedTable: $$MaintenanceRecordsTableReferences
                                ._deviceIdTable(db),
                            referencedColumn:
                                $$MaintenanceRecordsTableReferences
                                    ._deviceIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (filterReplacementsRefs)
                        await $_getPrefetchedDataByColumns<
                          MaintenanceRecordRow,
                          $MaintenanceRecordsTable,
                          FilterReplacementRow,
                          $FilterReplacementsTable
                        >(
                          currentTable: table,
                          referencedTable: $$MaintenanceRecordsTableReferences
                              ._filterReplacementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MaintenanceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).filterReplacementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'maintenance_record_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MaintenanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceRecordsTable,
      MaintenanceRecordRow,
      $$MaintenanceRecordsTableFilterComposer,
      $$MaintenanceRecordsTableOrderingComposer,
      $$MaintenanceRecordsTableAnnotationComposer,
      $$MaintenanceRecordsTableCreateCompanionBuilder,
      $$MaintenanceRecordsTableUpdateCompanionBuilder,
      (MaintenanceRecordRow, $$MaintenanceRecordsTableReferences),
      MaintenanceRecordRow,
      PrefetchHooks Function({bool deviceId, bool filterReplacementsRefs})
    >;
typedef $$FilterReplacementsTableCreateCompanionBuilder =
    FilterReplacementsCompanion Function({
      Value<int> id,
      required int maintenanceRecordId,
      required FilterType filterType,
    });
typedef $$FilterReplacementsTableUpdateCompanionBuilder =
    FilterReplacementsCompanion Function({
      Value<int> id,
      Value<int> maintenanceRecordId,
      Value<FilterType> filterType,
    });

final class $$FilterReplacementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FilterReplacementsTable,
          FilterReplacementRow
        > {
  $$FilterReplacementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MaintenanceRecordsTable _maintenanceRecordIdTable(_$AppDatabase db) =>
      db.maintenanceRecords.createAlias(
        'filter_replacements__maintenance_record_id__maintenance_records__id',
      );

  $$MaintenanceRecordsTableProcessedTableManager get maintenanceRecordId {
    final $_column = $_itemColumn<int>('maintenance_record_id')!;

    final manager = $$MaintenanceRecordsTableTableManager(
      $_db,
      $_db.maintenanceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_maintenanceRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FilterReplacementsTableFilterComposer
    extends Composer<_$AppDatabase, $FilterReplacementsTable> {
  $$FilterReplacementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FilterType, FilterType, String>
  get filterType => $composableBuilder(
    column: $table.filterType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$MaintenanceRecordsTableFilterComposer get maintenanceRecordId {
    final $$MaintenanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.maintenanceRecordId,
      referencedTable: $db.maintenanceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FilterReplacementsTableOrderingComposer
    extends Composer<_$AppDatabase, $FilterReplacementsTable> {
  $$FilterReplacementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterType => $composableBuilder(
    column: $table.filterType,
    builder: (column) => ColumnOrderings(column),
  );

  $$MaintenanceRecordsTableOrderingComposer get maintenanceRecordId {
    final $$MaintenanceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.maintenanceRecordId,
      referencedTable: $db.maintenanceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.maintenanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FilterReplacementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FilterReplacementsTable> {
  $$FilterReplacementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FilterType, String> get filterType =>
      $composableBuilder(
        column: $table.filterType,
        builder: (column) => column,
      );

  $$MaintenanceRecordsTableAnnotationComposer get maintenanceRecordId {
    final $$MaintenanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.maintenanceRecordId,
          referencedTable: $db.maintenanceRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$FilterReplacementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FilterReplacementsTable,
          FilterReplacementRow,
          $$FilterReplacementsTableFilterComposer,
          $$FilterReplacementsTableOrderingComposer,
          $$FilterReplacementsTableAnnotationComposer,
          $$FilterReplacementsTableCreateCompanionBuilder,
          $$FilterReplacementsTableUpdateCompanionBuilder,
          (FilterReplacementRow, $$FilterReplacementsTableReferences),
          FilterReplacementRow,
          PrefetchHooks Function({bool maintenanceRecordId})
        > {
  $$FilterReplacementsTableTableManager(
    _$AppDatabase db,
    $FilterReplacementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FilterReplacementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FilterReplacementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FilterReplacementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> maintenanceRecordId = const Value.absent(),
                Value<FilterType> filterType = const Value.absent(),
              }) => FilterReplacementsCompanion(
                id: id,
                maintenanceRecordId: maintenanceRecordId,
                filterType: filterType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int maintenanceRecordId,
                required FilterType filterType,
              }) => FilterReplacementsCompanion.insert(
                id: id,
                maintenanceRecordId: maintenanceRecordId,
                filterType: filterType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FilterReplacementsTable, FilterReplacementRow>(
                    table,
                  ),
                  $$FilterReplacementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({maintenanceRecordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (maintenanceRecordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.maintenanceRecordId,
                        referencedTable: $$FilterReplacementsTableReferences
                            ._maintenanceRecordIdTable(db),
                        referencedColumn: $$FilterReplacementsTableReferences
                            ._maintenanceRecordIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FilterReplacementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FilterReplacementsTable,
      FilterReplacementRow,
      $$FilterReplacementsTableFilterComposer,
      $$FilterReplacementsTableOrderingComposer,
      $$FilterReplacementsTableAnnotationComposer,
      $$FilterReplacementsTableCreateCompanionBuilder,
      $$FilterReplacementsTableUpdateCompanionBuilder,
      (FilterReplacementRow, $$FilterReplacementsTableReferences),
      FilterReplacementRow,
      PrefetchHooks Function({bool maintenanceRecordId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$MaintenanceRecordsTableTableManager get maintenanceRecords =>
      $$MaintenanceRecordsTableTableManager(_db, _db.maintenanceRecords);
  $$FilterReplacementsTableTableManager get filterReplacements =>
      $$FilterReplacementsTableTableManager(_db, _db.filterReplacements);
}
