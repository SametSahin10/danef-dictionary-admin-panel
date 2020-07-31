import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:danef_dictionary_admin_panel/core/util/navigation.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.25,
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
                    child: ListTile(
                      leading: Icon(
                        Icons.file_upload,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Upload words',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                onPressed: () => handleUploadWords(context),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              width: screenWidth * 0.25,
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
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Delete all words',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                onPressed: () => handleDeleteAllWords(context),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              width: screenWidth * 0.25,
              height: screenHeight * 0.1,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                ),
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.006,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                onPressed: () => handleLogout(context),
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
      final fileReader = FileReader();
      fileReader.onLoadEnd.listen((event) async {
        debugPrint("finished loading file");
        debugPrint("file.name: ${file.name}");
        final splitResult = (fileReader.result as String).split(",");
        final base64Part = splitResult[1];
        final response = await uploadFileToServer(
          file.name,
          base64.decode(base64Part),
        );
        debugPrint("statusCode: ${response?.statusCode}");
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
      fileReader.readAsDataUrl(file);
    }
  });
}

Future<http.Response> uploadFileToServer(
  String fileName,
  List<int> fileAsBytes,
) async {
  // TODO: Use clean architecture.
  debugPrint("Uploading file to server");
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
    debugPrint("exception occured while uploading file to server");
    debugPrint("err: $err");
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
        debugPrint('Deleted words succesfully');
        debugPrint('status code ${response.statusCode}');
      } else {
        debugPrint('Deleting words failed');
        debugPrint('status code ${response.statusCode}');
      }
      return status;
    } else {
      debugPrint('Signing in failed');
      debugPrint('status code ${response.statusCode}');
      return false;
    }
  } catch (err) {
    debugPrint("exception occured while deleting words");
    debugPrint("err: $err");
    return false;
  }
}

void onYesPressed(BuildContext context) async {
  final success = await deleteWordsFromDatabase(context);
  String alertDialogMessage;
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
  Navigator.of(context).pop();
}

Future<void> handleLogout(BuildContext context) async {
  await removeTokenFromSharedPrefs();
  pushSignInScreen(context);
}

Future<String> getTokenFromSharedPrefs() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString(Constants.jwtTokenString);
}

Future<bool> removeTokenFromSharedPrefs() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return await sharedPreferences.clear();
}
