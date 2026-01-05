import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;


class MaterialCost {

  int? id;
  int? financialId;
  String? item;
  double? quantity;
  Unit? unit;
  double? unitCost;


  MaterialCost({
    this.id,
    this.financialId,
    this.item,
    this.quantity,
    this.unit,
    this.unitCost,
  });


  //Create MaterialCost instance from JSON
  factory MaterialCost.fromJson(Map<String, dynamic> json){
    return MaterialCost(
      id: json['id'],
      financialId: json['financialId'],
      item: json['item'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: getUnitFromString(json['unit']),
      unitCost: (json['unit_cost'] as num).toDouble(),
    );
  }


  //Create Material instance to JSON
  Map<String, dynamic> toJson() => {
    if(id != null) 'id':id,
    if(financialId != null) 'financialId':financialId,
    if(item != null) 'item': item,
    if(quantity != null) 'quantity': quantity,
    if(unit != null) 'unit': unitToString(unit!),
    if(unitCost != null) 'unit_cost': unitCost,
  };

}



//Delete material costs
Future<http.Response> deleteMaterialCost(int materialCostId) async {
  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/material-costs/$materialCostId');

  final response = await http.delete(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception(
        'Failed to delete material cost. Status code: ${response.statusCode}, body: ${response.body}');
  }
}




//Define enum for Units
enum Unit{
  piece,
  kg,
  liter,
  meter
}


//Get unit from given string
Unit getUnitFromString(String unitString){
  switch(unitString.toLowerCase()){
    case 'piece':
      return Unit.piece;
    case 'kg':
      return Unit.kg; 
    case 'liter':
      return Unit.liter;
    case 'meter':
      return Unit.meter;  
    default:
      throw Exception('Unknown unit: $unitString');
  }
}


//Convert unit to string
String unitToString(Unit unit){
  switch(unit){
    case Unit.piece:
      return 'piece';
    case Unit.kg:
      return 'kg';
    case Unit.liter:
      return 'liter';
    case Unit.meter:
      return 'meter';  
    // default:
    //   throw Exception('Unknown unit: $unit');
  }
}
