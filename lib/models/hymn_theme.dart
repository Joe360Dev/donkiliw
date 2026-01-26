import 'package:donkiliw/models/hymn.dart';

class HymnTheme {
  final int? id;
  final String name;
  final String? description;
  final String iconName;
  List<Hymn> hymns = [];

  HymnTheme({
    this.id,
    required this.name,
    required this.iconName,
    this.description,
  });

  factory HymnTheme.fromMap(Map<String, dynamic> map) {
    return HymnTheme(
      id: map['id'],
      name: map['name'],
      iconName: map['icon_name'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'description': description,
    };
  }
}
