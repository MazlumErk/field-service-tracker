import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// Brand name shown in the app bar and task switcher.
  ///
  /// In tr, this message translates to:
  /// **'Field Service Tracker'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakış'**
  String get navDashboard;

  /// No description provided for @navCustomers.
  ///
  /// In tr, this message translates to:
  /// **'Müşteriler'**
  String get navCustomers;

  /// No description provided for @navMaintenance.
  ///
  /// In tr, this message translates to:
  /// **'Bakımlar'**
  String get navMaintenance;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @customerNewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Müşteri'**
  String get customerNewTitle;

  /// No description provided for @customerDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri Detayı'**
  String get customerDetailTitle;

  /// No description provided for @customerEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Müşteriyi Düzenle'**
  String get customerEditTitle;

  /// No description provided for @deviceNewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Cihaz'**
  String get deviceNewTitle;

  /// No description provided for @deviceDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz Detayı'**
  String get deviceDetailTitle;

  /// No description provided for @deviceEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cihazı Düzenle'**
  String get deviceEditTitle;

  /// No description provided for @maintenanceNewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bakım Kaydı'**
  String get maintenanceNewTitle;

  /// No description provided for @placeholderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu ekran hazırlanıyor'**
  String get placeholderTitle;

  /// No description provided for @placeholderMessage.
  ///
  /// In tr, this message translates to:
  /// **'İçerik bir sonraki geliştirme aşamasında eklenecek.'**
  String get placeholderMessage;

  /// No description provided for @notFoundTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa bulunamadı'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In tr, this message translates to:
  /// **'Aradığınız kayıt veya sayfa mevcut değil ya da silinmiş olabilir.'**
  String get notFoundMessage;

  /// No description provided for @backToDashboard.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakış\'a dön'**
  String get backToDashboard;

  /// No description provided for @settingsSectionApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama'**
  String get settingsSectionApp;

  /// No description provided for @settingsAbout.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama hakkında'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In tr, this message translates to:
  /// **'Su arıtma ve saha servis işletmeleri için internet gerektirmeyen müşteri, cihaz ve periyodik bakım takip uygulaması. Tüm veriler cihazda saklanır; demo verileri tamamen kurgusaldır.'**
  String get settingsAboutDescription;

  /// No description provided for @settingsVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get settingsVersion;

  /// No description provided for @settingsVersionValue.
  ///
  /// In tr, this message translates to:
  /// **'{version} (derleme {buildNumber})'**
  String settingsVersionValue(String version, String buildNumber);

  /// No description provided for @settingsLicenses.
  ///
  /// In tr, this message translates to:
  /// **'Açık kaynak lisansları'**
  String get settingsLicenses;

  /// No description provided for @settingsLicensesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanılan paketler ve Inter yazı tipi'**
  String get settingsLicensesSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
