import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:vote_app/app/models/candidate.dart';
import 'package:vote_app/app/services/socket_service.dart';


class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late SocketService _socketService;
  List<Candidate> candidates = [];


  @override
  void initState() {
    super.initState();

    _socketService = Provider.of<SocketService>(context, listen: false);

    _socketService.socket.on('active-candidates', _handleCandidates);
    
  }

  void _handleCandidates(dynamic payload) {
    candidates = (payload as List).map((v) => Candidate.fromMap(v)).toList();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidatos', style: TextStyle( color: Colors.black87 ) ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 10),
            child: _socketService.serverStatus == ServerStatus.online 
              ? Icon(Icons.check_circle, color: Colors.blue[300])
              : const Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ]
      ),
      body: Column(
        children: [
          _graphTile(),
          Expanded(
            child: ListView.builder(
              itemCount: candidates.length,
              itemBuilder: ( context, i ) => _voteTile( candidates[i] )
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon( Icons.add ),
        elevation: 1,
        onPressed: addNewVote
      ),
   );
  }

  Widget _voteTile( Candidate candidate ) {
    return Dismissible(
      key: Key(candidate.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ) {
        _socketService.socket.emit('delete-candidate', { "id": candidate.id });
      },
      background: Container(
        padding: const EdgeInsets.only( left: 8.0 ),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Vote', style: TextStyle( color: Colors.white) ),
        )
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( candidate.name!.substring(0,2) ),
          backgroundColor: Colors.blue[100],
        ),
        title: Text( candidate.name! ),
        trailing: Text('${ candidate.votes }', style: const TextStyle( fontSize: 20) ),
        onTap: () {
          _socketService.socket.emit('vote', {"id": candidate.id});
        },
      ),
    );
  }

  addNewVote() {
    final textController = TextEditingController();
    if ( Platform.isAndroid ) {
      // Android
      return showDialog(
        context: context,
        builder: ( context ) {
          return AlertDialog(
            title: const Text('New candidate name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                child: const Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addVoteToList( textController.text )
              )
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: ( _ ) {
        return CupertinoAlertDialog(
          title: const Text('New candidate name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addVoteToList( textController.text )
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        );
      }
    );

  }  

  void addVoteToList( String name ) {
    if ( name.length > 1 ) {
      _socketService.socket.emit('add-candidate', {"name": name});
    }
    Navigator.pop(context);
  }

  Widget _graphTile() {
    Map<String, double> dataMap = {};
    
    for (var e in candidates) {
      dataMap.putIfAbsent(e.name ?? '', () => e.votes?.toDouble() ?? 0);
    }

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: dataMap.isNotEmpty 
        ? PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 3.2,
            colorList: _colors,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            legendOptions: const LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.right,
              showLegends: true,
              legendShape: BoxShape.circle,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 1,
            ),
          )
        : const SizedBox.shrink(),
    );
  }

  final List<Color> _colors = [
    Colors.blue[300]!,
    Colors.purple,
    Colors.amber,
    Colors.teal,
  ];

}