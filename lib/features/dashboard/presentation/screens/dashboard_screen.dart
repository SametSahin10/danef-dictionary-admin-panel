import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/util/actions.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.2,
              height: screenHeight * 0.1,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                ),
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.006,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Upload words',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onPressed: () => handleUploadWords(context),
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Container(
              width: screenWidth * 0.2,
              height: screenHeight * 0.1,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                ),
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.006,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Delete all words',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onPressed: () => handleDeleteAllWords(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void handleUploadWords(BuildContext context) async {
  await startFilePicker(context);
}

void handleDeleteAllWords(BuildContext context) {
  showAlertDialog(
    context: context,
    message: "All the words will be deleted. Do you confirm?",
    showActions: true,
    onYesPressed: onYesPressed,
    onNoPressed: onNoPressed,
  );
}

Future<void> startFilePicker(BuildContext context) {
  final uploadInput = FileUploadInputElement();
  uploadInput.click();
  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files.length == 1) {
      final file = files[0];
      final reader = FileReader();
      reader.onLoadEnd.listen((event) async {
        print("finished loading file");
        print("file.name: ${file.name}");
        final response = await uploadFileToServer(
          file.name,
          utf8.encode(reader.result),
        );
        print("statusCode: ${response?.statusCode}");
        print("response.body: ${response?.body}");
        String alertDialogMessage;
        if (response == null) {
          alertDialogMessage =
              "Error occured while either uploading file or inserting words";
        } else {
          alertDialogMessage = "Uploading file successful";
        }
        showAlertDialog(
          context: context,
          message: alertDialogMessage,
          showActions: false,
        );
      });
      reader.readAsDataUrl(file);
    }
  });
}

Future<http.Response> uploadFileToServer(
  String fileName,
  List<int> fileAsBytes,
) async {
  // TODO: Use clean architecture.
  print("Uploading file to server");
  final fileUploadUrlString = Constants.baseUrl + Constants.uploadWordsString;
  final request = http.MultipartRequest(
    "POST",
    Uri.parse(fileUploadUrlString),
  );
  request.files.add(http.MultipartFile.fromBytes(
    "words",
    fileAsBytes,
    contentType: MediaType("application", "octet-stream"),
    filename: fileName,
  ));
  final jwtToken = await getTokenFromSharedPrefs();
  final headers = <String, String>{"Authorization": "Bearer $jwtToken"};
  request.headers.addAll(headers);
  try {
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  } catch (err) {
    print("exception occured while uploading file to server");
    print("err: $err");
    return null;
  }
}

Future<bool> deleteWordsFromDatabase(BuildContext context) async {
  // TODO: Use clean architecture.
  final jwtToken = await getTokenFromSharedPrefs();
  final url = Constants.baseUrl + Constants.deleteWordsString;
  try {
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $jwtToken"},
    );
    if (response.statusCode == HttpStatus.ok) {
      final responseBody = json.decode(response.body);
      final status = responseBody['status'];
      if (status == true) {
        print('Deleted words succesfully');
        print('status code ${response.statusCode}');
        print('response body: ${response.body}');
      } else {
        print('Deleting words failed');
        print('status code ${response.statusCode}');
        print('response body: ${response.body}');
      }
      return status;
    } else {
      print('Signing in failed');
      print('status code ${response.statusCode}');
      print('response body: ${response.body}');
      return false;
    }
  } catch (err) {
    print("exception occured while deleting words");
    print("err: $err");
    return false;
  }
}

void onYesPressed(BuildContext context) async {
  print("Yes pressed");
  final success = await deleteWordsFromDatabase(context);
  String alertDialogMessage;
  print("success: $success");
  if (success) {
    alertDialogMessage = "Deleted words successfully";
  } else {
    alertDialogMessage = "Deleting words failed";
  }
  Navigator.of(context).pop();
  showAlertDialog(
    context: context,
    message: alertDialogMessage,
    showActions: false,
  );
}

void onNoPressed(BuildContext context) {
  print("No pressed");
  Navigator.of(context).pop();
}

Future<String> getTokenFromSharedPrefs() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString(Constants.jwtTokenString);
}
