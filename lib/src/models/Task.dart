import "package:json_annotation/json_annotation.dart";

part "Task.g.dart";

@JsonSerializable()
class Task {
  String title;
  bool status;

  Task({this.title, this.status});

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);

  @override
  String toString() {
    return "{'title': '${this.title}', 'status': '${this.status}}'";
  }
}