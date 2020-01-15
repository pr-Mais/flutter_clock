// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'container_hand.dart';
import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with TickerProviderStateMixin {
  var _now = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF000521),
            // Minute hand.
            highlightColor: Color(0xFF000521),
            // Second hand.
            accentColor: Color(0xFFFF0000),
            backgroundColor: Color(0xFFFFFFFF),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFFFFFFF),
            highlightColor: Color(0xFFFFFFFF),
            accentColor: Color(0xFFFF0000),
            backgroundColor: Color(0xFF000521),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    List<String> weekdays = [
      'SUNDAY',
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
    ];
    List<String> months = [
      '',
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'OCT',
      'SEP',
      'NOV',
      'DEC'
    ];

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        decoration: BoxDecoration(
          /*border: Border.all(
            color: customTheme.primaryColor,
            width: 15,
          ),*/
          color: customTheme.backgroundColor,
        ),
        child: Stack(
          children: [
            // Example of a hand drawn with [CustomPainter].
            Align(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: customTheme.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                        color: customTheme.primaryColor.withOpacity(0.1),
                        offset: Offset(3, 3),
                        spreadRadius: 0.0,
                        blurRadius: 4.0)
                  ],
                  borderRadius: BorderRadius.circular(
                    200,
                  ),
                ),
                width: 230,
                height: 230,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: customTheme.accentColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(
                    200,
                  ),
                ),
                width: 50,
                height: 50,
              ),
            ),
            DrawnHand(
              color: customTheme.accentColor,
              thickness: 1,
              size: 0.8,
              angleRadians: _now.second * radiansPerTick,
            ),
            DrawnHand(
              color: customTheme.highlightColor,
              thickness: 2,
              size: 0.7,
              angleRadians: _now.minute * radiansPerTick,
            ),
            // Example of a hand drawn with [Container].
            ContainerHand(
              color: Colors.transparent,
              size: 0.5,
              angleRadians: _now.hour * radiansPerHour +
                  (_now.minute / 60) * radiansPerHour,
              child: Transform.translate(
                offset: Offset(0.0, -70.0),
                child: Container(
                  width: 6,
                  height: 140,
                  decoration: BoxDecoration(
                    color: customTheme.primaryColor,
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${weekdays[_now.weekday]}, ${months[_now.month]}',
                      style: TextStyle(
                          color: customTheme.primaryColor, fontSize: 10),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: customTheme.primaryColor),
                      width: 10,
                      height: 10,
                      child: Text(
                        _now.day.toString(),
                        style: TextStyle(
                          color: customTheme.backgroundColor,
                          fontSize: 9,
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: customTheme.accentColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 10,
                height: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
