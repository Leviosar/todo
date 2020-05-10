class Task {
  String title;
  bool status;

  Task({this.title, this.status});

  @override
  String toString() {
    return "{'title': ${this.title}, 'status': ${this.status}}";
  }
}