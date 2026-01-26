class HymnCollectionJoin {
  final int hymnId;
  final int collectionId;
  final int orderIndex;

  HymnCollectionJoin({
    required this.hymnId,
    required this.collectionId,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'hymn_id': hymnId,
      'collection_id': collectionId,
      'order_index': orderIndex,
    };
  }
}
