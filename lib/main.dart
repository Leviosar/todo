import 'package:flutter/material.dart';
import './src/app.dart';

void main() {
    runApp(
        MaterialApp(
            home: App(),
            theme: ThemeData(
                hintColor: Colors.blue,
            ),
        )
    );
}