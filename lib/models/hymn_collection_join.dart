class HymnCollectionJoin {
  final int hymnId;
  final int collectionId;

  HymnCollectionJoin({
    required this.hymnId,
    required this.collectionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'hymn_id': hymnId,
      'collection_id': collectionId,
    };
  }
}
