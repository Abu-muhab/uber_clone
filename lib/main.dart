import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uber',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Uber'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height:  MediaQuery.of(context).size.height*0.7,
              child:  Image.asset("images/welcomeIcon.jpg",fit: BoxFit.fill,),
            ),
            Padding(
              padding: EdgeInsets.all( MediaQuery.of(context).size.width*0.07),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.07,
                      height: MediaQuery.of(context).size.width*0.07,
                      child: Image.asset("images/nigeria.png"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05),
                    child: Text(
                      "+234",
                      style:
                          TextStyle(fontSize: MediaQuery.of(context).size.width*0.05, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.025),
                    child: Text(
                      "Enter your mobile number",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*0.05,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Divider(),
                ),
                Text("Or connect with social"),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Divider(),
                )
              ],
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding:
                    EdgeInsets.only(left: MediaQuery.of(context).size.width*0.07, bottom: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.07),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(),
                          child: SizedBox(
                            width:  MediaQuery.of(context).size.width*0.07,
                            height:  MediaQuery.of(context).size.width*0.07,
                            child: Image.asset("images/facebook.png"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left:MediaQuery.of(context).size.width*0.05),
                          child: Text(
                            "Facebook",
                            style: TextStyle(
                                fontSize:  MediaQuery.of(context).size.width*0.03,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                    EdgeInsets.only(left: MediaQuery.of(context).size.width*0.07,right: MediaQuery.of(context).size.width*0.07),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(),
                          child: SizedBox(
                            width:  MediaQuery.of(context).size.width*0.07,
                            height:  MediaQuery.of(context).size.width*0.07,
                            child: Image.asset("images/google.png"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left:MediaQuery.of(context).size.width*0.05),
                          child: Text(
                            "Google",
                            style: TextStyle(
                                fontSize:  MediaQuery.of(context).size.width*0.03,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
