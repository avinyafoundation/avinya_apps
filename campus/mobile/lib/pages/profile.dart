import 'package:flutter/material.dart';
import 'package:mobile/layout/adaptive.dart';
import 'package:mobile/pages/profile_info_view.dart';
import 'package:mobile/pages/splash.dart';

class ProfileScreen extends StatelessWidget {
  final int? id;
  final String? recordType;
  final String? preferredName;
  final String? fullName;
  final String? notes;
  final String? dateOfBirth;
  final String? sex;
  final int? avinyaTypeId;
  final String? passportNo;
  final int? permanentAddressId;
  final int? mailingAddressId;
  final String? nicNo;
  final String? idNo;
  final int? phone;
  final int? organizationId;
  final String? asgardeoId;
  final String? jwtSubId;
  final String? jwtEmail;
  final String? email;
  final Address? permanentAddress;
  final Address? mailingAddress;
  final Address? streetAddress;
  final int? bankAccountNumber;
  final String? bankName;
  final String? digitalId;
  final String? bankAccountName;
  final int? avinyaPhone;

  const ProfileScreen({
    Key? key,
    this.id,
    this.recordType,
    this.preferredName,
    this.fullName,
    this.notes,
    this.dateOfBirth,
    this.sex,
    this.avinyaTypeId,
    this.passportNo,
    this.permanentAddressId,
    this.mailingAddressId,
    this.nicNo,
    this.idNo,
    this.phone,
    this.organizationId,
    this.asgardeoId,
    this.jwtSubId,
    this.jwtEmail,
    this.email,
    this.permanentAddress,
    this.mailingAddress,
    this.streetAddress,
    this.bankAccountNumber,
    this.bankName,
    this.digitalId,
    this.bankAccountName,
    this.avinyaPhone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDisplayDesktop(context)) {
      return Scaffold(
        body: Container(
          child: SplashPage(
            child: MyProfileScreen(),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(40),
            ),
            child: Container(
              child: MyProfileScreen(),
            ),
          ),
        ),
      );
    }
  }
}

class Address {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? zip;
  final String? name_en;

  const Address({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.zip,
    this.name_en,
  });

  @override
  String toString() {
    return '$line1, $line2, $city, $state $zip $name_en';
  }
}
