import 'package:donkiliw/models/section.dart';

class Hymn {
  final int? id;
  final int hymnBookId;
  final int number;
  final String title;
  final String? firstLine;
  bool isLiked = false;
  final String? bookName;
  final String? otherReference;
  List<Section> sections = [];

  Hymn({
    this.id,
    required this.hymnBookId,
    required this.bookName,
    required this.number,
    required this.title,
    this.firstLine,
    this.otherReference,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hymn_book_id': hymnBookId,
      'title': title,
      'hymn_number': number,
      'first_line': firstLine,
      'book_name': bookName,
      'other_reference': otherReference,
    };
  }

  factory Hymn.fromMap(
    Map<String, dynamic> map, {
    bool isLiked = false,
  }) {
    final hymn = Hymn(
      id: map['id'] as int?,
      hymnBookId: map['hymn_book_id'] as int,
      bookName: map['book_name'] as String?,
      number: map['hymn_number'] as int,
      title: map['title'] as String,
      firstLine: map['first_line'],
      otherReference: map['other_reference'],
    );
    hymn.isLiked = isLiked;
    return hymn;
  }

  Hymn copyWith({
    int? id,
    int? hymnBookId,
    String? bookName,
    int? number,
    String? title,
    String? firstLine,
    String? otherReference,
    bool? isLiked,
    List<Section>? sections,
  }) {
    final hymn = Hymn(
      id: id ?? this.id,
      hymnBookId: hymnBookId ?? this.hymnBookId,
      bookName: bookName ?? this.bookName,
      number: number ?? this.number,
      title: title ?? this.title,
      firstLine: firstLine ?? this.firstLine,
      otherReference: otherReference ?? this.otherReference,
    );

    hymn.isLiked = isLiked ?? this.isLiked;
    hymn.sections = sections ?? this.sections;

    return hymn;
  }

  bool get isMultipleRefrain {
    return sections.where((s) => s.sectionType == 'refrain').length > 1;
  }

  bool get isMutiTitle {
    return sections.where((s) => s.sectionType == 'title').length > 1;
  }

  @override
  String toString() {
    return 'Hymn(id: $id, hymnBookId: $hymnBookId, number: $number, title: $title)';
  }
}
