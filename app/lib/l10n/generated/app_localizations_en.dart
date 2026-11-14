// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DhammaWave';

  @override
  String get navHome => 'Home';

  @override
  String get navBrowse => 'Browse';

  @override
  String get navSearch => 'Search';

  @override
  String get navLibrary => 'Library';

  @override
  String get homeSearchHint => 'Search dhamma talks...';

  @override
  String get homeFeatured => 'Featured Dhamma';

  @override
  String get homeTeachers => 'Teachers';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeLatest => 'Latest Dhamma';

  @override
  String get homeLoading => 'Loading dhamma talks...';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsVersionValue => '1.0.0 MVP';

  @override
  String get settingsBackgroundPlayback => 'Background playback';

  @override
  String get settingsBackgroundPlaybackValue => 'Always available';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageBurmese => 'Burmese';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsLegalSection => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyLastUpdated => 'Last updated: November 2026';

  @override
  String get privacyIntro =>
      'This Privacy Policy explains how Buddha Dhamma (\"the app\") handles your information. The app is a Dhamma audio catalog for listening and publishing. By using the app, you agree to this policy.';

  @override
  String get privacyDataTitle => 'Information we collect';

  @override
  String get privacyDataBody =>
      'The app does not require an account and does not collect personal information such as your name, email address, or phone number. We do not use advertising identifiers, analytics SDKs, or tracking tools.';

  @override
  String get privacyLocalTitle => 'Information stored on your device';

  @override
  String get privacyLocalBody =>
      'Your language preference, saved favorites, playback progress, and downloaded audio are stored only on your device. You can remove downloads at any time from the Downloads tab, and clearing the app\'s data removes all locally stored information.';

  @override
  String get privacyNetworkTitle => 'Network requests';

  @override
  String get privacyNetworkBody =>
      'The app connects to our catalog server to load dhamma talks, cover images, and audio streams. Like most internet services, the server may temporarily process standard technical data such as your IP address, device type, and request time to deliver content and keep the service secure. This data is not used to identify you personally.';

  @override
  String get privacySharingTitle => 'Sharing of information';

  @override
  String get privacySharingBody =>
      'We do not sell, rent, or share your information with third parties. The app does not include third-party advertising or social media tracking.';

  @override
  String get privacyChildrenTitle => 'Children\'s privacy';

  @override
  String get privacyChildrenBody =>
      'The app is suitable for general audiences, including children. Because we do not collect personal information, we do not knowingly collect data from children.';

  @override
  String get privacyChangesTitle => 'Changes to this policy';

  @override
  String get privacyChangesBody =>
      'We may update this policy from time to time. Changes take effect when the updated policy is available in the app. Continued use of the app after an update means you accept the revised policy.';

  @override
  String get privacyContactTitle => 'Contact us';

  @override
  String get privacyContactBody =>
      'If you have questions about this Privacy Policy, please contact us using the contact details listed on the app store page.';

  @override
  String get libraryTitle => 'Saved';

  @override
  String get libraryFavoritesTab => 'Favorites';

  @override
  String get libraryDownloadsTab => 'Downloads';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptySubtitle =>
      'Save dhamma talks you love to find them here.';

  @override
  String get filesNotFoundTitle => 'Nothing found';

  @override
  String get filesNotFoundSubtitle => 'Please wait a moment and try again.';

  @override
  String get downloadsReadError => 'Unable to read downloaded audio.';

  @override
  String get downloadsEmpty =>
      'No downloads yet.\nYou can download from an audio\'s detail page.';

  @override
  String get downloadsInProgress => 'Downloading';

  @override
  String get downloadsCompleted => 'Downloaded';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get downloadFailedStatus => 'Failed';

  @override
  String get downloadPausedStatus => 'Paused';

  @override
  String get downloadInProgressStatus => 'Downloading';

  @override
  String get retryTooltip => 'Retry';

  @override
  String get resumeTooltip => 'Resume';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get cancelTooltip => 'Cancel';

  @override
  String get browseTitle => 'Browse';

  @override
  String get browseEmptyTitle => 'No dhamma talks found';

  @override
  String get browseEmptySubtitle => 'Try changing the filters.';

  @override
  String get filterClear => 'Clear filters';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterType => 'Type';

  @override
  String get filterTeacher => 'Teacher';

  @override
  String get detailListening => 'Playing';

  @override
  String get detailListen => 'Listen';

  @override
  String get detailDescription => 'Description';

  @override
  String get detailDownloadedTooltip => 'Saved for offline';

  @override
  String get detailDownloadTooltip => 'Download';

  @override
  String get detailDownloadStarted => 'Download started';

  @override
  String get detailDownloadFailed => 'Download failed. Please try again.';

  @override
  String detailMoreFromTeacher(String teacher) {
    return 'More from $teacher';
  }

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search titles or teachers...';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchClear => 'Clear';

  @override
  String get searchEmptyTitle => 'Search dhamma talks';

  @override
  String get searchEmptySubtitle => 'Search by title or teacher name.';

  @override
  String get searchNoResultsTitle => 'No results';

  @override
  String get searchNoResultsSubtitle => 'Try searching with a different word.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorNetworkSubtitle => 'Check your connection and try again.';

  @override
  String get errorRetry => 'Retry';

  @override
  String get offlineTitle => 'Downloads';

  @override
  String get playAllTooltip => 'Play all downloads';

  @override
  String get playerNowPlaying => 'Now playing';

  @override
  String get playerRewind10 => '10s back';

  @override
  String playerQueue(int count) {
    return 'Queue ($count)';
  }

  @override
  String get playerDetails => 'Details';

  @override
  String get playerSpeedTitle => 'Playback speed';

  @override
  String get playerQueueTitle => 'Play queue';

  @override
  String get playerQueueEmpty => 'Queue is empty';

  @override
  String get playerErrorNetwork => 'Network connection is weak.';

  @override
  String get playerErrorSource => 'Unable to play this audio.';

  @override
  String get playerErrorGeneric => 'An error occurred during playback.';
}
