//details.dart
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final dynamic data;
  const Details({super.key, this.data});
  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    // استلام البيانات المرسلة عبر المسارات
    // final data = ModalRoute.of(context)!.settings.arguments as Map;
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
    return Scaffold(
      key: scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap:(val){
          setState(() {
            currentIndex = val;
          });
        },
        // fixedColor:Colors.blue,
        backgroundColor: const Color.fromARGB(255, 252, 249, 249),
        iconSize: 30.0,
        selectedItemColor: const Color.fromARGB(255, 140, 64, 255),
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: TextStyle(
          fontSize: 18,
          color: const Color.fromARGB(255, 140, 64, 255),
        ),
        unselectedLabelStyle: TextStyle(fontSize: 18, color: Colors.grey[500]),

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "ـــ"),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: "ـــ"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "ـــ"),
        ],
      ),
      endDrawer: Drawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle_outlined, size: 30, color: Colors.black),
            SizedBox(width: 6),
            Text(
              "Product",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              " Details",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.grey),
        backgroundColor: Colors.grey[200],
        elevation: 0.0,
      ),
      // Image.asset("${data['photoname']}"),
      // Text(
      //   "${data['title']}",
      //   style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      //   textAlign: TextAlign.center,
      // ),
      // Text("${data['subtitle']}", textAlign: TextAlign.center),
      // Text(
      //   "${data['price']}",
      //   textAlign: TextAlign.center,
      //   style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      // ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Image.asset(widget.data['photoname']),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                widget.data['title'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                widget.data['subtitle'],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                widget.data['price'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(//color
              margin: EdgeInsets.only(top: 20),
              width: 300,
              decoration: BoxDecoration(
                // color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              height: 40,
              // width: 1000,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // shrinkWrap: true,
                // scrollDirection: Axis.horizontal,
                children: [
                  Text(
                    "Color:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Container(
                    // height: 100,
                    // width: 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.data['colors'].length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 40,
                          // height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          margin: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.circle,
                            color: widget.data['colors'][index],
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(//size
              margin: EdgeInsets.only(top: 20),
              width: 300,
              decoration: BoxDecoration(
                // color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              height: 40,
              // width: 1000,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // shrinkWrap: true,
                // scrollDirection: Axis.horizontal,
                children: [
                  Text(
                    "Size:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Container(
                    // height: 100,
                    // width: 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.data['colors'].length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 40,
                          // height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.all(7),
                          child: Text(
                            widget.data['sizes'][index],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),//size
            Container(
              margin:EdgeInsets.only(top:20),
              padding:EdgeInsets.symmetric(horizontal:100,vertical:0),
              height:50,
              child: MaterialButton(
                // minWidth:200,
                color:Colors.black,
                textColor:Colors.white,
                onPressed:(){
              
                },
                child:Text("Add To Cart",style:TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
