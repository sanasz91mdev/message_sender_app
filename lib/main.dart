import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sms_maintained/sms.dart';
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
  bool isLoading = false;

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
              child: Text(
                'Open File',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.purple,
            )
          ],
        ),
      ),
    );
  }

  void _pickFile() async {
    try {
      File fileXlxs = await FilePicker.getFile();
      print(fileXlxs.path);
      var xcelRows = parseFile(fileXlxs.path);
      List<Data> dataList = fillData(xcelRows);
print("progress");
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          content: ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Please wait ...'),
          ),
        ),
      );

      //send sms
      for (var item in dataList) {
        if (!(item.amount.contains("-") || item.amount == "0")) {
          SmsSender sender = new SmsSender();
          String address = item.contactNumber;
          await sender.sendSms(new SmsMessage(address, item.message));
        }
      }

      Navigator.of(context).pop();

      Alert(
        context: context,
        type: AlertType.success,
        title: "Success!",
        desc: 'Messages sent',
        buttons: [
          DialogButton(
            color: Colors.green,
            child: Text("OK",
                style: Theme.of(context).textTheme.title.copyWith(
                      color: Colors.white,
                    )),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ).show();
    } catch (e) {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Oops!",
        desc: 'Something Bad Happened.',
        buttons: [
          DialogButton(
            color: Colors.green,
            child: Text("DISMISS",
                style: Theme.of(context).textTheme.title.copyWith(
                      color: Colors.white,
                    )),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ).show();
    }
  }

  List<List<dynamic>> parseFile(String path) {
    try {
      var bytes = File(path).readAsBytesSync();
      var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
      for (var table in decoder.tables.keys) {
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
      dataRows.add(Data(
          serialNo: (row[0]?.toString()),
          flatNo: row[1],
          contactName: row[2],
          noOfMonths: row[3]?.toString(),
          amount: row[4]?.toString(),
          contactNumber: row[5],
          message: row[6]
              ?.toString()
              ?.replaceAll("<Flat No.>", row[1]?.toString())
              ?.replaceAll("<Amount Outstanding>", row[4]?.toString())));
    }

    dataRows.removeAt(0);
    print('Length');
    print(dataRows.length.toString());

    for (var item in dataRows) {
      print(item.message);
    }

    return dataRows;
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
