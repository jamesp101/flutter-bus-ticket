import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:select_dialog/select_dialog.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import '../payment.dart';

class WalkInPage extends StatefulWidget {
  WalkInPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _WalkInPage();
}

class _WalkInPage extends State<WalkInPage> {
  _Location _fromVal = _Location();
  _Location _toVal = _Location();

  List<_Location> _locationList = [];

  List<BusRoute> routes = [];

  String routeError = '';
  String routeId = '';

  num _routePrice = 0.00;
  num _total = 0.00;
  num _passengers = 1;

  BusRoute myRoute = BusRoute();

  final firebaseTicket = FirebaseFirestore.instance
      .collection('tickets')
      .withConverter<FirestoreBusTicket>(
          fromFirestore: (snapshot, _) =>
              FirestoreBusTicket.fromJson(snapshot.data()!),
          toFirestore: (ticket, _) => ticket.toJson());

  @override
  void initState() {
    super.initState();
    getRoutes();
    loadLocationList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [fromWidget(), toWidget()],
          ),
          SizedBox(
            height: 24,
          ),
          routePrice(),
          SizedBox(height: 32),
          Text('Passengers'),
          passengers(),
          Spacer(),
          total(),
          Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              child: Text('PURCHASE'),
              onPressed: () {
                if (myRoute.id == "") {
                  EasyLoading.showError('Complete your route');
                  return;
                }
                setState(() {
                  saveToFirebase();
                });
              },
            )
          ]),
        ],
      ),
    );
  }

  Widget fromWidget() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('STARTING'),
            SizedBox(
              height: 16,
            ),
            Text(
              _fromVal.name,
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            SizedBox(
              height: 8,
            ),
            ElevatedButton(
              child: Text('SELECT'),
              onPressed: () {
                setState(() {
                  setFrom();
                  checkRoute();
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget toWidget() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('DESTINATION'),
            SizedBox(
              height: 16,
            ),
            Text(
              _toVal.name,
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            SizedBox(
              height: 8,
            ),
            destButton(),
          ],
        ),
      ),
    );
  }

  Widget destButton() {
    if (_fromVal.id == '') {
      return ElevatedButton(
        child: Text('SELECT'),
        onPressed: () {},
        style: ButtonStyle(),
      );
    }
    return ElevatedButton(
      child: Text('SELECT'),
      onPressed: () {
        setState(() {
          setTo();
        });
      },
    );
  }

  void setFrom() {
    SelectDialog.showModal<_Location>(context,
        label: 'Select Starting City',
        items: _locationList,
        selectedValue: _fromVal, onChange: (_Location loc) {
      setState(() {
        _fromVal = loc;
      });
    }, itemBuilder: (BuildContext context, _Location item, bool isSelected) {
      return Container(
        decoration: !isSelected
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),
              ),
        child: ListTile(
          selected: isSelected,
          title: Text(item.name),
        ),
      );
    });
  }

  void setTo() {
    SelectDialog.showModal<_Location>(context,
        label: 'Select Destination ',
        selectedValue: _toVal,
        items: _locationList, onChange: (_Location loc) {
      setState(() {
        _toVal = loc;
        checkRoute();
      });
    }, itemBuilder: (BuildContext context, _Location item, bool isSelected) {
      return Container(
        decoration: !isSelected
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),
              ),
        child: ListTile(
          selected: isSelected,
          title: Text(item.name),
        ),
      );
    });
  }

  Future<List<_Location>> loadLocationList() async {
    _locationList = [];
    var routes = await FirebaseFirestore.instance.collection('location').get();
    routes.docs.forEach((element) {
      _locationList.add(_Location(id: element.id, name: element['name']));
    });

    return _locationList;
  }

  Widget passengers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (_passengers - 1 <= 0) {
                return;
              }
              _passengers--;
              this._total = _passengers * this._routePrice;
            });
          },
          child: Text('-'),
        ),
        Text(
          '$_passengers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _passengers++;
              this._total = _passengers * this._routePrice;
            });
          },
          child: Text('+'),
        ),
      ],
    );
  }

  Widget routePrice() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$routeError',
          style: TextStyle(
              color: Color.fromRGBO(255, 0, 0, 1), fontWeight: FontWeight.w300),
        ),
        SizedBox(height: 32),
        Text('Route Price'),
        Text(
          'P ${NumberFormat("#,##0.00", "en_US").format(_routePrice)}',
          style: TextStyle(fontSize: 24),
        ),
      ],
    );
  }

  Widget mult() {
    return Row();
  }

  Widget total() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Total'),
        Text(
          'P ${NumberFormat("#,##0.00", "en_US").format(_total)}',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  void getRoutes() async {
    var x = await FirebaseFirestore.instance.collection('routes').get();
    print('xxxxx');
    x.docs.forEach((DocumentSnapshot element) async {
      print(await element['from']);
      this.routes.add(BusRoute(
            id: element.id,
            from: element['from'].id.toString(),
            to: element['to'].id.toString(),
            price: element['price'],
          ));
    });
  }

  checkRoute() {
    var temp = routes.where((element) {
      return element.from.toString() == _fromVal.id &&
          element.to.toString() == _toVal.id;
    });

    if (temp.toList().isEmpty) {
      this.routeError = 'Route is not available';
      return;
    }
    print(temp.first.price);
    this.routeError = '';
    this._routePrice = temp.first.price;
    this._total = _passengers * this._routePrice;
    myRoute = temp.first;
  }

  Future saveToFirebase() async {
    EasyLoading.show(status: 'Loading');
    FirestoreBusTicket ticket = FirestoreBusTicket(
        routeid: '${myRoute.id}',
        passengers: _passengers,
        total: _total,
        email: 'conductor',
        date: DateTime.now().toString(),
        status: 'Walk-in');

    await firebaseTicket.add(ticket);
    EasyLoading.dismiss();
    EasyLoading.showSuccess('Success');
    print('Ticket: $ticket');
  }
}

class _Location {
  _Location({id = "", name = ""}) {
    this.id = id;
    this.name = name;
  }

  var id = '';
  var name = '';
}

class BusRoute {
  BusRoute({id = "", String from = "", String to = "", price = num}) {
    this.id = id;
    this.from = from;
    this.to = to;
    this.price = price;
  }

  var id = '';
  var from = "";

  var to = "";
  var price;
}
