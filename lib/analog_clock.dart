// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'drawn_hand.dart';
import 'flutter_clock_helper/lib/model.dart';

final radiansPerTick = radians(360 / 60);

final radiansPerHour = radians(360 / 12);

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
    _updateTime();
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
            // Background color.
            backgroundColor: Color(0xFFFFFFFF),
          )
        : Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFFFFFFFF),
            // Minute hand.
            highlightColor: Color(0xFFFFFFFF),
            // Second hand.
            accentColor: Color(0xFFFF0000),
            // Background color.
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
    Map<int, String> months = {
      1: 'JAN',
      2: 'FEB',
      3: 'MAR',
      4: 'APR',
      5: 'MAY',
      6: 'JUN',
      7: 'JUL',
      8: 'AUG',
      9: 'SEP',
      10: 'OCT',
      11: 'NOV',
      12: 'DEC'
    };

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: customTheme.primaryColor,
            width: 10,
          ),
          color: customTheme.backgroundColor,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: customTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    200,
                  ),
                ),
                width: 50,
                height: 50,
              ),
            ),
            //Seconds hand.
            DrawnHand(
              color: customTheme.accentColor,
              thickness: 1,
              size: 0.8,
              angleRadians: _now.second * radiansPerTick,
            ),
            //Mins hand.
            DrawnHand(
              color: customTheme.highlightColor,
              thickness: 2,
              size: 0.72,
              angleRadians: _now.minute * radiansPerTick,
            ),
            //Hours hand.
            DrawnHand(
              color: customTheme.highlightColor,
              thickness: 4,
              size: 0.5,
              angleRadians: _now.hour * radiansPerHour +
                  (_now.minute / 60) * radiansPerHour,
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
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
