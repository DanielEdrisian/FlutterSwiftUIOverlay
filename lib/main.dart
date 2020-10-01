// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const EventChannel _platformEventChannel =
    const EventChannel('overlay_ios.flutter.io/responder');

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlutterDemo(),
    ),
  );
}

class FlutterDemo extends StatefulWidget {
  FlutterDemo({Key key}) : super(key: key);

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  double platformTouchPoint;

  @override
  void initState() {
    super.initState();

    _platformEventChannel.receiveBroadcastStream().listen((dynamic touchPoint) {
      if (touchPoint != platformTouchPoint)
        setState(() => platformTouchPoint = touchPoint);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[Align(child: Text(platformTouchPoint.toString()))],
      ),
    );
  }
}
