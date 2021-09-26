import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Seats extends StatefulWidget {
  Seats({Key? key, this.query}) : super(key: key);

  final query;

  @override
  _Seats createState() => _Seats(query: query);
}

class _Seats extends State<Seats> {
  _Seats({this.query});

  final query;

  @override
  Widget build(BuildContext context) {
    var x = FirebaseFirestore.instance
        .collection('tickets')
        .where('departure_time', isEqualTo: query['departure_time']!)
        .where('departure_date', isEqualTo: query['departure_date']!)
        .where('bus_no', isEqualTo: query['bus_no']!);

    return Scaffold(
      appBar: AppBar(
          title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ticket List'),
          Text(
              'Bus No: ${query["bus_no"]}  -  ${query["departure_time"]}  -  ${query["departure_date"]}',
              style: TextStyle(fontSize: 12 , fontWeight: FontWeight.w300),
              ),

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

              if (snapshot.data!.size == 0) {
                return Text('No tickets found');
              }

              if (snapshot.connectionState == ConnectionState.done) {
                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                return ListView(
                  children: documents
                      .map((e) => Card(
                            child: ListTile(
                              title: Text(censor(e.id)),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(censor(e['email'])),
                                  Text(
                                    'Seats: x ${e["passengers"].toString()}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
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
