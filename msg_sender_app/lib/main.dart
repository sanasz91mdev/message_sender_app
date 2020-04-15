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
  List<Data> _dataList = [];
  String _filePath = "";
  String _numberOfRecords = "0";
  bool isFileSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                child: isFileSelected
                    ? Table(
                        children: <TableRow>[
                          TableRow(
                            decoration: new BoxDecoration(
                                color: Colors.deepPurple[400],
                                borderRadius: BorderRadius.circular(5.0)),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "File Name: ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .copyWith(color: Colors.white),
                                    ),
                                    Text(
                                      _filePath,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                              decoration: new BoxDecoration(
                                  color: Colors.deepPurple[400],
                                  borderRadius: BorderRadius.circular(5.0)),
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          "Number of Records: ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(color: Colors.white),
                                        ),
                                      ),
                                      Text(
                                        _numberOfRecords,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )
                              ])
                        ],
                      )
                    : Container()),
          ),
          ButtonTheme(
            minWidth: 196,
            height: 40,
            child: !isFileSelected
                ? RaisedButton(
                    onPressed: _pickFile,
                    child: Text(
                      'Open File',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.purple,
                  )
                : Container(),
          ),
          isFileSelected
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.deepPurple),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Details ',
                          style: Theme.of(context)
                              .textTheme
                              .title
                              .copyWith(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          new Expanded(child: _buildContactList()),
          isFileSelected
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ProgressButton(
                    borderRadius: 10.0,
                    type: ProgressButtonType.Raised,
                    defaultWidget: const Text('Send SMS',
                        style: TextStyle(color: Colors.white)),
                    progressWidget: const CircularProgressIndicator(),
                    color: Colors.green,
                    width: 100,
                    height: 40,
                    onPressed: _sendSMS,
                  ),
                )
              : Container(),
        ],
      ),
      floatingActionButton: isFileSelected
          ? FloatingActionButton(
              onPressed: _refreshSelections,
              child: Icon(Icons.refresh),
            )
          : Container(),
    );
  }

  Widget _buildContactList() {
    if (_dataList != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: _dataList.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return ListTile(
              isThreeLine: true,
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
        ),
      );
    }

    return Container();
  }

  void _pickFile() async {
    try {
      setState(() {
        isFileSelected = false;
      });

      File fileXlxs = await FilePicker.getFile();
      var xcelRows = parseFile(fileXlxs.path);
      _dataList = fillData(xcelRows);

      setState(() {
        _filePath = fileXlxs.path.split('/').last;
        _numberOfRecords = _dataList.length?.toString();
        isFileSelected = true;
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

    for (var item in dataRows) {
      print(item.message);
    }

    return dataRows;
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

  void _refreshSelections() {
    setState(() {
      isFileSelected = false;
      _dataList = null;
    });
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
