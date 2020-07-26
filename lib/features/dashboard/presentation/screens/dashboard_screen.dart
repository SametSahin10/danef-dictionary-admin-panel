import 'package:flutter/material.dart';

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
                onPressed: handleDeleteAllWords,
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
                onPressed: handleUploadWords,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void handleUploadWords() {

}

void handleDeleteAllWords() {

}
