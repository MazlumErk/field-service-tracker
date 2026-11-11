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
  String get settingsSectionDemo => 'Demo verileri';

  @override
  String get settingsTagline => 'Offline saha servis ve bakım takibi';

  @override
  String get settingsResetDemo => 'Demo verilerini sıfırla';

  @override
  String get settingsResetDemoSubtitle =>
      'Tüm kayıtları silip başlangıçtaki örnek müşterileri, cihazları ve bakım geçmişini yeniden oluşturur.';

  @override
  String get settingsResetTitle => 'Demo verileri sıfırlansın mı?';

  @override
  String get settingsResetMessage =>
      'Sonradan eklediğiniz müşteriler, cihazlar ve bakım kayıtları dahil tüm veriler kalıcı olarak silinecek ve başlangıçtaki demo verileri yeniden oluşturulacak. Bu işlem geri alınamaz.';

  @override
  String get settingsResetConfirm => 'Sıfırla';

  @override
  String get settingsResetDone => 'Demo verileri yeniden oluşturuldu.';

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

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonMoreActions => 'Diğer işlemler';

  @override
  String get commonOptional => 'isteğe bağlı';

  @override
  String get commonNotProvided => 'Belirtilmemiş';

  @override
  String get errorNotFound => 'Kayıt bulunamadı. Silinmiş olabilir.';

  @override
  String get errorDuplicateCustomerNumber =>
      'Bu müşteri numarası başka bir müşteride kullanılıyor.';

  @override
  String get errorValidation => 'Lütfen işaretli alanları kontrol edin.';

  @override
  String get errorDatabase =>
      'İşlem tamamlanamadı. Verileriniz değişmedi; lütfen tekrar deneyin.';

  @override
  String get errorUnexpected =>
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get errorLoadTitle => 'Veriler yüklenemedi';

  @override
  String get validationRequired => 'Bu alan zorunludur.';

  @override
  String validationTooLong(int max) {
    return 'En fazla $max karakter girebilirsiniz.';
  }

  @override
  String get validationCustomerNumberFormat =>
      'Yalnızca harf (A–Z), rakam ve - _ / . kullanılabilir.';

  @override
  String get validationPhoneFormat =>
      'Geçerli bir telefon numarası girin (10–15 rakam).';

  @override
  String get validationAlreadyInUse =>
      'Bu müşteri numarası başka bir müşteride kullanılıyor.';

  @override
  String get customerSearchHint => 'Ad, soyad veya müşteri no ile ara';

  @override
  String get customerSearchClear => 'Aramayı temizle';

  @override
  String get customerAdd => 'Yeni müşteri';

  @override
  String customerCount(int count) {
    return '$count müşteri';
  }

  @override
  String customerResultCount(int count) {
    return '$count sonuç';
  }

  @override
  String customerDeviceCount(int count) {
    return '$count cihaz';
  }

  @override
  String get customerListEmptyTitle => 'Henüz müşteri yok';

  @override
  String get customerListEmptyMessage =>
      'İlk müşterinizi ekleyerek cihaz ve bakım takibine başlayın.';

  @override
  String get customerNoResultsTitle => 'Sonuç bulunamadı';

  @override
  String customerNoResultsMessage(String query) {
    return '“$query” ile eşleşen müşteri yok. Farklı bir ad veya müşteri numarası deneyin.';
  }

  @override
  String get customerFieldFirstName => 'Ad';

  @override
  String get customerFieldLastName => 'Soyad';

  @override
  String get customerFieldNumber => 'Müşteri numarası';

  @override
  String get customerFieldNumberHelper =>
      'Örn. FST-0021. Boşluklar kaldırılır, büyük harfe çevrilir.';

  @override
  String get customerFieldPhone => 'Telefon';

  @override
  String get customerFieldAddress => 'Adres';

  @override
  String get customerSaved => 'Müşteri kaydedildi.';

  @override
  String get customerUpdated => 'Değişiklikler kaydedildi.';

  @override
  String get customerSectionContact => 'İletişim';

  @override
  String get customerSectionDevices => 'Cihazlar';

  @override
  String get customerDevicesEmptyTitle => 'Kayıtlı cihaz yok';

  @override
  String get customerDevicesEmptyMessage =>
      'Bu müşteriye henüz cihaz eklenmemiş.';

  @override
  String get customerDelete => 'Müşteriyi sil';

  @override
  String get customerDeleteTitle => 'Müşteri silinsin mi?';

  @override
  String customerDeleteMessageSimple(String name) {
    return '$name kalıcı olarak silinecek. Bu işlem geri alınamaz.';
  }

  @override
  String customerDeleteMessageWithRelated(
    String name,
    int devices,
    int records,
  ) {
    return '$name ile birlikte $devices cihaz ve $records bakım kaydı kalıcı olarak silinecek. Bu işlem geri alınamaz.';
  }

  @override
  String get customerDeleted => 'Müşteri silindi.';

  @override
  String get customerRegisteredAt => 'Kayıt tarihi';

  @override
  String deviceSerial(String serial) {
    return 'Seri no: $serial';
  }

  @override
  String deviceNextMaintenance(String date) {
    return 'Sonraki bakım: $date';
  }

  @override
  String get deviceNoMaintenanceYet => 'Henüz bakım yapılmadı';

  @override
  String get unsavedChangesTitle => 'Kaydedilmemiş değişiklikler';

  @override
  String get unsavedChangesMessage =>
      'Yaptığınız değişiklikler kaydedilmedi. Çıkarsanız bu değişiklikler kaybolacak.';

  @override
  String get unsavedChangesDiscard => 'Değişiklikleri At';

  @override
  String get deviceAdd => 'Cihaz ekle';

  @override
  String get deviceFieldModel => 'Cihaz modeli';

  @override
  String get deviceFieldModelHelper => 'Örn. AquaPure RO-5';

  @override
  String get deviceFieldSerial => 'Seri numarası';

  @override
  String get deviceFieldInstalledAt => 'Kurulum tarihi';

  @override
  String get deviceFieldInstalledAtHint => 'Tarih seçmek için dokunun';

  @override
  String get deviceSaved => 'Cihaz kaydedildi.';

  @override
  String get deviceUpdated => 'Cihaz bilgileri güncellendi.';

  @override
  String get deviceSerialMissing => 'Seri numarası belirtilmemiş';

  @override
  String get deviceSectionInfo => 'Cihaz bilgileri';

  @override
  String get deviceCustomer => 'Müşteri';

  @override
  String get deviceCustomerNumber => 'Müşteri numarası';

  @override
  String get deviceLastMaintenance => 'Son bakım';

  @override
  String get deviceNextMaintenanceLabel => 'Sonraki bakım';

  @override
  String get deviceNoRecordValue => 'Kayıt yok';

  @override
  String deviceOverdueDays(int days) {
    return '$days gün gecikti';
  }

  @override
  String get deviceDueToday => 'Bakım bugün';

  @override
  String deviceDaysLeft(int days) {
    return '$days gün kaldı';
  }

  @override
  String get deviceNeverServiced => 'Bu cihaz için henüz bakım yapılmadı';

  @override
  String get deviceDelete => 'Cihazı sil';

  @override
  String get deviceDeleteTitle => 'Cihaz silinsin mi?';

  @override
  String deviceDeleteMessageSimple(String model) {
    return '$model cihazı kalıcı olarak silinecek. Bu işlem geri alınamaz.';
  }

  @override
  String deviceDeleteMessageWithHistory(
    String model,
    int records,
    int filters,
  ) {
    return '$model cihazı ile birlikte $records bakım kaydı ve $filters filtre değişimi kalıcı olarak silinecek. Bakım geçmişi geri getirilemez.';
  }

  @override
  String get deviceDeleted => 'Cihaz silindi.';

  @override
  String get validationInstalledAtFuture =>
      'Kurulum tarihi ileri bir tarih olamaz.';

  @override
  String get maintenanceAdd => 'Yeni bakım ekle';

  @override
  String get maintenanceHistory => 'Bakım geçmişi';

  @override
  String get maintenanceHistoryEmptyTitle => 'Henüz bakım kaydı yok';

  @override
  String get maintenanceHistoryEmptyMessage =>
      'Bu cihaz için ilk bakımı kaydettiğinizde geçmiş burada görünecek.';

  @override
  String maintenanceRecordNext(String date) {
    return 'Sonraki bakım: $date';
  }

  @override
  String get maintenanceRecordFilters => 'Değiştirilen filtreler';

  @override
  String get maintenanceRecordNotes => 'Not';

  @override
  String get maintenanceRecordPrice => 'Ücret';

  @override
  String get maintenanceFieldDate => 'Bakım tarihi';

  @override
  String get maintenanceFieldNextDate => 'Sonraki bakım tarihi';

  @override
  String get maintenanceFieldNextDateSuggested =>
      'Önerilen: bakım tarihinden 6 ay sonra';

  @override
  String get maintenanceFieldNextDateCustom => 'Elle seçildi';

  @override
  String get maintenanceUseSuggestion => '6 ay sonrasını kullan';

  @override
  String get maintenanceFieldFilters => 'Değiştirilen filtreler';

  @override
  String get maintenanceFieldFiltersHelper =>
      'Değiştirilen tüm filtreleri işaretleyin.';

  @override
  String get maintenanceFieldPrice => 'Bakım ücreti';

  @override
  String get maintenanceFieldPriceHelper => 'Örn. 1250, 1.250,50 veya 1250.50';

  @override
  String get maintenanceFieldNotes => 'Notlar';

  @override
  String get maintenanceSaved => 'Bakım kaydedildi.';

  @override
  String get maintenanceDeviceHeader => 'Bakım yapılan cihaz';

  @override
  String get validationMaintenanceDateFuture =>
      'Bakım tarihi ileri bir tarih olamaz.';

  @override
  String get validationNextBeforeMaintenance =>
      'Sonraki bakım tarihi bakım tarihinden önce olamaz.';

  @override
  String get validationFiltersEmpty => 'En az bir filtre seçin.';

  @override
  String get validationPriceFormat =>
      'Geçerli bir tutar girin (örn. 1.250,50 veya 1250.50).';

  @override
  String get validationPriceTooLarge =>
      'Tutar en fazla ₺1.000.000,00 olabilir.';

  @override
  String get validationPriceNegative => 'Tutar negatif olamaz.';

  @override
  String get filterSediment => 'Sediment';

  @override
  String get filterCto => 'CTO Karbon';

  @override
  String get filterGac => 'GAC Karbon';

  @override
  String get filterPost => 'Post Mineral';

  @override
  String get filterMembrane => 'Membran';

  @override
  String dashboardToday(String date) {
    return 'Bugün: $date';
  }

  @override
  String get dashboardKpiCustomers => 'Müşteri';

  @override
  String get dashboardKpiDevices => 'Cihaz';

  @override
  String get dashboardKpiOverdue => 'Geciken bakım';

  @override
  String get dashboardKpiUpcoming => 'Yaklaşan bakım';

  @override
  String get dashboardKpiUpcomingHint => '30 gün içinde';

  @override
  String get dashboardPriorityTitle => 'Öncelikli Bakımlar';

  @override
  String get dashboardSeeAll => 'Tüm Bakımları Gör';

  @override
  String dashboardPriorityMore(int count, int shown) {
    return '$count öncelikli bakımdan $shown tanesi gösteriliyor';
  }

  @override
  String get dashboardPriorityEmptyTitle => 'Öncelikli bakım yok';

  @override
  String get dashboardPriorityEmptyMessage =>
      'Geciken veya 30 gün içinde yaklaşan bakım bulunmuyor.';

  @override
  String get dashboardEmptyTitle => 'Henüz kayıt yok';

  @override
  String get dashboardEmptyMessage =>
      'İlk müşterinizi ve cihazını ekleyerek bakım takibine başlayın.';

  @override
  String get maintenanceFilterAll => 'Tümü';

  @override
  String get maintenanceFilterOverdue => 'Geciken';

  @override
  String get maintenanceFilterUpcoming => 'Yaklaşan';

  @override
  String get maintenanceFilterScheduled => 'Planlanan';

  @override
  String get maintenanceFilterNoRecord => 'Bakım Kaydı Yok';

  @override
  String maintenanceFilterWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get maintenanceListNoDevicesTitle => 'Henüz cihaz yok';

  @override
  String get maintenanceListNoDevicesMessage =>
      'Müşterilere cihaz eklediğinizde bakım durumları burada listelenir.';

  @override
  String get maintenanceListFilterEmptyTitle => 'Bu durumda cihaz yok';

  @override
  String get maintenanceListFilterEmptyMessage =>
      'Seçili duruma uyan cihaz bulunmuyor. Başka bir filtre seçin.';

  @override
  String get statusOverdue => 'Gecikti';

  @override
  String get statusUpcoming => 'Yaklaşıyor';

  @override
  String get statusScheduled => 'Planlandı';

  @override
  String get statusNoMaintenance => 'Bakım Kaydı Yok';
}
