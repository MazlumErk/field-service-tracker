// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Field Service Tracker';

  @override
  String get navDashboard => 'Genel Bakış';

  @override
  String get navCustomers => 'Müşteriler';

  @override
  String get navMaintenance => 'Bakımlar';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get customerNewTitle => 'Yeni Müşteri';

  @override
  String get customerDetailTitle => 'Müşteri Detayı';

  @override
  String get customerEditTitle => 'Müşteriyi Düzenle';

  @override
  String get deviceNewTitle => 'Yeni Cihaz';

  @override
  String get deviceDetailTitle => 'Cihaz Detayı';

  @override
  String get deviceEditTitle => 'Cihazı Düzenle';

  @override
  String get maintenanceNewTitle => 'Yeni Bakım Kaydı';

  @override
  String get placeholderTitle => 'Bu ekran hazırlanıyor';

  @override
  String get placeholderMessage =>
      'İçerik bir sonraki geliştirme aşamasında eklenecek.';

  @override
  String get notFoundTitle => 'Sayfa bulunamadı';

  @override
  String get notFoundMessage =>
      'Aradığınız kayıt veya sayfa mevcut değil ya da silinmiş olabilir.';

  @override
  String get backToDashboard => 'Genel Bakış\'a dön';

  @override
  String get startupErrorTitle => 'Veriler açılamadı';

  @override
  String get startupErrorMessage =>
      'Uygulama verilerine şu anda erişilemiyor. Lütfen uygulamayı kapatıp yeniden açın. Sorun devam ederse cihazda yeterli boş alan olduğundan emin olun.';

  @override
  String get settingsSectionApp => 'Uygulama';

  @override
  String get settingsAbout => 'Uygulama hakkında';

  @override
  String get settingsAboutDescription =>
      'Su arıtma ve saha servis işletmeleri için internet gerektirmeyen müşteri, cihaz ve periyodik bakım takip uygulaması. Tüm veriler cihazda saklanır; demo verileri tamamen kurgusaldır.';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String settingsVersionValue(String version, String buildNumber) {
    return '$version (derleme $buildNumber)';
  }

  @override
  String get settingsLicenses => 'Açık kaynak lisansları';

  @override
  String get settingsLicensesSubtitle =>
      'Kullanılan paketler ve Inter yazı tipi';
}
