
class ResourceProperty{

  int? id;
  int? asset_id;
  int? consumable_id;
  String? property;
  String? value;

  ResourceProperty({
    this.id,
    this.asset_id,
    this.consumable_id,
    this.property,
    this.value,
  });

  factory ResourceProperty.fromJson(Map<String,dynamic> json) {
    return ResourceProperty(
      id: json['id'],
      asset_id: json['asset_id'],
      consumable_id: json['consumable_id'],
      property: json['property'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (asset_id != null) 'asset_id': asset_id,
        if (consumable_id != null) 'consumable_id': consumable_id,
        if(property !=null) 'property':property,
        if(value !=null) 'value':value,
      };
}
