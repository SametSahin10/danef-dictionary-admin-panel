import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';

void showProgressDialog({
  @required BuildContext context,
  @required String text,
}) async {
  return await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      );
    },
  );
}

void showSnackBar({
  @required BuildContext context,
  @required String message,
}) {
  Scaffold.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    ),
  );
}

void showAlertDialog({
  @required BuildContext context,
  @required String message,
  @required bool showActions,
  Function onYesPressed,
  Function onNoPressed,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.green,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        actions: showActions
            ? [
                FlatButton(
                  onPressed: () => onYesPressed(context),
                  child: Text("Yes"),
                ),
                FlatButton(
                  onPressed: () => onNoPressed(context),
                  child: Text("No"),
                ),
              ]
            : null,
      );
    },
  );
}
