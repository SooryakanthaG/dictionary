import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dictionary',
        home: Home()
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {

  String _url = "https://owlbot.info/api/v4/dictionary/";
  String _token = "78d9ef6d9b330bd7488a60649349afc5cc7c47a5";

  TextEditingController _controller = TextEditingController();

  StreamController _streamController;
  Stream _stream;

  Timer _timer;

  _search() async{
    if(_controller.text == null || _controller.text.length == 0){
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");
    Response response = await get(_url+_controller.text.trim(), headers: {"Authorization":" Token " +_token});
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dictionary',style: TextStyle(
          fontSize: 25.0
        ),),
        centerTitle: true,
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0)
                  ),
                  child: TextFormField(
                    onChanged: (String text){
                      if(_timer?.isActive ?? false) _timer.cancel();
                      _timer = Timer(Duration(seconds: 1), (){
                        _search();
                      }
                        );
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search here",
                      contentPadding: EdgeInsets.only(left: 24),
                      border: InputBorder.none
                    ),
                  ),
                ),
              ),
              IconButton(
                iconSize: 30,
                alignment: Alignment.bottomLeft,
                icon: Icon(Icons.search, color: Colors.black,),
                onPressed: () => _search(),
              )
            ],
          ),
        ),
      ),
      body:Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage('https://cloudfront-us-east-1.images.arcpublishing.com/advancelocal/IEHBDGGVCRH57MTPCXOFYWMI7M.JPG'),
              fit: BoxFit.cover
          ),
        ),
        child: StreamBuilder(
              stream: _stream,
              builder: (BuildContext context,AsyncSnapshot snapshot){
                if(snapshot.data == null) {
                  return Center(
                        child:Text(
                          'Enter the word to be searched',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.justify,),
                  );
                }
                if(snapshot.data == "waiting")
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      backgroundColor: Colors.grey[40],
                    ),
                  );
                try {
                  return ListView.builder(
                      itemCount: snapshot.data["definitions"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListBody(
                          children: [
                            Container(
                              color: Colors.grey[100],
                              child: ListTile(
                                leading: snapshot.data["definitions"][index]["image_url"] == null ? Icon(Icons.insert_emoticon) : CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"]
                                  ),
                                ),
                                title: Text(
                                  _controller.text.trim() + " (" + snapshot.data["definitions"][index]["type"] + ")",
                                  style: TextStyle(
                                      fontSize: 20.0
                                  ),),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: snapshot.data["definitions"][index]["definition"] == null ? null : Text(
                                snapshot.data["definitions"][index]["definition"],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18
                                ),
                              )
                            ),

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: snapshot
                                  .data["definitions"][index]["example"] == null
                                  ? null
                                  : Text("Eg. " + snapshot
                                  .data["definitions"][index]["example"],
                                style: TextStyle(color: Colors.white,fontSize: 18),),
                            )
                          ],
                        );
                        });
                }
                catch(exception){
                  return Center(
                    child: Container(
                      child: Text(
                        "Sorry! Given word not found",
                        style: TextStyle(
                            fontWeight:FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 20.0,
                            color: Colors.redAccent
                        ),
                      ),
                    ),
                  );
                }
              },
        ),
      ),
    );
  }
}
