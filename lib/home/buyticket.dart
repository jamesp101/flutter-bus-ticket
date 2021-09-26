import 'dart:math';
import 'dart:ui';

import 'package:busticket/home/seats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  String _datePicked =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

  String _timePicked = '8:00 AM';
  String _busPicked = '2000';
  var availableSeats = 0;

  var seatLoading = true;

  BusRoute myRoute = BusRoute();

  @override
  void initState() {
    super.initState();
    getRoutes();
    loadLocationList();
    getAvailableSeats();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [fromWidget(), toWidget()],
                ),
                Text(
                  '$routeError',
                  style: TextStyle(
                      color: Color.fromRGBO(255, 0, 0, 1),
                      fontWeight: FontWeight.w300),
                ),
                routePrice(),
                Divider(),
                Text('Passengers'),
                passengers(),
                Divider(),
                departureWidget(),
                SizedBox(height: 1.0),
                Divider(),
                busWidget()
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

                if (availableSeats + _passengers > 20) {
                  EasyLoading.showError('Bus is full');
                  return;
                }

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentPage(
                                ticket: TicketInfo(
                              departure_time: _timePicked,
                              departure_date: _datePicked,
                              bus_no: _busPicked,
                              route: myRoute,
                              total: _total,
                              passengers: _passengers,
                              email: FirebaseAuth.instance.currentUser!.email!,
                            ))));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget departureWidget() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text('Departure'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () {
                    SelectDialog.showModal<String>(context,
                        label: 'Select Time',
                        items: [
                          '1:00 AM',
                          '2:00 AM',
                          '3:00 AM',
                          '4:00 AM',
                          '5:00 AM',
                          '6:00 AM',
                          '7:00 AM',
                          '8:00 AM',
                          '9:00 AM',
                          '10:00 AM',
                          '11:00 AM',
                          '12:00 PM',
                          '1:00 PM',
                          '2:00 PM',
                          '3:00 PM',
                          '4:00 PM',
                          '5:00 PM',
                          '6:00 PM',
                          '7:00 PM',
                          '8:00 PM',
                          '9:00 PM',
                          '10:00 PM',
                          '11:00 PM',
                          '12:00 AM',
                        ], onChange: (String selected) {
                      setState(() {
                        _timePicked = selected;
                        getAvailableSeats();
                      });
                    });
                  },
                  child: Text(_timePicked)),
              TextButton(
                  onPressed: () async {
                    var p = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(_datePicked),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 60)));

                    setState(() {
                      _datePicked =
                          DateFormat('yyyy-MM-dd').format(p!).toString();
                      getAvailableSeats();
                    });
                  },
                  child: Text(_datePicked)),
            ],
          ),
        ],
      ),
    );
  }

  Widget busWidget() {
    return SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text('Select Bus'),
                TextButton(
                    onPressed: () {
                      SelectDialog.showModal<String>(context,
                          label: 'Select Bus',
                          items: [
                            '2000',
                            '2001',
                            '2002',
                            '2003',
                          ], onChange: (String selected) {
                        setState(() {
                          _busPicked = selected;
                          getAvailableSeats();
                        });
                      });
                    },
                    child: Text(_busPicked))
              ],
            ),
            Column(
              children: [
                Text('Seats'),
                TextButton(
                    onPressed: () {
                      if (seatLoading){
                        return;
                      }

                      Map<String, dynamic> query = {
                        'departure_time': _timePicked,
                        'departure_date': _datePicked,
                        'bus_no': _busPicked
                      };

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Seats(
                              query: query
                            )  ));

                    },
                    child: (seatLoading)
                        ? Text('Loading')
                        : Text('$availableSeats/20',
                            style: TextStyle(
                                color: (availableSeats == 20)
                                    ? Colors.red
                                    : Theme.of(context).primaryColor)))
              ],
            )
          ],
        ));
  }

  Future getAvailableSeats() async {
    setState(() {
      seatLoading = true;
    });
    availableSeats = 0;

    FirebaseFirestore.instance
        .collection('tickets')
        .where('departure_date', isEqualTo: _datePicked)
        .where('departure_time', isEqualTo: _timePicked)
        .where('bus_no', isEqualTo: _busPicked)
        .get()
        .then((QuerySnapshot value) {
      value.docs.forEach((element) {
        availableSeats += element['passengers'] as int;
      });

      setState(() {
        availableSeats = availableSeats;
        seatLoading = false;
        print('$availableSeats:Available Seats');
        print('$_datePicked:DatePicked');
      });
    });
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
                  Theme.of(context).colorScheme.primary.withOpacity(0.5))));
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
    return Column(
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
