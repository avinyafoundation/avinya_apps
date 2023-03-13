import 'package:flutter/material.dart';

class ProfileInfoViewPage extends StatefulWidget {
  const ProfileInfoViewPage({Key? key}) : super(key: key);

  @override
  _ProfileInfoViewPageState createState() => _ProfileInfoViewPageState();
}

class _ProfileInfoViewPageState extends State<ProfileInfoViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Info'),
      ),
      body: Center(
        child: Text('Profile Info View'),
      ),
    );
  }
}
