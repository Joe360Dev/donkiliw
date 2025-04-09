class HymnThemeJoin {
  final int hymnId;
  final int themeId;

  HymnThemeJoin({
    required this.hymnId,
    required this.themeId,
  });

  factory HymnThemeJoin.fromMap(Map<String, dynamic> map) {
    return HymnThemeJoin(
      hymnId: map['hymn_id'],
      themeId: map['theme_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hymn_id': hymnId,
      'theme_id': themeId,
    };
  }
}
