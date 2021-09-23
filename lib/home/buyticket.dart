import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:select_dialog/select_dialog.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import '../payment.dart';

class BuyTicketPage extends StatefulWidget {
  BuyTicketPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => BuyTicket();
}

class BuyTicket extends State<BuyTicketPage> {
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
          Card(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [fromWidget(), toWidget()],
                ),

                Text(
                  '$routeError',
                  style: TextStyle(
                      color: Color.fromRGBO(255, 0, 0, 1), fontWeight: FontWeight.w300),
                ),

                routePrice(),
                SizedBox(
                  height: 16.0,
                ),
                Divider(),
                Text('Passengers'),
                passengers(),
              ],
            ),
          )),
          SizedBox(
            height: 24,
          ),
          SizedBox(height: 32),
          Spacer(),
          total(),
          Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              child: Text('PURCHASE'),
              onPressed: () {
                if (myRoute.id == "") {
                  EasyLoading.showError('Complete your route');
                  return;
                }

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentPage(
                            ticket: TicketInfo(
                                route: myRoute,
                                total: _total,
                                passengers: _passengers,
                                email:
                                    FirebaseAuth.instance.currentUser!.email!))));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget fromWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'FROM',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
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
        TextButton(
          child: Text('SELECT'),
          onPressed: () {
            setState(() {
              setFrom();
              checkRoute();
            });
          },
        )
      ],
    );
  }

  Widget toWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('TO', style: TextStyle(fontWeight: FontWeight.w900)),
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
    );
  }

  Widget destButton() {
    if (_fromVal.id == '') {
      return TextButton(
        child: Text(
          'SELECT',
        ),
        onPressed: () {},
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith((states) => 
            Theme.of(context).colorScheme.primary.withOpacity(0.5)
          )
        )
        
      );
    }
    return TextButton(
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
    return 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
