import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import './ui/Colors.dart';

class App extends StatefulWidget {
    @override
    _AppState createState() => _AppState();
}

class _AppState extends State<App> {

    TextEditingController addInput = TextEditingController(); 
    List _todo = [];
    Map<String, dynamic> _lastRemoved;
    int _lastRemovedPos;

    @override
    void initState() {
        super.initState();
        this._readData().then(
            (data) {
                setState((){
                    this._todo = json.decode(data);
                });
            }
        );
    }
    
    Future<File> _getFile() async{
        final dir = await getApplicationDocumentsDirectory();
        return File("${dir.path}/data.json");
    }

    Future<File> _saveData() async {
        String data = json.encode(this._todo);
        final file = await this._getFile();
        return file.writeAsString(data);
    }

    Future<String> _readData() async {
        try {
            final file = await this._getFile();
            return file.readAsString();
        } catch (e) {
            return null;
        }
    }

    void addTask() {
        setState(() {
            String text = this.addInput.text;
            this._todo.add({"title": text, "status": false});
            this.addInput.text = "";
            this._saveData();
        });
    }

    Widget buildItem(BuildContext context, int index) {
        return Dismissible(
            background: Container(
                color: Colors.red,
                child: Align(
                    alignment: Alignment(-0.9, 0.0),
                    child: Icon(Icons.delete, color: Colors.white),
                )
            ),
            direction: DismissDirection.startToEnd,
            key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
            onDismissed: (direction) {
                setState(() {  
                    this._lastRemoved = Map.from(this._todo[index]);
                    this._lastRemovedPos = index;
                    this._todo.removeAt(index);
                    this._saveData();

                    final snack = SnackBar(
                        content: Text("Task: \"${this._lastRemoved['title']}\" removed"),
                        action: SnackBarAction(
                            label: "Undo",
                            onPressed: () {
                                setState(() {
                                    this._todo.insert(this._lastRemovedPos, this._lastRemoved);
                                    this._saveData();
                                });
                            },
                        ),
                        duration: Duration(seconds: 3),
                    );

                    Scaffold.of(context).showSnackBar(snack);
                });
            },
            child: CheckboxListTile(
                title: Text(this._todo[index]["title"]),
                value: this._todo[index]["status"],
                onChanged: (status) {
                    setState(() {
                        this._todo[index]["status"] = status;
                        this._saveData();
                    });
                },
                secondary: CircleAvatar(
                    child: Icon(_todo[index]["status"] ? Icons.check : Icons.error),
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('To do', style: TextStyle(color: Colors.white),),
                actions: <Widget>[
                    IconButton(icon: Icon(Icons.add), onPressed: () {}, color: Colors.white)
                ],
                backgroundColor: COLORS.secondary,
                centerTitle: true,
            ),
            body: Column(
                children: <Widget>[
                    Container(
                        padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                        child: Row(
                            children: <Widget>[
                                Expanded(
                                    child: TextField(
                                        controller: this.addInput,
                                        decoration: InputDecoration(
                                            labelText: "New task",
                                            labelStyle: TextStyle(color: COLORS.secondary)
                                        ),
                                    ),
                                ),
                                RaisedButton(
                                    child: Text("Add"),
                                    onPressed: this.addTask,
                                    color: COLORS.secondary,
                                    textColor: Colors.white,
                                )
                            ],
                        ),
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: EdgeInsets.only(top: 10.0),
                            itemCount: this._todo.length,
                            itemBuilder: this.buildItem,
                        )
                    )
                ],
            ),
        );
    }
}