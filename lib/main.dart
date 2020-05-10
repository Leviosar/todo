import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:todo/src/blocs/TodoBloc.dart';
import './src/app.dart';

void main() {
  runApp(
    BlocProvider(
      blocs: [
        Bloc((i) => TodoBloc())
      ],
      child: MaterialApp(
        home: App(),
        theme: ThemeData(
          hintColor: Colors.blue,
        ),
      ),
    )
  );
}