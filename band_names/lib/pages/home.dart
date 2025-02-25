import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverstatus == ServerStatus.Online
                ? Icon(Icons.offline_bolt, color: Colors.blue)
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          _showGrafic(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, i) => _bandTile(bands[i])),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: addNewBand, elevation: 1, child: Icon(Icons.add)),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => deleteBandToList('id: ${band.id.toString()}'),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () => socketService.socket.emit('add-vote', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New band name'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                      textColor: Colors.blue,
                      elevation: 5,
                      onPressed: () => addBandToList(textController.text),
                      child: Text('Add'))
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text('New Band Name'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Add'),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Dismiss'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ));
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  void deleteBandToList(String id) {
    if (id.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('erase-band', {'id': id});
    }
  }

  Widget _showGrafic() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    final List<Color> colorList = [
      Colors.blue.shade50,
      Colors.blue.shade200,
      Colors.pink.shade50,
      Colors.pink.shade200,
      Colors.yellow.shade50,
      Colors.yellow.shade200,
    ];

    return Container(
        width: double.infinity,
        height: 200,
        child: PieChart(
            dataMap: dataMap,
            animationDuration: Duration(milliseconds: 800),
            chartRadius: MediaQuery.of(context).size.width / 3.2,
            colorList: colorList,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "BANDS",
            legendOptions: LegendOptions(
              showLegendsInRow: false,
              showLegends: true,
              legendShape: BoxShape.circle,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: true,
              showChartValuesOutside: false,
              decimalPlaces: 1,
            )));
  }
}
