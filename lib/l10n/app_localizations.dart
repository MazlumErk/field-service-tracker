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

  /// No description provided for @startupErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veriler açılamadı'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama verilerine şu anda erişilemiyor. Lütfen uygulamayı kapatıp yeniden açın. Sorun devam ederse cihazda yeterli boş alan olduğundan emin olun.'**
  String get startupErrorMessage;

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

  /// No description provided for @commonRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @commonMoreActions.
  ///
  /// In tr, this message translates to:
  /// **'Diğer işlemler'**
  String get commonMoreActions;

  /// No description provided for @commonOptional.
  ///
  /// In tr, this message translates to:
  /// **'isteğe bağlı'**
  String get commonOptional;

  /// No description provided for @commonNotProvided.
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmemiş'**
  String get commonNotProvided;

  /// No description provided for @errorNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt bulunamadı. Silinmiş olabilir.'**
  String get errorNotFound;

  /// No description provided for @errorDuplicateCustomerNumber.
  ///
  /// In tr, this message translates to:
  /// **'Bu müşteri numarası başka bir müşteride kullanılıyor.'**
  String get errorDuplicateCustomerNumber;

  /// No description provided for @errorValidation.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen işaretli alanları kontrol edin.'**
  String get errorValidation;

  /// No description provided for @errorDatabase.
  ///
  /// In tr, this message translates to:
  /// **'İşlem tamamlanamadı. Verileriniz değişmedi; lütfen tekrar deneyin.'**
  String get errorDatabase;

  /// No description provided for @errorUnexpected.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.'**
  String get errorUnexpected;

  /// No description provided for @errorLoadTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi'**
  String get errorLoadTitle;

  /// No description provided for @validationRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan zorunludur.'**
  String get validationRequired;

  /// No description provided for @validationTooLong.
  ///
  /// In tr, this message translates to:
  /// **'En fazla {max} karakter girebilirsiniz.'**
  String validationTooLong(int max);

  /// No description provided for @validationCustomerNumberFormat.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca harf (A–Z), rakam ve - _ / . kullanılabilir.'**
  String get validationCustomerNumberFormat;

  /// No description provided for @validationPhoneFormat.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir telefon numarası girin (10–15 rakam).'**
  String get validationPhoneFormat;

  /// No description provided for @validationAlreadyInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu müşteri numarası başka bir müşteride kullanılıyor.'**
  String get validationAlreadyInUse;

  /// No description provided for @customerSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ad, soyad veya müşteri no ile ara'**
  String get customerSearchHint;

  /// No description provided for @customerSearchClear.
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get customerSearchClear;

  /// No description provided for @customerAdd.
  ///
  /// In tr, this message translates to:
  /// **'Yeni müşteri'**
  String get customerAdd;

  /// No description provided for @customerCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} müşteri'**
  String customerCount(int count);

  /// No description provided for @customerResultCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} sonuç'**
  String customerResultCount(int count);

  /// No description provided for @customerDeviceCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} cihaz'**
  String customerDeviceCount(int count);

  /// No description provided for @customerListEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz müşteri yok'**
  String get customerListEmptyTitle;

  /// No description provided for @customerListEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'İlk müşterinizi ekleyerek cihaz ve bakım takibine başlayın.'**
  String get customerListEmptyMessage;

  /// No description provided for @customerNoResultsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get customerNoResultsTitle;

  /// No description provided for @customerNoResultsMessage.
  ///
  /// In tr, this message translates to:
  /// **'“{query}” ile eşleşen müşteri yok. Farklı bir ad veya müşteri numarası deneyin.'**
  String customerNoResultsMessage(String query);

  /// No description provided for @customerFieldFirstName.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get customerFieldFirstName;

  /// No description provided for @customerFieldLastName.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get customerFieldLastName;

  /// No description provided for @customerFieldNumber.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri numarası'**
  String get customerFieldNumber;

  /// No description provided for @customerFieldNumberHelper.
  ///
  /// In tr, this message translates to:
  /// **'Örn. FST-0021. Boşluklar kaldırılır, büyük harfe çevrilir.'**
  String get customerFieldNumberHelper;

  /// No description provided for @customerFieldPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get customerFieldPhone;

  /// No description provided for @customerFieldAddress.
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get customerFieldAddress;

  /// No description provided for @customerSaved.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri kaydedildi.'**
  String get customerSaved;

  /// No description provided for @customerUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler kaydedildi.'**
  String get customerUpdated;

  /// No description provided for @customerSectionContact.
  ///
  /// In tr, this message translates to:
  /// **'İletişim'**
  String get customerSectionContact;

  /// No description provided for @customerSectionDevices.
  ///
  /// In tr, this message translates to:
  /// **'Cihazlar'**
  String get customerSectionDevices;

  /// No description provided for @customerDevicesEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı cihaz yok'**
  String get customerDevicesEmptyTitle;

  /// No description provided for @customerDevicesEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu müşteriye henüz cihaz eklenmemiş.'**
  String get customerDevicesEmptyMessage;

  /// No description provided for @customerDelete.
  ///
  /// In tr, this message translates to:
  /// **'Müşteriyi sil'**
  String get customerDelete;

  /// No description provided for @customerDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri silinsin mi?'**
  String get customerDeleteTitle;

  /// No description provided for @customerDeleteMessageSimple.
  ///
  /// In tr, this message translates to:
  /// **'{name} kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String customerDeleteMessageSimple(String name);

  /// No description provided for @customerDeleteMessageWithRelated.
  ///
  /// In tr, this message translates to:
  /// **'{name} ile birlikte {devices} cihaz ve {records} bakım kaydı kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String customerDeleteMessageWithRelated(
    String name,
    int devices,
    int records,
  );

  /// No description provided for @customerDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri silindi.'**
  String get customerDeleted;

  /// No description provided for @customerRegisteredAt.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt tarihi'**
  String get customerRegisteredAt;

  /// No description provided for @deviceSerial.
  ///
  /// In tr, this message translates to:
  /// **'Seri no: {serial}'**
  String deviceSerial(String serial);

  /// No description provided for @deviceNextMaintenance.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki bakım: {date}'**
  String deviceNextMaintenance(String date);

  /// No description provided for @deviceNoMaintenanceYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bakım yapılmadı'**
  String get deviceNoMaintenanceYet;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilmemiş değişiklikler'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In tr, this message translates to:
  /// **'Yaptığınız değişiklikler kaydedilmedi. Çıkarsanız bu değişiklikler kaybolacak.'**
  String get unsavedChangesMessage;

  /// No description provided for @unsavedChangesDiscard.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri At'**
  String get unsavedChangesDiscard;

  /// No description provided for @deviceAdd.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz ekle'**
  String get deviceAdd;

  /// No description provided for @deviceFieldModel.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz modeli'**
  String get deviceFieldModel;

  /// No description provided for @deviceFieldModelHelper.
  ///
  /// In tr, this message translates to:
  /// **'Örn. AquaPure RO-5'**
  String get deviceFieldModelHelper;

  /// No description provided for @deviceFieldSerial.
  ///
  /// In tr, this message translates to:
  /// **'Seri numarası'**
  String get deviceFieldSerial;

  /// No description provided for @deviceFieldInstalledAt.
  ///
  /// In tr, this message translates to:
  /// **'Kurulum tarihi'**
  String get deviceFieldInstalledAt;

  /// No description provided for @deviceFieldInstalledAtHint.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seçmek için dokunun'**
  String get deviceFieldInstalledAtHint;

  /// No description provided for @deviceSaved.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz kaydedildi.'**
  String get deviceSaved;

  /// No description provided for @deviceUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz bilgileri güncellendi.'**
  String get deviceUpdated;

  /// No description provided for @deviceSerialMissing.
  ///
  /// In tr, this message translates to:
  /// **'Seri numarası belirtilmemiş'**
  String get deviceSerialMissing;

  /// No description provided for @deviceSectionInfo.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz bilgileri'**
  String get deviceSectionInfo;

  /// No description provided for @deviceCustomer.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri'**
  String get deviceCustomer;

  /// No description provided for @deviceCustomerNumber.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri numarası'**
  String get deviceCustomerNumber;

  /// No description provided for @deviceLastMaintenance.
  ///
  /// In tr, this message translates to:
  /// **'Son bakım'**
  String get deviceLastMaintenance;

  /// No description provided for @deviceNextMaintenanceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki bakım'**
  String get deviceNextMaintenanceLabel;

  /// No description provided for @deviceNoRecordValue.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt yok'**
  String get deviceNoRecordValue;

  /// No description provided for @deviceOverdueDays.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün gecikti'**
  String deviceOverdueDays(int days);

  /// No description provided for @deviceDueToday.
  ///
  /// In tr, this message translates to:
  /// **'Bakım bugün'**
  String get deviceDueToday;

  /// No description provided for @deviceDaysLeft.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün kaldı'**
  String deviceDaysLeft(int days);

  /// No description provided for @deviceNeverServiced.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihaz için henüz bakım yapılmadı'**
  String get deviceNeverServiced;

  /// No description provided for @deviceDelete.
  ///
  /// In tr, this message translates to:
  /// **'Cihazı sil'**
  String get deviceDelete;

  /// No description provided for @deviceDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz silinsin mi?'**
  String get deviceDeleteTitle;

  /// No description provided for @deviceDeleteMessageSimple.
  ///
  /// In tr, this message translates to:
  /// **'{model} cihazı kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String deviceDeleteMessageSimple(String model);

  /// No description provided for @deviceDeleteMessageWithHistory.
  ///
  /// In tr, this message translates to:
  /// **'{model} cihazı ile birlikte {records} bakım kaydı ve {filters} filtre değişimi kalıcı olarak silinecek. Bakım geçmişi geri getirilemez.'**
  String deviceDeleteMessageWithHistory(String model, int records, int filters);

  /// No description provided for @deviceDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz silindi.'**
  String get deviceDeleted;

  /// No description provided for @validationInstalledAtFuture.
  ///
  /// In tr, this message translates to:
  /// **'Kurulum tarihi ileri bir tarih olamaz.'**
  String get validationInstalledAtFuture;

  /// No description provided for @maintenanceAdd.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bakım ekle'**
  String get maintenanceAdd;

  /// No description provided for @maintenanceHistory.
  ///
  /// In tr, this message translates to:
  /// **'Bakım geçmişi'**
  String get maintenanceHistory;

  /// No description provided for @maintenanceHistoryEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bakım kaydı yok'**
  String get maintenanceHistoryEmptyTitle;

  /// No description provided for @maintenanceHistoryEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihaz için ilk bakımı kaydettiğinizde geçmiş burada görünecek.'**
  String get maintenanceHistoryEmptyMessage;

  /// No description provided for @maintenanceRecordNext.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki bakım: {date}'**
  String maintenanceRecordNext(String date);

  /// No description provided for @maintenanceRecordFilters.
  ///
  /// In tr, this message translates to:
  /// **'Değiştirilen filtreler'**
  String get maintenanceRecordFilters;

  /// No description provided for @maintenanceRecordNotes.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get maintenanceRecordNotes;

  /// No description provided for @maintenanceRecordPrice.
  ///
  /// In tr, this message translates to:
  /// **'Ücret'**
  String get maintenanceRecordPrice;

  /// No description provided for @maintenanceFieldDate.
  ///
  /// In tr, this message translates to:
  /// **'Bakım tarihi'**
  String get maintenanceFieldDate;

  /// No description provided for @maintenanceFieldNextDate.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki bakım tarihi'**
  String get maintenanceFieldNextDate;

  /// No description provided for @maintenanceFieldNextDateSuggested.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen: bakım tarihinden 6 ay sonra'**
  String get maintenanceFieldNextDateSuggested;

  /// No description provided for @maintenanceFieldNextDateCustom.
  ///
  /// In tr, this message translates to:
  /// **'Elle seçildi'**
  String get maintenanceFieldNextDateCustom;

  /// No description provided for @maintenanceUseSuggestion.
  ///
  /// In tr, this message translates to:
  /// **'6 ay sonrasını kullan'**
  String get maintenanceUseSuggestion;

  /// No description provided for @maintenanceFieldFilters.
  ///
  /// In tr, this message translates to:
  /// **'Değiştirilen filtreler'**
  String get maintenanceFieldFilters;

  /// No description provided for @maintenanceFieldFiltersHelper.
  ///
  /// In tr, this message translates to:
  /// **'Değiştirilen tüm filtreleri işaretleyin.'**
  String get maintenanceFieldFiltersHelper;

  /// No description provided for @maintenanceFieldPrice.
  ///
  /// In tr, this message translates to:
  /// **'Bakım ücreti'**
  String get maintenanceFieldPrice;

  /// No description provided for @maintenanceFieldPriceHelper.
  ///
  /// In tr, this message translates to:
  /// **'Örn. 1250 veya 1.250,50 (kuruş için virgül)'**
  String get maintenanceFieldPriceHelper;

  /// No description provided for @maintenanceFieldNotes.
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get maintenanceFieldNotes;

  /// No description provided for @maintenanceSaved.
  ///
  /// In tr, this message translates to:
  /// **'Bakım kaydedildi.'**
  String get maintenanceSaved;

  /// No description provided for @maintenanceDeviceHeader.
  ///
  /// In tr, this message translates to:
  /// **'Bakım yapılan cihaz'**
  String get maintenanceDeviceHeader;

  /// No description provided for @validationMaintenanceDateFuture.
  ///
  /// In tr, this message translates to:
  /// **'Bakım tarihi ileri bir tarih olamaz.'**
  String get validationMaintenanceDateFuture;

  /// No description provided for @validationNextBeforeMaintenance.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki bakım tarihi bakım tarihinden önce olamaz.'**
  String get validationNextBeforeMaintenance;

  /// No description provided for @validationFiltersEmpty.
  ///
  /// In tr, this message translates to:
  /// **'En az bir filtre seçin.'**
  String get validationFiltersEmpty;

  /// No description provided for @validationPriceFormat.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar girin (örn. 1.250,50).'**
  String get validationPriceFormat;

  /// No description provided for @validationPriceTooLarge.
  ///
  /// In tr, this message translates to:
  /// **'Tutar en fazla ₺1.000.000,00 olabilir.'**
  String get validationPriceTooLarge;

  /// No description provided for @validationPriceNegative.
  ///
  /// In tr, this message translates to:
  /// **'Tutar negatif olamaz.'**
  String get validationPriceNegative;

  /// No description provided for @filterSediment.
  ///
  /// In tr, this message translates to:
  /// **'Sediment'**
  String get filterSediment;

  /// No description provided for @filterCto.
  ///
  /// In tr, this message translates to:
  /// **'CTO Karbon'**
  String get filterCto;

  /// No description provided for @filterGac.
  ///
  /// In tr, this message translates to:
  /// **'GAC Karbon'**
  String get filterGac;

  /// No description provided for @filterPost.
  ///
  /// In tr, this message translates to:
  /// **'Post Mineral'**
  String get filterPost;

  /// No description provided for @filterMembrane.
  ///
  /// In tr, this message translates to:
  /// **'Membran'**
  String get filterMembrane;

  /// No description provided for @statusOverdue.
  ///
  /// In tr, this message translates to:
  /// **'Gecikti'**
  String get statusOverdue;

  /// No description provided for @statusUpcoming.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşıyor'**
  String get statusUpcoming;

  /// No description provided for @statusScheduled.
  ///
  /// In tr, this message translates to:
  /// **'Planlandı'**
  String get statusScheduled;

  /// No description provided for @statusNoMaintenance.
  ///
  /// In tr, this message translates to:
  /// **'Bakım Kaydı Yok'**
  String get statusNoMaintenance;
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
