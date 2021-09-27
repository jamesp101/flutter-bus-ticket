import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScanHistory extends StatefulWidget {
  ScanHistory({Key? key, this.query}) : super(key: key);

  final query;

  @override
  _Seats createState() => _Seats(query: query);
}

class _Seats extends State<ScanHistory> {
  _Seats({this.query});

  final query;

  @override
  Widget build(BuildContext context) {
    var x = FirebaseFirestore.instance
        .collection('tickets')
        .where('status', isEqualTo: 'Used');

    return Scaffold(
      appBar: AppBar(
          title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ticket List'),
        ],
      )),
      body: Padding(
          padding: EdgeInsets.all(10),
          child: FutureBuilder<QuerySnapshot>(
            future: x.get(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.data?.size == 0) {
                return Text('No tickets found');
              }

              if (snapshot.connectionState == ConnectionState.done) {
                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                return ListView(
                  children: documents
                      .map((e) => Card(
                            child: ListTile(
                              title: Text(e.id),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e['email']),
                                      Text(
                                        'Seats: x ${e["passengers"].toString()}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      )
                                    ],
                                  ),
                                  Text("Bus No:  " + e['bus_no']),
                                  Text("Departure Time:  " + e['departure_time']),
                                  Text("Departure Date:  " +e['departure_date']),
                                  SizedBox(height:15),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                );
              }

              return Text('Loading');
            },
          )),
    );
  }

  String censor(String str) {
    var first = str[0];
    var last = str.substring(str.length - 5, str.length);

    str = str.substring(1, str.length - 5);
    str = str.replaceAll(RegExp(r'[a-zA-Z0-9]'), '*');
    str = '$first$str$last';

    return str;
  }
}
