import 'package:donkiliw/models/hymn.dart';

class HymnCollection {
  final int? id;
  String? title;
  String? description;
  DateTime creationDate = DateTime.now();
  List<Hymn> hymns = [];

  HymnCollection({
    this.id,
    this.title,
    this.description,
  }) {
    title = title ?? 'Collection_${creationDate.millisecondsSinceEpoch}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creation_date': creationDate.toIso8601String(),
    };
  }

  HymnCollection copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? creationDate,
    List<Hymn>? hymns,
  }) {
    final collection = HymnCollection(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
    collection.creationDate = creationDate ?? this.creationDate;

    collection.hymns = hymns ?? this.hymns;
    return collection;
  }

  factory HymnCollection.fromMap(Map<String, dynamic> map) {
    final hymnCollection = HymnCollection(
      id: map['id'],
      title: map['title'],
      description: map['description'],
    );

    hymnCollection.creationDate = DateTime.parse(map['creation_date']);
    return hymnCollection;
  }
}
