import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Sms Sender'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: _pickFile,
              child: Text('Open File'),
              color: Colors.purple,
            )
          ],
        ),
      ),
    );
  }

  void _pickFile() async {
    File fileXlxs = await FilePicker.getFile();
    print(fileXlxs.path);
    var xcelRows = parseFile(fileXlxs.path);
    fillData(xcelRows);
  }

  List<List<dynamic>> parseFile(String path) {
    try {
      var bytes = File(path).readAsBytesSync();
      var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
      for (var table in decoder.tables.keys) {
        for (var row in decoder.tables[table].rows) {
          print("$row");
          // print(row.toString());
        }
        return decoder.tables[table].rows;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<Data> fillData(List<List<dynamic>> xcelRows) {
    List<Data> dataRows = new List<Data>();

    for (var row in xcelRows) {
      print(row[0]?.toString());
      print('======');
            print(row[1]?.toString());

      dataRows.add(Data(
          serialNo: (row[0]?.toString()),
          flatNo: row[1],
          contactName: row[2],
          noOfMonths: row[3]?.toString(),
          amount: row[4]?.toString(),
          contactNumber: row[5],
          message: row[6]));
    }

    dataRows.removeAt(0);

    for(var item in dataRows)
    {
      print(item.message);
    }

  }
}

class Data {
  final String serialNo;
  final String flatNo;
  final String contactName;
  final String noOfMonths;
  final String amount;
  final String contactNumber;
  final String message;

  Data(
      {this.serialNo,
      this.flatNo,
      this.contactName,
      this.noOfMonths,
      this.amount,
      this.contactNumber,
      this.message});
}
