import 'package:flutter/material.dart';
import 'package:iit_app/screens/account.dart';
import 'package:iit_app/screens/loginPage.dart';
import 'package:iit_app/screens/settings.dart';
import 'package:iit_app/screens/create.dart';
import 'package:iit_app/model/workshop_create.dart';
import 'package:iit_app/model/user_data.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/Home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User _user = new User(2);
  Drawer getNavDrawer(BuildContext context) {
    ListTile getNavItem(var icon, String s, String routeName,
        {bool replacement = false}) {
      return ListTile(
        leading: Icon(icon),
        title: Text(s),
        onTap: () {
          setState(() {
            // pop closes the drawer
            Navigator.of(context).pop();
            // navigate to the route
            if (replacement)
              Navigator.of(context).pushReplacementNamed(routeName);
            else
              Navigator.of(context).pushNamed(routeName);
          });
        },
      );
    }

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(child: Text("Header")),
          getNavItem(Icons.plus_one, "Create Workshop", CreateScreen.routeName),
          getNavItem(Icons.settings, "Settings", SettingsScreen.routeName),
          getNavItem(Icons.home, "Home", HomeScreen.routeName, replacement: true),
          getNavItem(Icons.account_box, "Account", AccountScreen.routeName),
          getNavItem(Icons.exit_to_app, 'Logout', LoginPage.routeName),
          AboutListTile(
              child: Text("About"),
              applicationName: "Gymkhana IIT(BHU)",
              applicationVersion: "v1.0.0",
              applicationIcon: Icon(Icons.business),
              aboutBoxChildren: <Widget>[
                Text('Front End: @nishantkr18'),
                Text('Back End: @nishantwrp, @krashish8')
              ],
              icon: Icon(Icons.info)),
        ],
      ),
    );
  }

  _buildCard({
    String title,
    String date,
    String time,
    String club,
    int goingGlobal,
    User user,
  }) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: InkWell(
          // onTap: () {
          //   Navigator.of(context)
          //       .push(MaterialPageRoute(builder: (context) => DetailPage()));
          // },
          child: Stack(
            children: <Widget>[
              Container(
                height: 275.0,
                width: 200.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                        image: AssetImage(Workshop.imgPath[club]),
                        fit: BoxFit.cover)),
              ),
              // make the shade a bit deeper.
              Container(
                height: 275.0,
                width: 200.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black.withOpacity(0.5)),
              ),
              Positioned(
                  top: 20.0,
                  left: 10.0,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            height: 25,
                            // width: 60.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              // color: Colors.black.withOpacity(0.5)
                            ),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.date_range,
                                    color: Colors.white, size: 12.0),
                                SizedBox(width: 4.0),
                                Text(
                                  date,
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            )),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 25,
                            // width: 60.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              // color: Colors.black.withOpacity(0.5)
                            ),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.timer,
                                    color: Colors.white, size: 12.0),
                                SizedBox(width: 4.0),
                                Text(
                                  time,
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            )),
                          ),
                        ],
                      ),
                    ],
                  )),
              Positioned(
                top: 200.0,
                left: 10.0,
                child: Container(
                  width: 150.0,
                  child: Text(title,
                      style: TextStyle(
                          fontFamily: 'Opensans',
                          fontSize: 17.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              Positioned(
                  top: 230.0,
                  left: 10.0,
                  child: Row(children: [
                    Text('People going',
                        style: TextStyle(
                            fontFamily: 'Opensans',
                            fontSize: 13.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w100)),
                    SizedBox(width: 30.0),
                    IconButton(
                      padding: EdgeInsets.fromLTRB(13.0, 0, 0, 0),
                      icon: Icon(
                        Icons.people,
                        size: 30,
                      ),
                      color: user.going[title] ? Colors.blue : Colors.white,
                      onPressed: () {
                        setState(() {
                          user.going[title] = !user.going[title];
                          print(user.going[title]);
                        });
                      },
                    ),
                    Text(
                      goingGlobal.toString(),
                      style: TextStyle(color: Colors.white54, fontSize: 10.0),
                    ),
                  ]))
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getNavDrawer(context),
      body: Builder(
        builder: (context) => ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  Stack(
                    children: <Widget>[
                      Container(height: 60.0, width: 60.0),
                      Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/profile_test.jpg'),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(25.0)),
                      ),
                      Positioned(
                        left: 5.0,
                        top: 40.0,
                        child: Container(
                          height: 15.0,
                          width: 15.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.5),
                              color: Colors.green,
                              border: Border.all(
                                  color: Colors.white,
                                  style: BorderStyle.solid,
                                  width: 1.0)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'The Official',
                    style: TextStyle(
                        fontFamily: 'Opensans',
                        fontSize: 50.0,
                        color: Color(0xFFFD6F4F)),
                  ),
                  Text(
                    'IIT(BHU) App',
                    style: TextStyle(
                      fontFamily: 'Opensans',
                      fontSize: 40.0,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 50, 30, 15),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Most Popular Workshops:',
                        style: TextStyle(
                          fontFamily: 'Opensans',
                          fontSize: 20.0,
                        )),
                    // IconButton(
                    //     icon: Icon(Icons.more_horiz, color: Colors.black),
                    //     onPressed: () => print(_user.going)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                height: 300.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    _buildCard(
                        title: 'Dev Extravaganza',
                        date: '24th Sept',
                        time: '12:40pm',
                        club: 'COPS',
                        goingGlobal: 204,
                        user: _user),
                    _buildCard(
                        title: 'Intro to Arduino',
                        date: '26th Sept',
                        time: '6:30pm',
                        club: 'Robotics',
                        goingGlobal: 119,
                        user: _user),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}