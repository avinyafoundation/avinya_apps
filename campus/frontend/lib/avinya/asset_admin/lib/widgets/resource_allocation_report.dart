import 'package:flutter/material.dart';
import 'package:asset_admin/data.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ResourceAllocationReport extends StatefulWidget {
  const ResourceAllocationReport({super.key});

  @override
  State<ResourceAllocationReport> createState() => _ResourceAllocationReportState();
}

class _ResourceAllocationReportState extends State<ResourceAllocationReport> {
 
 List<ResourceAllocation> _resource_allocations = [];

 late DataTableSource _data;
 List<String?> columnNames = [];
var _selectedOrganizationValue; 
 List<Organization> _organizationsList=[];
 //List<String> _organizationsNames=[];

 List<AvinyaType> _avinyaAllAvinyaTypes = [];
 List<AvinyaType> _avinyaAssetAvinyaTypes = [];
var _selectedAssetValue;
bool assetTypesLoaded = false;
bool organizationsLoaded = false;

 @override
  void initState(){
    super.initState();
    loadOrganizationsData();
    loadAssetTypesData();
  }

  Future<void> loadOrganizationsData() async{

   if (campusAppsPortalInstance.isTeacher) { 

    var org = campusAppsPortalInstance.getUserPerson().organization; 
   
    print("organization: ${org!.name!.name_en}");
    _selectedOrganizationValue = org;
    print("selected Organization Value : {$_selectedOrganizationValue}");
   // _organizationsList = await fetchOrganizationsByAvinyaType(2);
   
   }else if(campusAppsPortalInstance.isFoundation){

    _organizationsList = await fetchOrganizationsByAvinyaType(2);
   }

    setState(() {
      assetTypesLoaded = false;
    });
  }

  Future<void> loadAssetTypesData() async{
    _avinyaAllAvinyaTypes = await fetchAvinyaTypes();
    _avinyaAssetAvinyaTypes = _avinyaAllAvinyaTypes.where((AvinyaType type) => type.description=='asset').toList();

    setState(() {
          organizationsLoaded = true;
          assetTypesLoaded = true;
    }); 
  }

  List<DataColumn> _buildDataColumns(){
    
    List<DataColumn> ColumnNames = [];  

    ColumnNames.add(DataColumn(
                        label: Text(
                              'preferred_name',
                              style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
                        label: Text(
                              'digital_id',
                              style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    ColumnNames.add(DataColumn(
                        label: Text(
                              'organization',
                              style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    ColumnNames.add(DataColumn(
                        label: Text(
                              'name',
                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));      

    ColumnNames.add(DataColumn(
                        label: Text(
                              'serial_number',
                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    
    
    ColumnNames.add(DataColumn(
                        label: Text(
                              'properties',
                               style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
   
    

    return ColumnNames;
  }
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    _data = _MyData(
        _resource_allocations,_buildDataColumns());
  }

  @override
  Widget build(BuildContext context) {

  
    return SingleChildScrollView(
      
     child: Wrap(
        alignment: WrapAlignment.start,
        children: <Widget>[
          Column(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[                 
                  Container(
                    margin: EdgeInsets.only(
                      left: 20, top: 20, bottom: 10),
                    child: Row(
                      children: <Widget>[
                        if(!campusAppsPortalInstance.isTeacher)
                        Text('Select a Organization:'),
                        SizedBox(width: 10),
                       if(organizationsLoaded && !campusAppsPortalInstance.isTeacher)
                        
                        DropdownButton<Organization>(
                          value: _selectedOrganizationValue,
                          onChanged: (Organization? newValue) async{

                            setState(() {                             
                              _selectedOrganizationValue = newValue!;
                             print(_selectedOrganizationValue!.id);
                            });

                          if(_selectedOrganizationValue !=null && _selectedAssetValue!=null ){
                            
                            _resource_allocations = 
                               await getResourceAllocationReport(
                                 _selectedOrganizationValue!.id,
                                 _selectedAssetValue!.id
                                );

                               setState(() {
                                  _data = _MyData(
                                  _resource_allocations,_buildDataColumns());
                                });
                          }
                    
                          },
                          items: _organizationsList
                                .map((Organization value){
                                return DropdownMenuItem<Organization>(
                                    value: value,
                                    child: Text(value.name!.name_en!),
                                  );
                                 }).toList(),            
                        ),
                        if(!campusAppsPortalInstance.isTeacher)
                        if (!organizationsLoaded)
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: SpinKitCircle(
                            color: (Colors.yellow[700]), // Customize the color of the indicator
                            size: 40, // Customize the size of the indicator
                            ),
                          ),
                          SizedBox(width: 20),
                  Container(
                    margin: EdgeInsets.only(
                      left: 10, top: 20, bottom: 10),
                    child: Row(
                      children: <Widget>[
                        Text('Select a Asset Type:'),
                        SizedBox(width: 10),
                       if(assetTypesLoaded)
                        DropdownButton<AvinyaType?>(
                          value:_selectedAssetValue,
                          onChanged: (AvinyaType? newValue) async{
                 
                            setState(() {                             
                              _selectedAssetValue = newValue!;
                             print(_selectedAssetValue!.id);
                             
                            });

                            if(_selectedOrganizationValue !=null && _selectedAssetValue!=null ){

                             _resource_allocations = 
                               await getResourceAllocationReport(
                                 _selectedOrganizationValue!.id,
                                 _selectedAssetValue!.id
                                );

                                setState(() {
                                  _data = _MyData(
                                  _resource_allocations,_buildDataColumns());
                                });

                            }
                          },
                          items: _avinyaAssetAvinyaTypes
                                .map((AvinyaType? value){
                                return DropdownMenuItem<AvinyaType>(
                                    value: value,
                                    child: Text(value!.name!),
                                  );
                                 }).toList(),            
                        ),
                        if (!assetTypesLoaded)
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: SpinKitCircle(
                            color: (Colors.yellow[700]), // Customize the color of the indicator
                            size: 40, // Customize the size of the indicator
                           ),
                          ),                        
                      ],
                    ),
                  ),
                      ],
                    ),
                  ),
                ],
              ),        
           ],
          ),
          SizedBox(height: 16.0),
          SizedBox(height: 32.0),
          Wrap(children: [
            PaginatedDataTable(
              columns:  _buildDataColumns(), 
              source: _data,
              columnSpacing: 40,
              horizontalMargin: 60,
              rowsPerPage: 25,
            )
           ],
          )

        ],
     ),
    );
  }

}

class _MyData extends DataTableSource{

 _MyData(this._resource_allocations,this.numberOfColumns) {
    
  }

  List<ResourceAllocation> _resource_allocations=[];
  List<DataColumn> numberOfColumns = [];




  @override
  DataRow? getRow(int index) {

   List<DataCell> cells = [];
    
   if(_resource_allocations.length >0){

    var person = _resource_allocations[index].person;
    var asset = _resource_allocations[index].asset;
    var resource_properties = _resource_allocations[index].resource_properties;
    var organization = _resource_allocations[index].organization;

   if( person!=null)
   {
    cells.add(DataCell(Text(person.preferred_name !=null ? person.preferred_name! :'N/A')));
    cells.add(DataCell(Text(person.digital_id !=null ? person.digital_id!:'N/A')));
   }else{
    cells.add(DataCell(Text('N/A')));
    cells.add(DataCell(Text('N/A')));
   }

  if(person == null){

   if(organization !=null){

    cells.add(DataCell(Text(organization.name!.name_en !=null ? organization.name!.name_en! :'N/A')));
   }
   
  }else{
    cells.add(DataCell(Text('N/A')));
   }

    if(asset !=null){
     cells.add(DataCell(Text(asset.name !=null ? asset.name! :'N/A')));
     cells.add(DataCell(Text(asset.serialNumber !=null ? asset.serialNumber! :'N/A')));
    }else{
     cells.add(DataCell(Text('N/A')));
     cells.add(DataCell(Text('N/A')));
    }


    if(resource_properties.length>0){

      String cellValue = resource_properties.map((entry) => '${entry.property}: ${entry.value}').join('\n');
      cells.add(DataCell(Text(cellValue)));
   
    }else{
      cells.add(DataCell(Text('N/A')));
    }
      
  }
   return DataRow(
        cells: cells,
      );

  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _resource_allocations.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;



}