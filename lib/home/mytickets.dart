import 'package:busticket/home/qrcode.dart';
import 'package:busticket/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class MyTicketsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyTicketsState();
}

class _MyTicketsState extends State<MyTicketsPage> {
  final firebaseTicket = FirebaseFirestore.instance
      .collection('tickets')
      .withConverter<FirestoreBusTicket>(
          fromFirestore: (snapshot, _) =>
              FirestoreBusTicket.fromJson(snapshot.data()!),
          toFirestore: (ticket, _) => ticket.toJson());

  List<FirestoreBusTicket> tickets = [];

  Future loadTickets() async {
    tickets = [];
    var x = await firebaseTicket
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .orderBy('date', )
        .get() ;

    var e = await Future.forEach(x.docs, (dynamic element) async {
      var from1 = await element.data().routeid.get();
      var from2 = await from1.data()['from'].get();
      var from = await from2.data();

      var to1 = await element.data().routeid.get();
      var to2 = await to1.data()['to'].get();
      var to = await to2.data();

      tickets.add(FirestoreBusTicket(
        routeid: {
          'ticketid': element.id,
          'id': element.data().routeid.id,
          'from': from['name'],
          'to': to['name']

        },
        passengers: element.data().passengers,
        total: element.data().total,
        date: element.data().date,
        status: element.data().status,
        departure_time: element.data().departure_time,
        departure_date: element.data().departure_date,
        bus_no: element.data().bus_no
      ));
    });
    return x;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: FutureBuilder(
        future: loadTickets(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          if (snapshot.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text('Something went wrong.')],
            );
          }


          if (snapshot.hasData) {
            return 
            listTickets();
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text('Loading')],
            );
          }
        },
      ),
    );
  }

  Widget listTickets() {
    if (tickets.length == 0){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[ Text("You have no tickets.")],
      );

    }else
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () {
              print(tickets[index]);
              // setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          QRCodePage(ticketInfo: tickets[index])));
              // });
            },
            child: Padding(
              padding: const EdgeInsets.all(27),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        ' ${tickets[index].routeid["from"]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.arrow_right_alt_rounded,
                        size: 30,
                      ),
                      Text('${tickets[index].routeid["to"]}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  Text('Code:    ${tickets[index].routeid["ticketid"]}'),
                  SizedBox(height: 16),
                  Text('Date:    ${tickets[index].date}'),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Status: '),
                      Text(
                        '${tickets[index].status}',
                        style: statusStyle(tickets[index].status),
                      ),
                    ],
                  ),
                  Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Bus No:           ${tickets[index].bus_no}'),
                      Text('Departure Time:   ${tickets[index].departure_time}'),
                      Text('Departure Date:   ${tickets[index].departure_date}'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Passengers: '),
                      Text(
                        'x ${tickets[index].passengers}  ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: '),
                      Text(
                        'P ${NumberFormat("#,##0.00", "en_US").format(tickets[index].total)}',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TextStyle statusStyle(String status) {
    var backgroundColor;
    var color;
    switch (status) {
      case "Available":
        backgroundColor = Colors.green[400];
        color = Colors.white;
    }

    return TextStyle(
      backgroundColor: backgroundColor,
      color: color,
      fontWeight: FontWeight.w700,
    );
  }
}
