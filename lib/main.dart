import 'dart:async';
import 'dart:convert';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Post> fetchPost() async {
  final response = await http.get('https://ayadi.dev/readings');
  print(response.body);
  if (response.statusCode == 200) {

    // If the server did return a 200 OK response, then parse the JSON.
    return Post.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load post');
  }
}

class Post {
  final int amps;
  final int current_amp;

  Post({this.amps, this.current_amp});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
      amps: int.parse(json['amps']), current_amp: int.parse(json['current']));
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Post> post;
  //int amps = ;
  @override
  void initState() {
    super.initState();
    post = fetchPost();
  }

  void _pressed() {
    setState(() {
      post = fetchPost();
    });
  }

  void _toggle() {
    http.get('');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Solar Power',
            style: TextStyle(
                fontFamily: 'DancingScript', fontSize: 30, color: Colors.white),
          ),
        ),
        body: Center(
          child: FutureBuilder<Post>(
            future: post,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                double x = snapshot.data.current_amp / 10;
                double z = x * 100;
                int y = snapshot.data.amps;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Amps',
                      style: TextStyle(
                        fontFamily: 'DancingScript',
                        fontSize: 90,
                        color: Colors.blue,
                      ),
                    ),
                    Text('$y',
                        style: TextStyle(
                            fontFamily: 'DancingScript',
                            fontSize: 60,
                            color: Colors.blue)),
                    new CircularPercentIndicator(
                      radius: 300.0,
                      lineWidth: 15.0,
                      percent: x,
                      center: new FloatingActionButton(onPressed: null),
                      progressColor: Colors.black,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: _pressed,
                        tooltip: 'fetch',
                        child: Icon(Icons.refresh),
                      ),
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.blue,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: _pressed,
                        tooltip: 'fetch',
                        child: Icon(Icons.refresh),
                      ),
                    )
                  ],
                );
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
