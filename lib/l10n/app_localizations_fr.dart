// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get language => 'Français';

  @override
  String get appName => 'Donkiliw';

  @override
  String appDescription(String appName) {
    return '$appName vous permet d\'explorer et de chanter vos cantiques locaux en bamanakan et en dogon (en cours de développement).\nProfitez de fonctionnalités telles que la recherche avancée, le regroupement par thèmes, la création de collections et l\'exportation des cantiques en images pour les partager avec vos proches.\nNotre mission est de préserver et de promouvoir la culture musicale spirituelle.';
  }

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get home => 'Accueil';

  @override
  String get themes => 'Thèmes';

  @override
  String get collections => 'Collections';

  @override
  String get settings => 'Paramètres';

  @override
  String get favorites => 'Favoris';

  @override
  String get appearancePageTitle => 'Apparence et thème';

  @override
  String get welcomeToDonkiliw => 'Bienvenue sur Donkiliw';

  @override
  String get exploreByTheme => 'Explorer par thème';

  @override
  String get myCollections => 'Mes collections';

  @override
  String get myFavorites => 'Mes favoris';

  @override
  String get loadingText => 'Chargement en cours...';

  @override
  String get loadingCollections => 'Chargement des collections...';

  @override
  String get errorText => 'Une erreur est survenue';

  @override
  String get errorTryAgain => 'Erreur : Veuillez réessayer.';

  @override
  String get errorWhenLoadingCollections =>
      'Erreur : Impossible de charger vos collections';

  @override
  String get errorWhenLoadingHymns =>
      'Erreur : Impossible de charger vos cantiques';

  @override
  String get errorWhenLoadingThemes =>
      'Erreur : Impossible de charger vos thèmes';

  @override
  String get errorWhenLoadingBooks =>
      'Erreur : Impossible de charger vos livres';

  @override
  String get errorWhenLoadingHymn =>
      'Erreur : Impossible de charger votre cantique';

  @override
  String get errorWhenCopying => 'Erreur lors de la copie';

  @override
  String get imageExportationFailedMessage =>
      'Échec de l\'exportation de l\'image';

  @override
  String get generatingImage => 'Génération de l\'image...';

  @override
  String get unableToOpenMailClient =>
      'Impossible d\'ouvrir le client de messagerie.';

  @override
  String get emptyText => 'Aucune donnée disponible';

  @override
  String get emptyTextCreateCollection => 'Créez votre première collection';

  @override
  String get noResult => 'Aucun résultat';

  @override
  String get noHymnFound => 'Aucun cantique trouvé';

  @override
  String get noTitle => 'Aucun titre';

  @override
  String get noTitleCollection => 'Collection sans titre';

  @override
  String get noDescription => 'Aucune description';

  @override
  String get createYourFirstCollection => 'Créez votre première collection';

  @override
  String get addHymnsToYourCollection =>
      'Ajoutez des cantiques à votre collection';

  @override
  String get createNewCollection => 'Créer une nouvelle collection';

  @override
  String get addHymns => 'Ajouter des cantiques';

  @override
  String addToCollection(int count) {
    return 'Ajouter à la collection ($count)';
  }

  @override
  String get exploreThemes => 'Explorer les thèmes';

  @override
  String get exploreBooks => 'Livres de cantiques';

  @override
  String get seeMore => 'Voir plus';

  @override
  String get seeLess => 'Voir moins';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get editCollection => 'Modifier la collection';

  @override
  String get share => 'Partager';

  @override
  String get copy => 'Copier';

  @override
  String get exportAsImage => 'Exporter en image';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get retry => 'Réessayer';

  @override
  String hymnsAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cantiques ajoutés aux collections',
      one: 'Cantique ajouté à la collection',
    );
    return '$_temp0';
  }

  @override
  String get hymnRemovedFromCollection => 'Cantique retiré de la collection';

  @override
  String get collectionDeleted => 'Collection supprimée';

  @override
  String get hymnShared => 'Cantique partagé !';

  @override
  String get hymnCopied => 'Cantique copié !';

  @override
  String get hymnExported => 'Cantique exporté !';

  @override
  String get imageSavedToGallery => 'Image enregistrée dans la galerie !';

  @override
  String toggleLikeResponseMessage(String likeStatus) {
    String _temp0 = intl.Intl.selectLogic(
      likeStatus,
      {
        'liked': 'Cantique ajouté aux favoris !',
        'unliked': 'Cantique retiré des favoris !',
        'other': 'Une erreur est survenue. Veuillez réessayer !',
      },
    );
    return '$_temp0';
  }

  @override
  String hymnsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cantiques',
      one: '1 cantique',
      zero: 'Aucun cantique',
    );
    return '$_temp0';
  }

  @override
  String countResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String createdAt(String date) {
    return 'Créé le $date';
  }

  @override
  String signature(String appName) {
    return 'Généré avec $appName';
  }

  @override
  String get searchAnHymn => 'Rechercher un cantique...';

  @override
  String get searchCollection => 'Rechercher une collection...';

  @override
  String get collectionName => 'Nom de la collection';

  @override
  String get selectionCollection => 'Sélectionner une collection';

  @override
  String get collectionDescription => 'Description de la collection';

  @override
  String get result => 'Résultat';

  @override
  String get hymn => 'Cantique';

  @override
  String get hymns => 'Cantiques';

  @override
  String get number => 'Numéro';

  @override
  String get title => 'Titre';

  @override
  String get book => 'Livre';

  @override
  String get collection => 'Collection';

  @override
  String get description => 'Description';

  @override
  String get languageLabel => 'Langue';

  @override
  String get appearance => 'Apparence';

  @override
  String get mode => 'Mode';

  @override
  String get darkMode => 'Sombre';

  @override
  String get lightMode => 'Clair';

  @override
  String get systemMode => 'Système';

  @override
  String get themeMode => 'Mode de thème';

  @override
  String get themeColor => 'Couleur du thème';

  @override
  String get fontSize => 'Taille de la police';

  @override
  String get repeatRefrain => 'Répéter le refrain';

  @override
  String get repeatRefrainDescription =>
      'Répéter le refrain après chaque verset';

  @override
  String get connectedMode => 'Mode connecté';

  @override
  String get connectedModeDescription =>
      'Célébrez le SEIGNEUR en communauté avec vos amis et votre famille.';

  @override
  String get about => 'À propos';

  @override
  String get developer => 'Développeur';

  @override
  String get appDeveloperText => 'Développé par Joe Dev';

  @override
  String get developerDescription => 'Une autre victoire pour le SEIGNEUR.';

  @override
  String get supports => 'Soutenu par';

  @override
  String get supportsDescription =>
      'Grand merci à Idrissa Pierre Diarra et à Daniel Sagara pour avoir soutenu cette œuvre.';

  @override
  String get contact => 'Contact';

  @override
  String get contactDescription =>
      'Si vous avez des questions, des commentaires, des suggestions ou souhaitez contribuer à l\'application, n\'hésitez pas à me contacter.';

  @override
  String get donkiliwQuote => 'Tout ce qui respire loue le SEIGNEUR.';

  @override
  String get donkiliwQuoteReference => 'Psaume 150:6';

  @override
  String get permissionRequired => 'Permission requise';

  @override
  String permissionRequiredMessage(String permission, String reason) {
    return 'La permission $permission est requise $reason. Veuillez l\'activer dans les paramètres de l\'application.';
  }

  @override
  String get permissionDenied => 'Permission refusée';

  @override
  String permissionDeniedMessage(String permission, String reason) {
    return 'La permission $permission a été refusée. Elle est requise $reason. Voulez-vous réessayer ?';
  }

  @override
  String get storagePermission => 'Stockage';

  @override
  String get photosPermission => 'Photos';

  @override
  String get saveHymnImages => 'pour enregistrer des images d\'hymnes';
}
