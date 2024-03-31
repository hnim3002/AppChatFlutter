

import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 15.0,
);

const kMessageTextFieldDecoration = InputDecoration(

  isDense: true,
  // Alternatively, you can use visualDensity
  // visualDensity: VisualDensity(vertical: -4),
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  labelText: '',
  hintText: '',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
