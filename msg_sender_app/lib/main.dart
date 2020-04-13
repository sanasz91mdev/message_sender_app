import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sms_maintained/sms.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRWA',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'SRWA Messaging App'),
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
  List<Data> _dataList = [];
  String _filePath = "File: ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading
          ? Dialog(
              child: Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('Please Wait ... ')
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: Text(_filePath,
                          style: TextStyle(color: Colors.black))),
                  ButtonTheme(
                    minWidth: 196,
                    height: 40,
                    child: RaisedButton(
                      onPressed: _pickFile,
                      child: Text(
                        'Open File',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.purple,
                    ),
                  ),
                  ProgressButton(
                    defaultWidget: const Text('Send SMS',
                        style: TextStyle(color: Colors.white)),
                    progressWidget: const CircularProgressIndicator(),
                    color: Colors.green,
                    width: 196,
                    height: 40,
                    onPressed: _sendSMS,
                  ),
                  new Expanded(child: _buildContactList())
                ],
              ),
            ),
    );
  }

  Widget _buildContactList() {
    if (_dataList != null) {
      return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: _dataList.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return ListTile(
              title: Text(
                  _dataList[index].contactName +
                      "\n(" +
                      _dataList[index].contactNumber +
                      ")",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  )),
              subtitle: Text(_dataList[index].message),
              leading: Icon(
                Icons.message,
                color: Colors.blue[500],
              ));
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      );
    }

    return null;
  }

  void _sendSMS() async {
    try {
      //send sms
      for (var item in _dataList) {
        if (!(item.amount.contains("-") || item.amount == "0")) {
          SmsSender sender = new SmsSender();
          String address = item.contactNumber;
          sender.sendSms(new SmsMessage(address, item.message));
        }
      }

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

  void _pickFile() async {
    try {
      File fileXlxs = await FilePicker.getFile();
      print(fileXlxs.path);
      var xcelRows = parseFile(fileXlxs.path);
      _dataList = fillData(xcelRows);

      setState(() {
        _filePath = "File: " +
            fileXlxs.path +
            "\nTotal records: " +
            _dataList.length.toString();
      });
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
        for (var row in decoder.tables[table].rows) {
          
          print("$row");
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

    // Dummy Data
    // for (int i = 0; i < 500; i++) {
    //   dataRows.add(Data(
    //       serialNo: (i.toString()),
    //       flatNo: "A" + i.toString(),
    //       contactName: "Abdullah_" + i.toString(),
    //       noOfMonths: '4',
    //       amount: (i * 100).toString(),
    //       contactNumber: "03001234" + i.toString().padLeft(3, '0'),
    //       message:
    //           "Dear Resident <Flat No.>, your total outstanding is Rs <Amount Outstanding>. Kindly pay online to Bank A Account Number XYZ. Thanks"
    //               ?.replaceAll("<Flat No.>", "A" + i.toString())
    //               ?.replaceAll("<Amount Outstanding>", (i * 100).toString())));
    // }

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
