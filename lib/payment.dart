
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pay/flutter_pay.dart';

import '_env.dart';
import 'home/buyticket.dart';
import 'package:intl/intl.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({Key? key, this.ticket}) : super(key: key);

  final ticket;

  @override
  _PaymentPageState createState() => _PaymentPageState(ticket);
}

class _PaymentPageState extends State<PaymentPage> {
  _PaymentPageState(this.ticketInfo);

  final TicketInfo ticketInfo;

  PaymentMethod payMethod = PaymentMethod.gpay;
  PageController _pageController = PageController(initialPage: 0);

  FlutterPay flutterPay = FlutterPay();

  final firebaseTicket = FirebaseFirestore.instance
      .collection('tickets')
      .withConverter<FirestoreBusTicket>(
          fromFirestore: (snapshot, _) =>
              FirestoreBusTicket.fromJson(snapshot.data()!),
          toFirestore: (ticket, _) => ticket.toJson());
  @override
  void initState() {
    super.initState();
    flutterPay.setEnvironment(environment: PaymentEnvironment.Test);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Payment")),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(21),
                      child: Column(
                        children: [
                          Row(children: [
                            Text("From: ${ticketInfo.route.from}")
                          ]),
                          Row(children: [Text("To: ${ticketInfo.route.to}")]),
                          SizedBox(height: 8),
                          Row(children: [
                            Text(
                              "Route ID: ${ticketInfo.route.id}",
                              style: TextStyle(fontWeight: FontWeight.w300),
                            )
                          ]),

                          SizedBox(height: 16),
                          Divider(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                            Text ('Bus No: ${ticketInfo.bus_no}', style: TextStyle(fontWeight: FontWeight.w300)),
                            Text ('Departure time: ${ticketInfo.departure_time}', style: TextStyle(fontWeight: FontWeight.w300)),
                            Text ('Departure date: ${ticketInfo.departure_date}', style: TextStyle(fontWeight: FontWeight.w300)),
                          ],),
                          Divider(),

                          Divider(),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Price: ",
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  'P ${NumberFormat("#,##0.00", "en_US").format(ticketInfo.route.price)}',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Passengers:",
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  "x ${ticketInfo.passengers}",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                )
                              ]),
                          Divider(),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total:",
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  'P ${NumberFormat("#,##0.00", "en_US").format(ticketInfo.total)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20),
                                )
                              ]),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            try {
                              EasyLoading.show(status: "Processing Payment");
                              await payment();
                              await saveToFirebase();
                              EasyLoading.showSuccess('Payment Successful!');
                              Navigator.pop(context);
                            } catch (e) {
                              print(e);
                              EasyLoading.showError(e.toString());
                            } finally {
                              EasyLoading.dismiss();
                            }
                          },
                          child: Text('PROCEED')))
                ])));
  }

  Future payment() async {
    List<PaymentItem> items = [];
    PaymentItem item = PaymentItem(
        name: "${ticketInfo.route} x${ticketInfo.passengers}", price: 0.01);

    items.add(item);

    String token = await flutterPay.requestPayment(
      googleParameters: GoogleParameters(
        gatewayName: gatewayName,
        gatewayMerchantId: gatewayMerchantId,
        merchantId: merchantId,
        merchantName: merchantId,
      ),
      currencyCode: "PHP",
      countryCode: "PH",
      paymentItems: items,
    );
    print(token);
  }

  Future saveToFirebase() async {
    FirestoreBusTicket ticket = FirestoreBusTicket(
        routeid: '${ticketInfo.route.id}',
        passengers: ticketInfo.passengers,
        total: ticketInfo.total,
        email: ticketInfo.email,
        date: DateTime.now().toString(),
        status: 'Available',
        departure_date: ticketInfo.departure_date,
        departure_time: ticketInfo.departure_time,
        bus_no: ticketInfo.bus_no
        );

    await firebaseTicket.add(ticket);
    print('Ticket: $ticket');
  }
}

enum PaymentMethod {
  gpay,
}

class TicketInfo {
  TicketInfo(
      {this.route,
      num passengers = 0,
      num total = 0,
      String email = "",
      String date = "",
      String departure_time="",
      String departure_date="",
      String bus_no = "",
      }) {
    this.passengers = passengers;
    this.total = total;
    this.email = email;
    this.departure_time = departure_time;
    this.departure_date = departure_date;
    this.bus_no = bus_no;
  }

  final route;
  String email = "";
  num passengers = 0;
  num total = 0;
  String date = "";

  String departure_time = "";
  String departure_date =""; 
  String bus_no = "";

  TicketInfo.fromJson(Map<String, Object?> json)
      : this(
            route: json['route']! as BusRoute,
            email: json['email']! as String,
            passengers: json['passengers']! as num,
            total: json['total']! as num,
            date: json['date']! as String,
            departure_time: json['departure_time']! as String,
            departure_date : json['departure_date']! as String,
            bus_no : json['departure_date']! as String,
            );
}

class FirestoreBusTicket {
  FirestoreBusTicket({
    this.routeid,
    this.passengers,
    this.total,
    this.email,
    this.date,
    this.status,
    this.departure_time,
    this.departure_date,
    this.bus_no,
    
  });
  final routeid;
  dynamic passengers;
  dynamic total;
  final email;
  final date;
  final status;
  final departure_time;
  final departure_date;
  final bus_no;

  FirestoreBusTicket.fromJson(Map<String, Object?> json)
      : this(
          routeid: json['routeid'] as dynamic,
          passengers: json['passengers'] as dynamic,
          total: json['total'] as dynamic,
          email: json['email'] as String,
          date: json['date'] as String,
          status: json['status'] as String,
          departure_time: json['departure_time']! as String,
          departure_date : json['departure_date']! as String,
          bus_no : json['departure_date']! as String,

        );

  Map<String, Object?> toJson() {
    return {
      'routeid': FirebaseFirestore.instance.collection('routes').doc(routeid),
      'passengers': passengers,
      'total': total,
      'email': email,
      'date': date,
      'status': status,
      'departure_time': departure_time,
      'departure_date': departure_date,
      'bus_no': bus_no
    };
  }
}
