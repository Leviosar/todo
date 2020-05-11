import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:todo/src/blocs/TodoBloc.dart';
import 'models/Task.dart';
import 'ui/Colors.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  TextEditingController addInput = TextEditingController();
  ColorPallette pallette = ColorPallette();

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Procrastinalist', style: TextStyle(color: Colors.white)),
        backgroundColor: pallette.secondary,
        centerTitle: true,
      ),
      body: this.buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          BlocProvider.getBloc<TodoBloc>().addTask(this.addInput.text);
          this.addInput.text = '';
        },
        backgroundColor: Theme.of(context).accentColor
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildBody() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: this.addInput,
                  decoration: InputDecoration(
                    labelText: "New task",
                    labelStyle: TextStyle(color: pallette.secondary)
                  ),
                ),
              ),
            ],
          ),
        ),
        this.buildList()
      ],
    );
  }

  Widget buildList() {
    return StreamBuilder<List<Task>>(
      stream: BlocProvider.getBloc<TodoBloc>().tasks,
      builder: (BuildContext context, AsyncSnapshot<List<Task>> tasks) {
        if (tasks.hasData) {
          return Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: tasks.data.length,
              itemBuilder: (BuildContext context, int index) => this.buildItem(context, index, tasks.data),
            )
          );
        } else {
          return Container();
        }
      }
    );
  }

  Widget buildItem(BuildContext context, int index, List<Task> tasks) {
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
      onDismissed: (DismissDirection direction) => this.onDismiss(context, direction, index, tasks[index]),
      child: CheckboxListTile(
        title: Text(tasks[index].title),
        value: tasks[index].status,
        onChanged: (status) {
          BlocProvider.getBloc<TodoBloc>().toggleTaskStatus(index);
        },
        secondary: CircleAvatar(
          foregroundColor: tasks[index].status ? Colors.white : Colors.white,
          backgroundColor: tasks[index].status ? this.pallette.success : this.pallette.warning,
          child: Icon(tasks[index].status ? Icons.check : Icons.error),
        ),
      ),
    );
  }

  void onDismiss(BuildContext context, DismissDirection direction, int index, Task task) async {
    BlocProvider.getBloc<TodoBloc>().removeTask(index);

    final snack = SnackBar(
      content: Text("Task: \"${task.title}\" removed"),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          BlocProvider.getBloc<TodoBloc>().restoreLast();
        },
      ),
      duration: Duration(seconds: 3),
    );

    Scaffold.of(context).showSnackBar(snack);
  }

}
