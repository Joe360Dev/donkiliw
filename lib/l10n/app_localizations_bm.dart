// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bambara (`bm`).
class AppLocalizationsBm extends AppLocalizations {
  AppLocalizationsBm([String locale = 'bm']) : super(locale);

  @override
  String get language => 'Bamanankan';

  @override
  String get appName => 'Donkiliw';

  @override
  String appDescription(String appName) {
    return '$appName bɛɛ fɛ ka dɔnkiliw bamanankan ani dogon kan (dogon kan bɛ kɛlɛ). \nI bɛ kɛ don kɛɲɛnkɛ, suguya kalan, wɛrɛ kɔrɔlen donkiliw, ani donkiliw dɔrɔn fɔlɔ sisan ka baara bolo i ce yera. \nU ye a la sariya kɔrɔba ani donkili bamanakan dɔɔn bolo.';
  }

  @override
  String versionNumber(String version) {
    return 'Sigilan $version';
  }

  @override
  String get home => 'Sɔrɔ';

  @override
  String get themes => 'Suguya';

  @override
  String get collections => 'Wɛrɛw';

  @override
  String get settings => 'Tungɛnɛ';

  @override
  String get favorites => 'Bɛɛ min i bɛ se ka fɛ';

  @override
  String get appearancePageTitle => 'Dugu ani sigi';

  @override
  String get welcomeToDonkiliw => 'I ni ce Donkiliw la';

  @override
  String get exploreByTheme => 'Ka suguya la don';

  @override
  String get myCollections => 'Ne wɛrɛw';

  @override
  String get myFavorites => 'Ne bɛɛ min ne bɛ fɛ';

  @override
  String get loadingText => 'Ka ladɛ...';

  @override
  String get loadingCollections => 'Ka wɛrɛw ladɛ...';

  @override
  String get errorText => 'Fɔlɔ fɛɛra';

  @override
  String get errorTryAgain => 'Fɔlɔ: A fɔlɔ, i ka segin.';

  @override
  String get errorWhenLoadingCollections => 'Fɔlɔ: Wɛrɛw ka ladɛ bɔ fɔ';

  @override
  String get errorWhenLoadingHymns => 'Fɔlɔ: Donkiliw ka ladɛ bɔ fɔ';

  @override
  String get errorWhenLoadingThemes => 'Fɔlɔ: Suguya ka ladɛ bɔ fɔ';

  @override
  String get errorWhenLoadingBooks => 'Fɔlɔ: Liburu ladɛ bɔ fɔ';

  @override
  String get errorWhenLoadingHymn => 'Fɔlɔ: Donkili ka ladɛ bɔ fɔ';

  @override
  String get errorWhenCopying => 'Fɔlɔ ka kɔpi kɛ';

  @override
  String get imageExportationFailedMessage => 'Sɛnin fɔlɔ ladɛ bɔ fɔ';

  @override
  String get generatingImage => 'Sɛnin fɔlɔ bɔ fɔ sisan...';

  @override
  String get unableToOpenMailClient => 'I bɛ se ka email kɛnɛ bɔ fɔ.';

  @override
  String get emptyText => 'Dɔ bɛ yen';

  @override
  String get emptyTextCreateCollection => 'Ka i fɔlɔ wɛrɛ daminɛn';

  @override
  String get noResult => 'Ala fɛn bɛ yen';

  @override
  String get noHymnFound => 'Ala donkili bɛ yen';

  @override
  String get noTitle => 'Ala tɔgɔ bɛ yen';

  @override
  String get noTitleCollection => 'Wɛrɛ min tɔgɔ tɛ';

  @override
  String get noDescription => 'Ala tafɛn bɛ yen';

  @override
  String get createYourFirstCollection => 'Ka i fɔlɔ wɛrɛ daminɛn';

  @override
  String get addHymnsToYourCollection => 'Ka donkiliw kɛ i wɛrɛ kan';

  @override
  String get createNewCollection => 'Ka wɛrɛ kɛ kɔrɔ';

  @override
  String get addHymns => 'Ka donkiliw dɔrɔn';

  @override
  String addToCollection(int count) {
    return 'Ka wɛrɛ kan dɔrɔn ($count)';
  }

  @override
  String get exploreThemes => 'Ka suguya don';

  @override
  String get exploreBooks => 'Donkili liburuw';

  @override
  String get seeMore => 'Ka dɔrɔ';

  @override
  String get seeLess => 'Ka nɔgɔya';

  @override
  String get cancel => 'Fɔlɔ';

  @override
  String get save => 'Dɛmɛ';

  @override
  String get edit => 'Bɛɛ kɛ';

  @override
  String get editCollection => 'Ka wɛrɛ bɛɛ kɛ';

  @override
  String get share => 'Kɛla';

  @override
  String get copy => 'Kɔpi';

  @override
  String get exportAsImage => 'Ka sɛnin tɛgɛ fɔ';

  @override
  String get openSettings => 'Ka tungɛnɛ bɔ';

  @override
  String get retry => 'Segin';

  @override
  String hymnsAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Donkiliw dɔrɔn ka wɛrɛ kan',
      one: 'Donkili dɔrɔn ka wɛrɛ kan',
    );
    return '$_temp0';
  }

  @override
  String get hymnRemovedFromCollection => 'Donkili ka wɛrɛ kan fɔ';

  @override
  String get collectionDeleted => 'Wɛrɛ ka tɔgɔ';

  @override
  String get hymnShared => 'Donkili ka kɛla!';

  @override
  String get hymnCopied => 'Donkili ka kɔpi kɛ!';

  @override
  String get hymnExported => 'Donkili ka fɔ!';

  @override
  String get imageSavedToGallery => 'Sɛnin ka galerie kɔnɔ dɛmɛ!';

  @override
  String toggleLikeResponseMessage(String likeStatus) {
    String _temp0 = intl.Intl.selectLogic(
      likeStatus,
      {
        'liked': 'Donkili ka bɛɛ fɛ!',
        'unliked': 'Donkili ka bɛɛ fɔ!',
        'other': 'Fɔlɔ fɛɛra. A fɔlɔ, i ka segin!',
      },
    );
    return '$_temp0';
  }

  @override
  String hymnsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count donkiliw',
      one: 'Donkili kelen',
      zero: 'Ala donkili',
    );
    return '$_temp0';
  }

  @override
  String countResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count natigɛw',
      one: 'Natigɛ kelen',
      zero: 'Ala natigɛ',
    );
    return '$_temp0';
  }

  @override
  String createdAt(String date) {
    return 'Ka kɛ $date';
  }

  @override
  String signature(String appName) {
    return 'Ka kɛ fɛ $appName bɛɛ';
  }

  @override
  String get searchAnHymn => 'Ka donkiliw kɛnɛ...';

  @override
  String get searchCollection => 'Ka wɛrɛ kɛnɛ...';

  @override
  String get collectionName => 'Wɛrɛ tɔgɔ';

  @override
  String get selectionCollection => 'Ka wɛrɛ sɔrɔ';

  @override
  String get collectionDescription => 'Wɛrɛ tafɛn';

  @override
  String get result => 'Natigɛ';

  @override
  String get hymn => 'Donkili';

  @override
  String get hymns => 'Donkiliw';

  @override
  String get number => 'Nɔmba';

  @override
  String get title => 'Tɔgɔ';

  @override
  String get book => 'Liburu';

  @override
  String get collection => 'Wɛrɛ';

  @override
  String get description => 'Tafɛn';

  @override
  String get languageLabel => 'Kangɛ';

  @override
  String get appearance => 'Sigilen';

  @override
  String get mode => 'Fɛnɛ';

  @override
  String get darkMode => 'Sɔrɔkɔ';

  @override
  String get lightMode => 'Jɛ';

  @override
  String get systemMode => 'Sistɛmu';

  @override
  String get themeMode => 'Suguya fɛnɛ';

  @override
  String get themeColor => 'Suguya kɔnɔni';

  @override
  String get fontSize => 'Bo kan';

  @override
  String get repeatRefrain => 'Ka refɛrɛ kɔrɔladon';

  @override
  String get repeatRefrainDescription => 'Ka refɛrɛ kɔrɔladon kɔnɔ fɔlɔ kɛnɛ';

  @override
  String get connectedMode => 'Mɔgɔ tugu fɛnɛ';

  @override
  String get connectedModeDescription =>
      'Ka SEGUW ka yera kɛ mɔgɔnw ka ɲɛgɛn bolo.';

  @override
  String get about => 'Ka i bɔ';

  @override
  String get developer => 'Dɛvɛlɔpɛri';

  @override
  String get appDeveloperText => 'Joe Dev bɛɛ kɛ don';

  @override
  String get developerDescription => 'SEGUW bɛɛ kɛ fɔ!';

  @override
  String get supports => 'Bɔ kɛbaw';

  @override
  String get supportsDescription =>
      'Ka foli di Pierre Diarra ni Daniel Sagara ma ni bara demeli koson.';

  @override
  String get contact => 'Taw';

  @override
  String get contactDescription =>
      'Sisan, i bɛ se ka ka ɲinɛ, kɛlɛ, jɛgɛya ani ka app fɛɛra, i bɛ se ka ɲinɛ nɔgɔ.';

  @override
  String get donkiliwQuote => 'Mɔgɔ bɛɛ ye SEGUW ka donkili.';

  @override
  String get donkiliwQuoteReference => 'Zabura 150:6';

  @override
  String get permissionRequired => 'Sɔrɔ sisan ye';

  @override
  String permissionRequiredMessage(String permission, String reason) {
    return 'Sɔrɔ $permission ye sisan $reason. Ka a kɛ app tungɛnɛ kɔnɔ.';
  }

  @override
  String get permissionDenied => 'Sɔrɔ ka fɔ';

  @override
  String permissionDeniedMessage(String permission, String reason) {
    return 'Sɔrɔ $permission ka fɔ. A ye sisan ye $reason. I bɛ segin?';
  }

  @override
  String get storagePermission => 'Damɛ';

  @override
  String get photosPermission => 'Sɛninw';

  @override
  String get saveHymnImages => 'ka donkili sɛninw dɛmɛ';
}
