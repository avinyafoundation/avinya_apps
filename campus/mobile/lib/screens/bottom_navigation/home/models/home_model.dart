class MyAlumniDashboardScreenModel {
  final bool? isLocationLoaded;
  final String? toLocation;
  final String? fromLocation;
  final String? tripDescription;
  final String? rideType;
  final String? pickupLocation;
  final String? dropoutLocation;
  final String? pickupDateTime;
  final String? dropoutDateTime;
  final String? driverNumber;
  final String? vehicleType;
  final int? passengerCount;
  final String? hireAmount;
  final String? hireStage;
  final String? tripId;
  final String? tripOwner;
  final String? tripOwnerNumber;
  final String? totalTripBudget;
  final String? referrerCharge;
  final String? serviceCharge;
  final String? totalPaymentYouGet;
  final String? sessionToken;
  final List<dynamic>? placeList;
  final bool? toggleButtonStatus;

  MyAlumniDashboardScreenModel(
      {this.isLocationLoaded,
      this.toLocation,
      this.fromLocation,
      this.tripDescription,
      this.rideType,
      this.pickupLocation,
      this.dropoutLocation,
      this.pickupDateTime,
      this.dropoutDateTime,
      this.driverNumber,
      this.vehicleType,
      this.passengerCount,
      this.hireAmount,
      this.hireStage,
      this.tripId,
      this.tripOwner,
      this.tripOwnerNumber,
      this.totalTripBudget,
      this.referrerCharge,
      this.serviceCharge,
      this.totalPaymentYouGet,
      this.sessionToken,
      this.placeList,
      this.toggleButtonStatus});

  factory MyAlumniDashboardScreenModel.fromJson(Map<String, dynamic> json) {
    return MyAlumniDashboardScreenModel(
      isLocationLoaded: json['isLocationLoaded'] as bool?,
      toLocation: json['toLocation'] as String?,
      fromLocation: json['fromLocation'] as String?,
      tripDescription: json['tripDescription'] as String?,
      rideType: json['rideType'] as String?,
      pickupLocation: json['pickupLocation'] as String?,
      dropoutLocation: json['dropoutLocation'] as String?,
      pickupDateTime: json['pickupDateTime'] as String?,
      dropoutDateTime: json['dropoutDateTime'] as String?,
      driverNumber: json['driverNumber'] as String?,
      vehicleType: json['vehicleType'] as String?,
      passengerCount: json['passengerCount'] as int?,
      hireAmount: json['hireAmount'] as String?,
      hireStage: json['hireStage'] as String?,
      tripId: json['tripId'] as String?,
      tripOwner: json['tripOwner'] as String?,
      tripOwnerNumber: json['tripOwnerNumber'] as String?,
      totalTripBudget: json['totalTripBudget'] as String?,
      referrerCharge: json['referrerCharge'] as String?,
      serviceCharge: json['serviceCharge'] as String?,
      totalPaymentYouGet: json['totalPaymentYouGet'] as String?,
      sessionToken: json['sessionToken'] as String?,
      placeList: json['placeList'] as List<dynamic>,
      toggleButtonStatus: json['toggleButtonStatus'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLocationLoaded': isLocationLoaded,
      'toLocation': toLocation,
      'fromLocation': fromLocation,
      'tripDescription': tripDescription,
      'rideType': rideType,
      'pickupLocation': pickupLocation,
      'dropoutLocation': dropoutLocation,
      'pickupDateTime': pickupDateTime,
      'dropoutDateTime': dropoutDateTime,
      'driverNumber': driverNumber,
      'vehicleType': vehicleType,
      'passengerCount': passengerCount,
      'hireAmount': hireAmount,
      'hireStage': hireStage,
      'tripId': tripId,
      'tripOwner': tripOwner,
      'tripOwnerNumber': tripOwnerNumber,
      'totalTripBudget': totalTripBudget,
      'referrerCharge': referrerCharge,
      'serviceCharge': serviceCharge,
      'totalPaymentYouGet': totalPaymentYouGet,
      'sessionToken': sessionToken,
      'placeList': placeList,
      'toggleButtonStatus': toggleButtonStatus,
    };
  }

  MyAlumniDashboardScreenModel copyWith(
      {String? firstName,
      bool? isLocationLoaded,
      String? toLocation,
      String? fromLocation,
      String? tripDescription,
      String? rideType,
      String? pickupLocation,
      String? dropoutLocation,
      String? pickupDateTime,
      String? dropoutDateTime,
      String? driverNumber,
      String? vehicleType,
      int? passengerCount,
      String? hireAmount,
      String? hireStage,
      String? tripId,
      String? tripOwner,
      String? tripOwnerNumber,
      String? totalTripBudget,
      String? referrerCharge,
      String? serviceCharge,
      String? totalPaymentYouGet,
      String? sessionToken,
      List<dynamic>? placeList,
      bool? toggleButtonStatus}) {
    return MyAlumniDashboardScreenModel(
        isLocationLoaded: isLocationLoaded ?? this.isLocationLoaded,
        toLocation: toLocation ?? this.toLocation,
        fromLocation: fromLocation ?? this.fromLocation,
        tripDescription: tripDescription ?? this.tripDescription,
        rideType: rideType ?? this.rideType,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        dropoutLocation: dropoutLocation ?? this.dropoutLocation,
        pickupDateTime: pickupDateTime ?? this.pickupDateTime,
        dropoutDateTime: dropoutDateTime ?? this.dropoutDateTime,
        driverNumber: driverNumber ?? this.driverNumber,
        vehicleType: vehicleType ?? this.vehicleType,
        passengerCount: passengerCount ?? this.passengerCount,
        hireAmount: hireAmount ?? this.hireAmount,
        hireStage: hireStage ?? this.hireStage,
        tripId: tripId ?? this.tripId,
        tripOwner: tripOwner ?? this.tripOwner,
        tripOwnerNumber: tripOwnerNumber ?? this.tripOwnerNumber,
        totalTripBudget: totalTripBudget ?? this.totalTripBudget,
        referrerCharge: referrerCharge ?? this.referrerCharge,
        serviceCharge: serviceCharge ?? this.serviceCharge,
        totalPaymentYouGet: totalPaymentYouGet ?? this.totalPaymentYouGet,
        sessionToken: sessionToken ?? this.sessionToken,
        placeList: placeList ?? this.placeList,
        toggleButtonStatus: toggleButtonStatus ?? this.toggleButtonStatus);
  }
}
