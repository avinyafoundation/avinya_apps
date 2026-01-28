class AcademyLocation {
  int? id;
  int? organizationId;
  String? name;
  String? description;

  AcademyLocation({
    this.id,
    this.organizationId,
    this.name,
    this.description,
  });

  // Create AcademyLocation instance from JSON
  factory AcademyLocation.fromJson(Map<String, dynamic> json) {
    return AcademyLocation(
      id: json['id'],
      organizationId: json['organization_id'],
      name: json['location_name'],
      description: json['description'],
    );
  }

  // Convert AcademyLocation instance to JSON
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (organizationId != null) 'organization_id': organizationId,
        if (name != null) 'location_name': name,
        if (description != null) 'description': description,
      };
}