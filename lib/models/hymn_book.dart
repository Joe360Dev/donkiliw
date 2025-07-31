import 'package:slugify/slugify.dart';

class HymnBook {
  final int? id;
  final String name;
  final String coverImagePath;

  final int? publicationYear;
  final String? language;

  HymnBook({
    this.id,
    required this.name,
    this.publicationYear,
    this.language,
  }) : coverImagePath =
            'assets/book_covers/${slugify(name, delimiter: '_')}.png';

  factory HymnBook.fromMap(Map<String, dynamic> map) {
    return HymnBook(
      id: map['id'],
      name: map['name'],
      publicationYear: map['publication_year'],
      language: map['language'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'publication_year': publicationYear,
      'language': language,
    };
  }

  @override
  String toString() {
    return '$name (Year: $publicationYear, language: $language)';
  }
}
