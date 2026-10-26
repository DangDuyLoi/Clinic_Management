class AdministrativeUnit {
  final String id;
  final String name;
  final String? code;
  final String? parentId;

  const AdministrativeUnit({
    required this.id,
    required this.name,
    this.code,
    this.parentId,
  });

  factory AdministrativeUnit.fromJson(Map<String, dynamic> json, {String? parentId}) {
    return AdministrativeUnit(
      id: json['code']?.toString() ?? json['id']?.toString() ?? json['name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      parentId: parentId ?? json['parent_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (code != null) 'code': code,
      if (parentId != null) 'parentId': parentId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdministrativeUnit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => name;
}
