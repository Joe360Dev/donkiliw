// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'English';

  @override
  String get appName => 'Donkiliw';

  @override
  String appDescription(String appName) {
    return '$appName allows you to explore and sing your local hymns in Bamanakan and Dogon (currently under development).\nEnjoy features such as advanced search, grouping by themes, creating collections, and exporting hymns as images to share with your loved ones.\nOur mission is to preserve and promote spiritual musical culture.';
  }

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get home => 'Home';

  @override
  String get themes => 'Themes';

  @override
  String get collections => 'Collections';

  @override
  String get settings => 'Settings';

  @override
  String get favorites => 'Favorites';

  @override
  String get appearancePageTitle => 'Appearance & Theme';

  @override
  String get welcomeToDonkiliw => 'Welcome to Donkiliw';

  @override
  String get exploreByTheme => 'Explore by Theme';

  @override
  String get myCollections => 'My Collections';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get loadingText => 'Loading in progress...';

  @override
  String get loadingCollections => 'Loading collections...';

  @override
  String get errorText => 'An error occurred';

  @override
  String get errorTryAgain => 'Error: Please try again.';

  @override
  String get errorWhenLoadingCollections =>
      'Error: Unable to load your collections';

  @override
  String get errorWhenLoadingHymns => 'Error: Unable to load your hymns';

  @override
  String get errorWhenLoadingThemes => 'Error: Unable to load your themes';

  @override
  String get errorWhenLoadingBooks => 'Error: Unable to load your books';

  @override
  String get errorWhenLoadingHymn => 'Error: Unable to load your hymn';

  @override
  String get errorWhenCopying => 'Error when copying';

  @override
  String get imageExportationFailedMessage => 'Image exportation failed';

  @override
  String get generatingImage => 'Generating image...';

  @override
  String get unableToOpenMailClient => 'Unable to open mail client.';

  @override
  String get emptyText => 'No data available';

  @override
  String get emptyTextCreateCollection => 'Create your first collection';

  @override
  String get noResult => 'No result';

  @override
  String get noHymnFound => 'No hymn found';

  @override
  String get noTitle => 'No title';

  @override
  String get noTitleCollection => 'No title collection';

  @override
  String get noDescription => 'No description';

  @override
  String get createYourFirstCollection => 'Create your first collection';

  @override
  String get addHymnsToYourCollection => 'Add hymns to your collection';

  @override
  String get createNewCollection => 'Create a new collection';

  @override
  String get addHymns => 'Add hymns';

  @override
  String addToCollection(int count) {
    return 'Add to collection ($count)';
  }

  @override
  String get exploreThemes => 'Explore Themes';

  @override
  String get exploreBooks => 'Hymn Books';

  @override
  String get seeMore => 'See More';

  @override
  String get seeLess => 'See Less';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get editCollection => 'Edit Collection';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get exportAsImage => 'Export as Image';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get retry => 'Retry';

  @override
  String hymnsAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hymns added to collections',
      one: 'Hymn added to collection',
    );
    return '$_temp0';
  }

  @override
  String get hymnRemovedFromCollection => 'Hymn removed from collection';

  @override
  String get collectionDeleted => 'Collection deleted';

  @override
  String get hymnShared => 'Hymn shared!';

  @override
  String get hymnCopied => 'Hymn copied!';

  @override
  String get hymnExported => 'Hymn exported!';

  @override
  String get imageSavedToGallery => 'Image saved to gallery!';

  @override
  String toggleLikeResponseMessage(String likeStatus) {
    String _temp0 = intl.Intl.selectLogic(
      likeStatus,
      {
        'liked': 'Hymn added to favorites!',
        'unliked': 'Hymn removed from favorites!',
        'other': 'An error occurred. Please retry!',
      },
    );
    return '$_temp0';
  }

  @override
  String hymnsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hymns',
      one: '1 hymn',
      zero: 'No hymns',
    );
    return '$_temp0';
  }

  @override
  String countResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No result',
    );
    return '$_temp0';
  }

  @override
  String createdAt(String date) {
    return 'Created on $date';
  }

  @override
  String signature(String appName) {
    return 'Generated with $appName';
  }

  @override
  String get searchAnHymn => 'Search a hymn...';

  @override
  String get searchCollection => 'Search a collection...';

  @override
  String get collectionName => 'Collection Name';

  @override
  String get selectionCollection => 'Select a collection';

  @override
  String get collectionDescription => 'Description of the collection';

  @override
  String get result => 'Result';

  @override
  String get hymn => 'Hymn';

  @override
  String get hymns => 'Hymns';

  @override
  String get number => 'Number';

  @override
  String get title => 'Title';

  @override
  String get book => 'Book';

  @override
  String get collection => 'Collection';

  @override
  String get description => 'Description';

  @override
  String get languageLabel => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get mode => 'Mode';

  @override
  String get darkMode => 'Dark';

  @override
  String get lightMode => 'Light';

  @override
  String get systemMode => 'System';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get fontSize => 'Font Size';

  @override
  String get repeatRefrain => 'Repeat Refrain';

  @override
  String get repeatRefrainDescription => 'Repeat the refrain after each verse';

  @override
  String get connectedMode => 'Connected Mode';

  @override
  String get connectedModeDescription =>
      'Celebrate the LORD in community with your friends and family.';

  @override
  String get about => 'About';

  @override
  String get developer => 'Developer';

  @override
  String get appDeveloperText => 'Developed by Joe Dev';

  @override
  String get developerDescription => 'Another victory for the LORD.';

  @override
  String get supports => 'Supported by';

  @override
  String get supportsDescription =>
      'Big thanks to Idrissa Pierre Diarra for sharing his local hymns database.';

  @override
  String get contact => 'Contact';

  @override
  String get contactDescription =>
      'If you have any questions, feedback, suggestions, or want to contribute to the app, please don\'t hesitate to reach out to me.';

  @override
  String get donkiliwQuote => 'All that breathes praise the LORD.';

  @override
  String get donkiliwQuoteReference => 'Psalm 150:6';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String permissionRequiredMessage(String permission, String reason) {
    return '$permission permission is required $reason. Please enable it in app settings.';
  }

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String permissionDeniedMessage(String permission, String reason) {
    return '$permission permission was denied. This is required $reason. Would you like to try again?';
  }

  @override
  String get storagePermission => 'Storage';

  @override
  String get photosPermission => 'Photos';

  @override
  String get saveHymnImages => 'to save hymn images';
}
