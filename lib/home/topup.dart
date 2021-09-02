import 'package:busticket/payment.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class TopupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TopupPageState();
}

class _TopupPageState extends State<StatefulWidget> {
  final topupData = FirebaseFirestore.instance.collection('/topup');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: topupData.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No data found.'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<dynamic, dynamic> data =
                    document.data()! as Map<dynamic, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(data['coins'].toString()),
                    subtitle: Text('+ ${data['bonus'].toString()} coins'),
                    leading: Icon(Icons.toll),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaymentPage()));
                    },
                  ),
                );
              }).toList(),
            ),
          );
        });
  }
}
