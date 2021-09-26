import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatefulWidget {
  QRCodePage({this.ticketInfo});

  final ticketInfo;

  @override
  State<StatefulWidget> createState() => _QRCodeState(ticketInfo);
}

class _QRCodeState extends State<StatefulWidget> {
  _QRCodeState(this.ticketInfo);

  final ticketInfo;

  @override
  Widget build(BuildContext context) {
    print(ticketInfo);

    return Scaffold(
      appBar: AppBar(title: Text('Ticket')),
      body: Padding(padding: EdgeInsets.all(10), child: body()),
    );
  }

  Widget body() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(27),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImage(
                  data: ticketInfo.routeid['ticketid'],
                  size: 200,
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Show to the conductor.')],
            ),
            Divider(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  ' ${ticketInfo.routeid["from"]}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.arrow_right_alt_rounded,
                  size: 30,
                ),
                Text('${ticketInfo.routeid["to"]}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            Text('Code:    ${ticketInfo.routeid["ticketid"]}'),
            SizedBox(height: 16),
            Text('Date:    ${ticketInfo.date}'),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Status: '),
                Text(
                  '${ticketInfo.status}',
                  style: statusStyle(ticketInfo.status),
                ),
              ],
            ),
            Divider(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Bus No:           ${ticketInfo.bus_no}'),
                    Text('Departure Time:   ${ticketInfo.departure_time}'),
                    Text('Departure Date:   ${ticketInfo.departure_date}'),
                  ],
                ),
            Divider(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Passengers: '),
                Text(
                  'x ${ticketInfo.passengers}  ',
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
                  'P ${NumberFormat("#,##0.00", "en_US").format(ticketInfo.total)}',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
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
