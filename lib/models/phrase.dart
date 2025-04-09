class Phrase {
  final int? id;
  final int sectionId;
  final String content;
  final int sequence;
  final int repeatCount;

  Phrase({
    this.id,
    required this.sectionId,
    required this.content,
    required this.sequence,
    this.repeatCount = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section_id': sectionId,
      'content': content,
      'sequence': sequence,
      'repeat_count': repeatCount,
    };
  }

  factory Phrase.fromMap(Map<String, dynamic> map) {
    return Phrase(
      id: map['id'],
      sectionId: map['section_id'],
      content: map['content'],
      sequence: map['sequence'],
      repeatCount: map['repeat_count'] ?? 1,
    );
  }
}
