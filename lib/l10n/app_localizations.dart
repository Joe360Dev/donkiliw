import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bm.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('bm'),
    Locale('fr')
  ];

  /// Language code for English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// The name of the app
  ///
  /// In en, this message translates to:
  /// **'Donkiliw'**
  String get appName;

  /// Description of the app
  ///
  /// In en, this message translates to:
  /// **'{appName} allows you to explore and sing your local hymns in Bamanakan and Dogon (currently under development).\nEnjoy features such as advanced search, grouping by themes, creating collections, and exporting hymns as images to share with your loved ones.\nOur mission is to preserve and promote spiritual musical culture.'**
  String appDescription(String appName);

  /// Version number with version code
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionNumber(String version);

  /// The title of the home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// The title of the themes tab
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// The title of the collections tab
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// The title of the settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// The title of the appearance page
  ///
  /// In en, this message translates to:
  /// **'Appearance & Theme'**
  String get appearancePageTitle;

  /// Welcome message on the home page
  ///
  /// In en, this message translates to:
  /// **'Welcome to Donkiliw'**
  String get welcomeToDonkiliw;

  /// Title for exploring hymns by theme
  ///
  /// In en, this message translates to:
  /// **'Explore by Theme'**
  String get exploreByTheme;

  /// Title for the collections page
  ///
  /// In en, this message translates to:
  /// **'My Collections'**
  String get myCollections;

  /// Label for my favorites
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// Text displayed while data is being loaded
  ///
  /// In en, this message translates to:
  /// **'Loading in progress...'**
  String get loadingText;

  /// Loading message for collections
  ///
  /// In en, this message translates to:
  /// **'Loading collections...'**
  String get loadingCollections;

  /// Text displayed when an error occurs during data loading
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorText;

  /// Error message when an error occurs
  ///
  /// In en, this message translates to:
  /// **'Error: Please try again.'**
  String get errorTryAgain;

  /// Error message when unable to load collections
  ///
  /// In en, this message translates to:
  /// **'Error: Unable to load your collections'**
  String get errorWhenLoadingCollections;

  /// Error message when unable to load hymns
  ///
  /// In en, this message translates to:
  /// **'Error: Unable to load your hymns'**
  String get errorWhenLoadingHymns;

  /// Error message when unable to load themes
  ///
  /// In en, this message translates to:
  /// **'Error: Unable to load your themes'**
  String get errorWhenLoadingThemes;

  /// Error message when unable to load books
  ///
  /// In en, this message translates to:
  /// **'Error: Unable to load your books'**
  String get errorWhenLoadingBooks;

  /// Error message when unable to load a hymn
  ///
  /// In en, this message translates to:
  /// **'Error: Unable to load your hymn'**
  String get errorWhenLoadingHymn;

  /// Message when there is an error while copying
  ///
  /// In en, this message translates to:
  /// **'Error when copying'**
  String get errorWhenCopying;

  /// Message when image exportation fails
  ///
  /// In en, this message translates to:
  /// **'Image exportation failed'**
  String get imageExportationFailedMessage;

  /// Message when the image is being generated
  ///
  /// In en, this message translates to:
  /// **'Generating image...'**
  String get generatingImage;

  /// Message when the mail client cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Unable to open mail client.'**
  String get unableToOpenMailClient;

  /// Text displayed when there is no data to show
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get emptyText;

  /// Message when there are no collections
  ///
  /// In en, this message translates to:
  /// **'Create your first collection'**
  String get emptyTextCreateCollection;

  /// Message when there are no results
  ///
  /// In en, this message translates to:
  /// **'No result'**
  String get noResult;

  /// Message when no hymn is found
  ///
  /// In en, this message translates to:
  /// **'No hymn found'**
  String get noHymnFound;

  /// Message when there is no title available
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// Message when there is no title for a collection
  ///
  /// In en, this message translates to:
  /// **'No title collection'**
  String get noTitleCollection;

  /// Message when there is no description available
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// Message prompting the user to create their first collection
  ///
  /// In en, this message translates to:
  /// **'Create your first collection'**
  String get createYourFirstCollection;

  /// Message prompting the user to add hymns to their collection
  ///
  /// In en, this message translates to:
  /// **'Add hymns to your collection'**
  String get addHymnsToYourCollection;

  /// Button text for creating a new collection
  ///
  /// In en, this message translates to:
  /// **'Create a new collection'**
  String get createNewCollection;

  /// Button text for adding hymns
  ///
  /// In en, this message translates to:
  /// **'Add hymns'**
  String get addHymns;

  /// Button text for adding to a collection with the number of collections
  ///
  /// In en, this message translates to:
  /// **'Add to collection ({count})'**
  String addToCollection(int count);

  /// Button text for exploring themes
  ///
  /// In en, this message translates to:
  /// **'Explore Themes'**
  String get exploreThemes;

  /// Button text for exploring hymn books
  ///
  /// In en, this message translates to:
  /// **'Hymn Books'**
  String get exploreBooks;

  /// Button text for seeing more items
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// Button text for seeing less items
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// Button text for canceling an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text for saving an action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button text for editing
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button text for editing a collection
  ///
  /// In en, this message translates to:
  /// **'Edit Collection'**
  String get editCollection;

  /// Label for share
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Label for copy
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Label for exporting as image
  ///
  /// In en, this message translates to:
  /// **'Export as Image'**
  String get exportAsImage;

  /// label for Open Settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Label for Retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Message when one or more hymns are added to a collection
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {Hymn added to collection} other {Hymns added to collections}}'**
  String hymnsAddedToCollection(int count);

  /// Message when a hymn is removed from a collection
  ///
  /// In en, this message translates to:
  /// **'Hymn removed from collection'**
  String get hymnRemovedFromCollection;

  /// Message when a collection is deleted
  ///
  /// In en, this message translates to:
  /// **'Collection deleted'**
  String get collectionDeleted;

  /// Message when a hymn is shared
  ///
  /// In en, this message translates to:
  /// **'Hymn shared!'**
  String get hymnShared;

  /// Message when a hymn is copied
  ///
  /// In en, this message translates to:
  /// **'Hymn copied!'**
  String get hymnCopied;

  /// Message when a hymn is exported
  ///
  /// In en, this message translates to:
  /// **'Hymn exported!'**
  String get hymnExported;

  /// Message when the image is saved to the gallery
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery!'**
  String get imageSavedToGallery;

  /// Message displayed after toggling the like status of a hymn
  ///
  /// In en, this message translates to:
  /// **'{likeStatus, select, liked {Hymn added to favorites!} unliked {Hymn removed from favorites!} other {An error occurred. Please retry!}}'**
  String toggleLikeResponseMessage(String likeStatus);

  /// Message for the number of hymns in a collection
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {No hymns} one {1 hymn} other {{count} hymns}}'**
  String hymnsCount(int count);

  /// Message for the number of results
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {No result} one {1 result} other {{count} results}}'**
  String countResult(int count);

  /// Message for the creation date of a collection
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String createdAt(String date);

  /// App signature when exporting as image
  ///
  /// In en, this message translates to:
  /// **'Generated with {appName}'**
  String signature(String appName);

  /// Placeholder text for the search bar
  ///
  /// In en, this message translates to:
  /// **'Search a hymn...'**
  String get searchAnHymn;

  /// Placeholder text for the collection search bar
  ///
  /// In en, this message translates to:
  /// **'Search a collection...'**
  String get searchCollection;

  /// Label for the name of a collection
  ///
  /// In en, this message translates to:
  /// **'Collection Name'**
  String get collectionName;

  /// Label for selecting a collection
  ///
  /// In en, this message translates to:
  /// **'Select a collection'**
  String get selectionCollection;

  /// Label for the description of a collection
  ///
  /// In en, this message translates to:
  /// **'Description of the collection'**
  String get collectionDescription;

  /// Label for the result section
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// Label for hymn
  ///
  /// In en, this message translates to:
  /// **'Hymn'**
  String get hymn;

  /// Label for hymns
  ///
  /// In en, this message translates to:
  /// **'Hymns'**
  String get hymns;

  /// Label for number
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// Label for title
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Label for book
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// Label for collection
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// Label for description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// Label for appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Label for mode
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// Label for dark mode
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// Label for light mode
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// Label for system mode
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// Label for theme mode
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// Label for theme color
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// Label for font size
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Label for repeat refrain
  ///
  /// In en, this message translates to:
  /// **'Repeat Refrain'**
  String get repeatRefrain;

  /// Description for repeat refrain
  ///
  /// In en, this message translates to:
  /// **'Repeat the refrain after each verse'**
  String get repeatRefrainDescription;

  /// Label for connected mode
  ///
  /// In en, this message translates to:
  /// **'Connected Mode'**
  String get connectedMode;

  /// Description for connected mode
  ///
  /// In en, this message translates to:
  /// **'Celebrate the LORD in community with your friends and family.'**
  String get connectedModeDescription;

  /// Label for about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Label for developer
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Text for the app developer
  ///
  /// In en, this message translates to:
  /// **'Developed by Joe Dev'**
  String get appDeveloperText;

  /// Description for the app developer
  ///
  /// In en, this message translates to:
  /// **'Another victory for the LORD.'**
  String get developerDescription;

  /// Label for supports
  ///
  /// In en, this message translates to:
  /// **'Supported by'**
  String get supports;

  /// Description for supports
  ///
  /// In en, this message translates to:
  /// **'Big thanks to Idrissa Pierre Diarra for sharing his local hymns database.'**
  String get supportsDescription;

  /// Label for contact
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Description for contact
  ///
  /// In en, this message translates to:
  /// **'If you have any questions, feedback, suggestions, or want to contribute to the app, please don\'t hesitate to reach out to me.'**
  String get contactDescription;

  /// Quote from the Bible
  ///
  /// In en, this message translates to:
  /// **'All that breathes praise the LORD.'**
  String get donkiliwQuote;

  /// Reference for the quote
  ///
  /// In en, this message translates to:
  /// **'Psalm 150:6'**
  String get donkiliwQuoteReference;

  /// Permission required message
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// Permission required message
  ///
  /// In en, this message translates to:
  /// **'{permission} permission is required {reason}. Please enable it in app settings.'**
  String permissionRequiredMessage(String permission, String reason);

  /// Permission denied message
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// Permission denied message
  ///
  /// In en, this message translates to:
  /// **'{permission} permission was denied. This is required {reason}. Would you like to try again?'**
  String permissionDeniedMessage(String permission, String reason);

  /// Stockage
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storagePermission;

  /// Photos
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosPermission;

  /// Save hymn images
  ///
  /// In en, this message translates to:
  /// **'to save hymn images'**
  String get saveHymnImages;
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
      <String>['en', 'bm', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'bm':
      return AppLocalizationsBm();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
