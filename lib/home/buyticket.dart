import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class BuyTicketPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BuyTicket();
}

class BuyTicket extends State<BuyTicketPage>
    with AutomaticKeepAliveClientMixin<BuyTicketPage> {
  var fromValue;
  var toValue;

  final passengersController = TextEditingController();

  Widget toWidget() {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('TO',
              style: TextStyle(
                color: Theme.of(this.context).backgroundColor,
                fontWeight: FontWeight.bold,
              )),
          SizedBox(height: 24),
          DropdownButton<String>(
            hint: Text('SELECT'),
            value: toValue,
            onChanged: (String? newValue) {
              setState(() {
                toValue = newValue!;
                print(newValue);
              });
            },
            items: <String>['CdeO', 'Two', 'Free', 'Four']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    ));
  }

  Widget fromWidget() {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('FROM',
              style: TextStyle(
                color: Theme.of(this.context).backgroundColor,
                fontWeight: FontWeight.bold,
              )),
          SizedBox(height: 24),
          DropdownButton<String>(
            hint: Text('SELECT'),
            onChanged: (String? newValue) {
              setState(() {
                fromValue = newValue!;
                print(newValue);
              });
            },
            value: fromValue,
            items: <String>['One', 'Two', 'Free', 'Four']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    ));
  }

  var passenger = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: fromWidget()),
              Expanded(child: toWidget()),
            ],
          ),
          Spacer(),
          Text('Passengers'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (passenger - 1 <= 0) {
                      return;
                    }
                    passenger--;
                  });
                },
                child: Text('-'),
              ),
              SizedBox(width: 50),
              Text(
                '$passenger',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 50),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    passenger++;
                  });
                },
                child: Text('+'),
              ),
            ],
          ),
          Spacer(),
          ElevatedButton(
            child: Text('PURCHASE'),
            onPressed: () {
              setState(() {
                passenger++;
              });
            },
          ),
          Spacer()
        ]));
  }

  @override
  bool get wantKeepAlive => true;
}
