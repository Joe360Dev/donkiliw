import 'package:donkiliw/models/phrase.dart';

class Section {
  final int? id;
  final int hymnId;
  final String? title;
  final String sectionType;
  final int sequence;
  List<Phrase> phrases = [];

  Section({
    this.id,
    required this.hymnId,
    this.title,
    required this.sectionType,
    required this.sequence,
  }) {
    assert(
      sectionType == 'title' ||
          sectionType == 'verse' ||
          sectionType == 'refrain',
      'sectionType must be either "title", "verse" or "refrain"',
    );
  }

  Section copyWith({
    int? id,
    int? hymnId,
    String? title,
    String? sectionType,
    int? sequence,
    List<Phrase>? phrases,
  }) {
    final section = Section(
      id: id ?? this.id,
      hymnId: hymnId ?? this.hymnId,
      title: title ?? this.title,
      sectionType: sectionType ?? this.sectionType,
      sequence: sequence ?? this.sequence,
    );
    section.phrases = phrases ?? this.phrases;
    return section;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hymn_id': hymnId,
      'title': title,
      'section_type': sectionType,
      'sequence': sequence,
    };
  }

  // Create a Section object from a Map retrieved from the database
  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'] as int?,
      hymnId: map['hymn_id'] as int,
      title: map['title'] as String?,
      sectionType: map['section_type'] as String,
      sequence: map['sequence'] as int,
    );
  }

  // Optional: toString for debugging or logging
  @override
  String toString() {
    return 'Section(id: $id, hymnId: $hymnId, title: $title, sectionType: $sectionType, sequence: $sequence)';
  }
}
