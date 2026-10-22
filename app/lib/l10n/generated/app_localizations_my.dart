// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'ဗုဒ္ဓသံသာ';

  @override
  String get navHome => 'ပင်မ';

  @override
  String get navBrowse => 'ရှာဖွေ';

  @override
  String get navSearch => 'ရှာရန်';

  @override
  String get navLibrary => 'သိမ်းဆည်း';

  @override
  String get homeSearchHint => 'တရားတော် ရှာမည်...';

  @override
  String get homeFeatured => 'ထူးခြားသော တရားတော်များ';

  @override
  String get homeTeachers => 'ဆရာတော်များ';

  @override
  String get homeCategories => 'အမျိုးအစားများ';

  @override
  String get homeLatest => 'အသစ်ထွက် တရားတော်များ';

  @override
  String get homeLoading => 'တရားတော်များ ရယူနေသည်...';

  @override
  String durationMinutes(int minutes) {
    return '$minutes မိနစ်';
  }

  @override
  String get settingsTitle => 'ဆက်တင်များ';

  @override
  String get settingsAppSection => 'အက်ပ်';

  @override
  String get settingsVersion => 'ဗားရှင်း';

  @override
  String get settingsVersionValue => '1.0.0 MVP';

  @override
  String get settingsBackgroundPlayback => 'နောက်ခံဖွင့်ခြင်း';

  @override
  String get settingsBackgroundPlaybackValue => 'အမြဲဖွင့်ထားနိုင်သည်';

  @override
  String get settingsLanguage => 'ဘာသာစကား';

  @override
  String get languageBurmese => 'မြန်မာ';

  @override
  String get languageEnglish => 'English';

  @override
  String get libraryTitle => 'သိမ်းဆည်းထားသည်';

  @override
  String get libraryFavoritesTab => 'ကြိုက်နှစ်သက်';

  @override
  String get libraryDownloadsTab => 'ဒေါင်းလုဒ်';

  @override
  String get favoritesEmptyTitle => 'ကြိုက်နှစ်သက်သော မရှိသေးပါ';

  @override
  String get favoritesEmptySubtitle =>
      'နှစ်သက်သော တရားတော်များကို နှလုံးသွင်း သိမ်းဆည်းနိုင်ပါသည်။';

  @override
  String get filesNotFoundTitle => 'ဖိုင်များ ရှာမတွေ့ပါ';

  @override
  String get filesNotFoundSubtitle => 'ခဏစောင့်ပြီး ထပ်ကြည့်ပါ။';

  @override
  String get downloadsReadError => 'သိမ်းထားသော အသံများကို ဖတ်မရပါ';

  @override
  String get downloadsEmpty =>
      'ဒေါင်းလုဒ်ထားသော အသံ မရှိသေးပါ။\nအသံအသေးစိတ်စာမျက်နှာမှ ဒေါင်းလုဒ်လုပ်နိုင်ပါသည်။';

  @override
  String get downloadsInProgress => 'ဒေါင်းလုဒ်လုပ်နေသည်';

  @override
  String get downloadsCompleted => 'ဒေါင်းလုဒ်ပြီး';

  @override
  String get deleteTooltip => 'ဖျက်ရန်';

  @override
  String get downloadFailedStatus => 'မအောင်မြင်ပါ';

  @override
  String get downloadPausedStatus => 'ခေတ္တရပ်ထားသည်';

  @override
  String get downloadInProgressStatus => 'ဒေါင်းလုဒ်လုပ်နေသည်';

  @override
  String get retryTooltip => 'ထပ်စမ်းရန်';

  @override
  String get resumeTooltip => 'ဆက်လုပ်ရန်';

  @override
  String get pauseTooltip => 'ခေတ္တရပ်ရန်';

  @override
  String get cancelTooltip => 'ပယ်ဖျက်ရန်';

  @override
  String get browseTitle => 'ရှာဖွေရန်';

  @override
  String get browseEmptyTitle => 'တရားတော် မတွေ့ပါ';

  @override
  String get browseEmptySubtitle => 'စစ်ထုတ်မှုများကို ပြောင်းလဲကြည့်ပါ။';

  @override
  String get filterClear => 'စစ်ထုတ်မှု ဖျက်';

  @override
  String get filterCategory => 'အမျိုးအစား';

  @override
  String get filterType => 'အမျိုးအစား(type)';

  @override
  String get filterTeacher => 'ဆရာတော်';

  @override
  String get detailListening => 'ဖွင့်နေသည်';

  @override
  String get detailListen => 'နားထောင်မည်';

  @override
  String get detailDescription => 'ဖော်ပြချက်';

  @override
  String get detailDownloadedTooltip => 'အော့ဖ်လိုင်းအတွက် သိမ်းပြီး';

  @override
  String get detailDownloadTooltip => 'ဒေါင်းလုဒ်လုပ်ရန်';

  @override
  String get detailDownloadStarted => 'ဒေါင်းလုဒ် စတင်ပါပြီ';

  @override
  String get detailDownloadFailed => 'ဒေါင်းလုဒ် မအောင်မြင်ပါ။ ထပ်စမ်းကြည့်ပါ။';

  @override
  String detailMoreFromTeacher(String teacher) {
    return '$teacher၏ အခြားတရားတော်များ';
  }

  @override
  String get searchTitle => 'ရှာဖွေရန်';

  @override
  String get searchHint => 'ခေါင်းစဉ်၊ ဆရာတော် ရှာရန်...';

  @override
  String get searchRecent => 'မကြာသေးမီက ရှာဖွေမှုများ';

  @override
  String get searchClear => 'ဖျက်';

  @override
  String get searchEmptyTitle => 'တရားတော် ရှာဖွေပါ';

  @override
  String get searchEmptySubtitle =>
      'ခေါင်းစဉ် သို့မဟုတ် ဆရာတော်အမည်ဖြင့် ရှာနိုင်ပါသည်။';

  @override
  String get searchNoResultsTitle => 'တွေ့မတွေ့ပါ';

  @override
  String get searchNoResultsSubtitle => 'အခြားစကားလုံးဖြင့် ထပ်ရှာကြည့်ပါ။';

  @override
  String get errorTitle => 'တစ်စုံတစ်ရာ မှားယွင်းနေပါသည်';

  @override
  String get errorNetworkSubtitle =>
      'ကွန်ရက် ချိတ်ဆက်မှုကို စစ်ဆေးပြီး ထပ်စမ်းပါ။';

  @override
  String get errorRetry => 'ထပ်စမ်းမည်';

  @override
  String get offlineTitle => 'ဒေါင်းလုဒ်များ';

  @override
  String get playAllTooltip => 'ဒေါင်းလုဒ်အားလုံး ဖွင့်ရန်';

  @override
  String get playerNowPlaying => 'နားထောင်နေသည်';

  @override
  String get playerRewind10 => '၁၀ စက္ကန့် နောက်';

  @override
  String playerQueue(int count) {
    return 'စာရင်း ($count)';
  }

  @override
  String get playerDetails => 'အသေးစိတ်';

  @override
  String get playerSpeedTitle => 'ဖွင့်နှုန်း';

  @override
  String get playerQueueTitle => 'နားထောင်စာရင်း';

  @override
  String get playerQueueEmpty => 'စာရင်း မရှိသေးပါ';

  @override
  String get playerErrorNetwork => 'ကွန်ရက် ချိတ်ဆက်မှု အားနည်းနေပါသည်။';

  @override
  String get playerErrorSource => 'အသံဖိုင် ဖွင့်၍ မရပါ။';

  @override
  String get playerErrorGeneric => 'အသံဖွင့်ရာတွင် အမှားဖြစ်ပွားပါသည်။';
}
