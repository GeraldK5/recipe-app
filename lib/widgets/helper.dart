


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/views/searchpage.dart';

AppBar appbar(GlobalKey<ScaffoldState> scaffoldkey) {
  return AppBar(
    centerTitle: true,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
    automaticallyImplyLeading: false,
    leading: Padding(
        padding: EdgeInsets.only(left: 10),
        child: IconButton(
          icon: Icon(
            Icons.person_rounded,
            size: 30,
            color: primaryColor,
          ),
          onPressed: () {
            scaffoldkey.currentState?.openDrawer();
          },
        )),
    title: InkWell(
      onTap: () {
       Get.to(Search());
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'What can we get for you?',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
            )
          ],
        ),
      ),
    ),
  );
}

Drawer drawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          accountName: Text('Ichigo Kurosaki',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
          accountEmail: Text(
            '0771170263',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          currentAccountPicture: Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 70,
          ),
        ),
        ListTile(
          onTap: () {},
          leading: Icon(
            Icons.person_outline_rounded,
            color: primaryColor,
          ),
          title: Text(
            'My Information',
            style: TextStyle(fontSize: 20),
          ),
        ),
        ListTile(
          onTap: () {},
          leading: Icon(
            Icons.shopping_bag_outlined,
            color: primaryColor,
          ),
          title: Text(
            'My Orders',
            style: TextStyle(fontSize: 20),
          ),
        ),
        ListTile(
          onTap: () {},
          leading: Icon(
            Icons.person_off_outlined,
            color: primaryColor,
          ),
          title: Text(
            'Delete my Account',
            style: TextStyle(fontSize: 20),
          ),
        ),
        ListTile(
          onTap: () {},
          leading: Icon(
            Icons.logout_rounded,
            color: primaryColor,
          ),
          title: Text(
            'Log Out',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    ),
  );
}

void displaymessage(BuildContext context, String message, bool success) {
  final Snackbar = SnackBar(
      dismissDirection: DismissDirection.up,
      duration: Duration(seconds: 1, milliseconds: 500),
      // margin:
      //     EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 140),
      content: Row(
        children: [
          success
              ? Icon(Icons.check, color: Colors.white)
              : Icon(
                  Icons.error,
                  color: Colors.white,
                ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Wrap(children: [
            Text(
              message,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.fade,
            )
          ])),
        ],
      ),
      backgroundColor: success
          ? Color.fromARGB(255, 19, 175, 24)
          : Color.fromARGB(255, 236, 31, 16));
  ScaffoldMessenger.of(context).showSnackBar(Snackbar);
}
