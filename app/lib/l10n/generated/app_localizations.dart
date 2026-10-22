import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('my'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In my, this message translates to:
  /// **'ဗုဒ္ဓသံသာ'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In my, this message translates to:
  /// **'ပင်မ'**
  String get navHome;

  /// No description provided for @navBrowse.
  ///
  /// In my, this message translates to:
  /// **'ရှာဖွေ'**
  String get navBrowse;

  /// No description provided for @navSearch.
  ///
  /// In my, this message translates to:
  /// **'ရှာရန်'**
  String get navSearch;

  /// No description provided for @navLibrary.
  ///
  /// In my, this message translates to:
  /// **'သိမ်းဆည်း'**
  String get navLibrary;

  /// No description provided for @homeSearchHint.
  ///
  /// In my, this message translates to:
  /// **'တရားတော် ရှာမည်...'**
  String get homeSearchHint;

  /// No description provided for @homeFeatured.
  ///
  /// In my, this message translates to:
  /// **'ထူးခြားသော တရားတော်များ'**
  String get homeFeatured;

  /// No description provided for @homeTeachers.
  ///
  /// In my, this message translates to:
  /// **'ဆရာတော်များ'**
  String get homeTeachers;

  /// No description provided for @homeCategories.
  ///
  /// In my, this message translates to:
  /// **'အမျိုးအစားများ'**
  String get homeCategories;

  /// No description provided for @homeLatest.
  ///
  /// In my, this message translates to:
  /// **'အသစ်ထွက် တရားတော်များ'**
  String get homeLatest;

  /// No description provided for @homeLoading.
  ///
  /// In my, this message translates to:
  /// **'တရားတော်များ ရယူနေသည်...'**
  String get homeLoading;

  /// No description provided for @durationMinutes.
  ///
  /// In my, this message translates to:
  /// **'{minutes} မိနစ်'**
  String durationMinutes(int minutes);

  /// No description provided for @settingsTitle.
  ///
  /// In my, this message translates to:
  /// **'ဆက်တင်များ'**
  String get settingsTitle;

  /// No description provided for @settingsAppSection.
  ///
  /// In my, this message translates to:
  /// **'အက်ပ်'**
  String get settingsAppSection;

  /// No description provided for @settingsVersion.
  ///
  /// In my, this message translates to:
  /// **'ဗားရှင်း'**
  String get settingsVersion;

  /// No description provided for @settingsVersionValue.
  ///
  /// In my, this message translates to:
  /// **'1.0.0 MVP'**
  String get settingsVersionValue;

  /// No description provided for @settingsBackgroundPlayback.
  ///
  /// In my, this message translates to:
  /// **'နောက်ခံဖွင့်ခြင်း'**
  String get settingsBackgroundPlayback;

  /// No description provided for @settingsBackgroundPlaybackValue.
  ///
  /// In my, this message translates to:
  /// **'အမြဲဖွင့်ထားနိုင်သည်'**
  String get settingsBackgroundPlaybackValue;

  /// No description provided for @settingsLanguage.
  ///
  /// In my, this message translates to:
  /// **'ဘာသာစကား'**
  String get settingsLanguage;

  /// No description provided for @languageBurmese.
  ///
  /// In my, this message translates to:
  /// **'မြန်မာ'**
  String get languageBurmese;

  /// No description provided for @languageEnglish.
  ///
  /// In my, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @libraryTitle.
  ///
  /// In my, this message translates to:
  /// **'သိမ်းဆည်းထားသည်'**
  String get libraryTitle;

  /// No description provided for @libraryFavoritesTab.
  ///
  /// In my, this message translates to:
  /// **'ကြိုက်နှစ်သက်'**
  String get libraryFavoritesTab;

  /// No description provided for @libraryDownloadsTab.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ်'**
  String get libraryDownloadsTab;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In my, this message translates to:
  /// **'ကြိုက်နှစ်သက်သော မရှိသေးပါ'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In my, this message translates to:
  /// **'နှစ်သက်သော တရားတော်များကို နှလုံးသွင်း သိမ်းဆည်းနိုင်ပါသည်။'**
  String get favoritesEmptySubtitle;

  /// No description provided for @filesNotFoundTitle.
  ///
  /// In my, this message translates to:
  /// **'ဖိုင်များ ရှာမတွေ့ပါ'**
  String get filesNotFoundTitle;

  /// No description provided for @filesNotFoundSubtitle.
  ///
  /// In my, this message translates to:
  /// **'ခဏစောင့်ပြီး ထပ်ကြည့်ပါ။'**
  String get filesNotFoundSubtitle;

  /// No description provided for @downloadsReadError.
  ///
  /// In my, this message translates to:
  /// **'သိမ်းထားသော အသံများကို ဖတ်မရပါ'**
  String get downloadsReadError;

  /// No description provided for @downloadsEmpty.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ်ထားသော အသံ မရှိသေးပါ။\nအသံအသေးစိတ်စာမျက်နှာမှ ဒေါင်းလုဒ်လုပ်နိုင်ပါသည်။'**
  String get downloadsEmpty;

  /// No description provided for @downloadsInProgress.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ်လုပ်နေသည်'**
  String get downloadsInProgress;

  /// No description provided for @downloadsCompleted.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ်ပြီး'**
  String get downloadsCompleted;

  /// No description provided for @deleteTooltip.
  ///
  /// In my, this message translates to:
  /// **'ဖျက်ရန်'**
  String get deleteTooltip;

  /// No description provided for @downloadFailedStatus.
  ///
  /// In my, this message translates to:
  /// **'မအောင်မြင်ပါ'**
  String get downloadFailedStatus;

  /// No description provided for @downloadPausedStatus.
  ///
  /// In my, this message translates to:
  /// **'ခေတ္တရပ်ထားသည်'**
  String get downloadPausedStatus;

  /// No description provided for @downloadInProgressStatus.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ်လုပ်နေသည်'**
  String get downloadInProgressStatus;

  /// No description provided for @retryTooltip.
  ///
  /// In my, this message translates to:
  /// **'ထပ်စမ်းရန်'**
  String get retryTooltip;

  /// No description provided for @resumeTooltip.
  ///
  /// In my, this message translates to:
  /// **'ဆက်လုပ်ရန်'**
  String get resumeTooltip;

  /// No description provided for @pauseTooltip.
  ///
  /// In my, this message translates to:
  /// **'ခေတ္တရပ်ရန်'**
  String get pauseTooltip;

  /// No description provided for @cancelTooltip.
  ///
  /// In my, this message translates to:
  /// **'ပယ်ဖျက်ရန်'**
  String get cancelTooltip;

  /// No description provided for @browseTitle.
  ///
  /// In my, this message translates to:
  /// **'ရှာဖွေရန်'**
  String get browseTitle;

  /// No description provided for @browseEmptyTitle.
  ///
  /// In my, this message translates to:
  /// **'တရားတော် မတွေ့ပါ'**
  String get browseEmptyTitle;

  /// No description provided for @browseEmptySubtitle.
  ///
  /// In my, this message translates to:
  /// **'စစ်ထုတ်မှုများကို ပြောင်းလဲကြည့်ပါ။'**
  String get browseEmptySubtitle;

  /// No description provided for @filterClear.
  ///
  /// In my, this message translates to:
  /// **'စစ်ထုတ်မှု ဖျက်'**
  String get filterClear;

  /// No description provided for @filterCategory.
  ///
  /// In my, this message translates to:
  /// **'အမျိုးအစား'**
  String get filterCategory;

  /// No description provided for @filterType.
  ///
  /// In my, this message translates to:
  /// **'အမျိုးအစား(type)'**
  String get filterType;

  /// No description provided for @filterTeacher.
  ///
  /// In my, this message translates to:
  /// **'ဆရာတော်'**
  String get filterTeacher;

  /// No description provided for @detailListening.
  ///
  /// In my, this message translates to:
  /// **'ဖွင့်နေသည်'**
  String get detailListening;

  /// No description provided for @detailListen.
  ///
  /// In my, this message translates to:
  /// **'နားထောင်မည်'**
  String get detailListen;

  /// No description provided for @detailDescription.
  ///
  /// In my, this message translates to:
  /// **'ဖော်ပြချက်'**
  String get detailDescription;

  /// No description provided for @detailDownloadedTooltip.
  ///
  /// In my, this message translates to:
  /// **'အော့ဖ်လိုင်းအတွက် သိမ်းပြီး'**
  String get detailDownloadedTooltip;

  /// No description provided for @detailDownloadTooltip.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ်လုပ်ရန်'**
  String get detailDownloadTooltip;

  /// No description provided for @detailDownloadStarted.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ် စတင်ပါပြီ'**
  String get detailDownloadStarted;

  /// No description provided for @detailDownloadFailed.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ် မအောင်မြင်ပါ။ ထပ်စမ်းကြည့်ပါ။'**
  String get detailDownloadFailed;

  /// No description provided for @detailMoreFromTeacher.
  ///
  /// In my, this message translates to:
  /// **'{teacher}၏ အခြားတရားတော်များ'**
  String detailMoreFromTeacher(String teacher);

  /// No description provided for @searchTitle.
  ///
  /// In my, this message translates to:
  /// **'ရှာဖွေရန်'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In my, this message translates to:
  /// **'ခေါင်းစဉ်၊ ဆရာတော် ရှာရန်...'**
  String get searchHint;

  /// No description provided for @searchRecent.
  ///
  /// In my, this message translates to:
  /// **'မကြာသေးမီက ရှာဖွေမှုများ'**
  String get searchRecent;

  /// No description provided for @searchClear.
  ///
  /// In my, this message translates to:
  /// **'ဖျက်'**
  String get searchClear;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In my, this message translates to:
  /// **'တရားတော် ရှာဖွေပါ'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In my, this message translates to:
  /// **'ခေါင်းစဉ် သို့မဟုတ် ဆရာတော်အမည်ဖြင့် ရှာနိုင်ပါသည်။'**
  String get searchEmptySubtitle;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In my, this message translates to:
  /// **'တွေ့မတွေ့ပါ'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In my, this message translates to:
  /// **'အခြားစကားလုံးဖြင့် ထပ်ရှာကြည့်ပါ။'**
  String get searchNoResultsSubtitle;

  /// No description provided for @errorTitle.
  ///
  /// In my, this message translates to:
  /// **'တစ်စုံတစ်ရာ မှားယွင်းနေပါသည်'**
  String get errorTitle;

  /// No description provided for @errorNetworkSubtitle.
  ///
  /// In my, this message translates to:
  /// **'ကွန်ရက် ချိတ်ဆက်မှုကို စစ်ဆေးပြီး ထပ်စမ်းပါ။'**
  String get errorNetworkSubtitle;

  /// No description provided for @errorRetry.
  ///
  /// In my, this message translates to:
  /// **'ထပ်စမ်းမည်'**
  String get errorRetry;

  /// No description provided for @offlineTitle.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ်များ'**
  String get offlineTitle;

  /// No description provided for @playAllTooltip.
  ///
  /// In my, this message translates to:
  /// **'ဒေါင်းလုဒ်အားလုံး ဖွင့်ရန်'**
  String get playAllTooltip;

  /// No description provided for @playerNowPlaying.
  ///
  /// In my, this message translates to:
  /// **'နားထောင်နေသည်'**
  String get playerNowPlaying;

  /// No description provided for @playerRewind10.
  ///
  /// In my, this message translates to:
  /// **'၁၀ စက္ကန့် နောက်'**
  String get playerRewind10;

  /// No description provided for @playerQueue.
  ///
  /// In my, this message translates to:
  /// **'စာရင်း ({count})'**
  String playerQueue(int count);

  /// No description provided for @playerDetails.
  ///
  /// In my, this message translates to:
  /// **'အသေးစိတ်'**
  String get playerDetails;

  /// No description provided for @playerSpeedTitle.
  ///
  /// In my, this message translates to:
  /// **'ဖွင့်နှုန်း'**
  String get playerSpeedTitle;

  /// No description provided for @playerQueueTitle.
  ///
  /// In my, this message translates to:
  /// **'နားထောင်စာရင်း'**
  String get playerQueueTitle;

  /// No description provided for @playerQueueEmpty.
  ///
  /// In my, this message translates to:
  /// **'စာရင်း မရှိသေးပါ'**
  String get playerQueueEmpty;

  /// No description provided for @playerErrorNetwork.
  ///
  /// In my, this message translates to:
  /// **'ကွန်ရက် ချိတ်ဆက်မှု အားနည်းနေပါသည်။'**
  String get playerErrorNetwork;

  /// No description provided for @playerErrorSource.
  ///
  /// In my, this message translates to:
  /// **'အသံဖိုင် ဖွင့်၍ မရပါ။'**
  String get playerErrorSource;

  /// No description provided for @playerErrorGeneric.
  ///
  /// In my, this message translates to:
  /// **'အသံဖွင့်ရာတွင် အမှားဖြစ်ပွားပါသည်။'**
  String get playerErrorGeneric;
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
      <String>['en', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'my':
      return AppLocalizationsMy();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
