class OrganizationMetaData {
  int? id;
  int? organization_id;
  String? key_name;
  String? value;

  OrganizationMetaData({
    this.id,
    this.organization_id,
    this.key_name,
    this.value,
  });

  factory OrganizationMetaData.fromJson(Map<String, dynamic> json) {
    return OrganizationMetaData(
      id: json['id'],
      organization_id: json['organization_id'],
      key_name: json['key_name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (organization_id != null) 'organization_id': organization_id,
        if (key_name != null) 'key_name': key_name,
        if (value != null) 'value': value,
  };
}
