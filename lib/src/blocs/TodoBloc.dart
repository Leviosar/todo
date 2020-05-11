import 'dart:convert';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:todo/src/models/Task.dart';

class TodoBloc extends BlocBase {

  BehaviorSubject<List<Task>> tasks = BehaviorSubject<List<Task>>();
  BehaviorSubject<Task> lastRemoved = BehaviorSubject<Task>();
  BehaviorSubject<int> lastRemovedIndex = BehaviorSubject<int>();

  TodoBloc() {
    tasks.add([]);
    lastRemoved.add(null);
    lastRemovedIndex.add(0);
    this.loadData();
  }

  void loadData() async {
    List<dynamic> loadedData = json.decode(await this.readData()) as List<dynamic>;
    if (loadedData.length > 0) {
      List<Task> taskList = loadedData.map((item) => Task.fromJson(item)).toList();
      this.tasks.add(taskList);
    }
  }

  Future<String> taskListToString() async {
    List<Task> currentTasks = await this.tasks.first;
    String output = "[";

    for (var i = 0; i < currentTasks.length; i++) {
      output += currentTasks[i].toString();
      if (i == currentTasks.length - 1) output += ",";
    }

    output += "]";

    return output;
  }

  Future<File> getFile() async{
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/data.json");
  }

  Future<String> readData() async {
    try {
      return (await this.getFile()).readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<File> saveData() async {
    List<Task> currentTasks = await this.tasks.first;
    String data = json.encode(currentTasks);
    return (await this.getFile()).writeAsString(data);
  }

  void addTask(String text) async {
    List<Task> currentTasks = await this.tasks.first;
    currentTasks.add(Task(title: text, status: false));
    this.tasks.add(currentTasks);
    this.saveData();
  }

  void removeTask(int index) async {
    List<Task> currentTasks = await this.tasks.first;
    this.lastRemoved.add(currentTasks.removeAt(index));
    this.lastRemovedIndex.add(index);
    this.tasks.add(currentTasks);
    this.saveData();
  }

  void restoreLast() async {
    List<Task> currentTasks = await this.tasks.first;
    Task lastRemoved = await this.lastRemoved.first;
    int lastRemovedIndex = await this.lastRemovedIndex.first;

    currentTasks.insert(lastRemovedIndex, lastRemoved);

    this.tasks.add(currentTasks);
    this.saveData();
  }

  void toggleTaskStatus(int index) async {
    List<Task> currentTasks = await this.tasks.first;
    currentTasks[index].status = !currentTasks[index].status;

    this.tasks.add(currentTasks);
    this.saveData();
  }
}