import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';

class OgretmenEkrani extends StatefulWidget {
  const OgretmenEkrani({Key? key}) : super(key: key);

  @override
  State<OgretmenEkrani> createState() => _OgretmenEkraniState();
}

class _OgretmenEkraniState extends State<OgretmenEkrani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Giriş Kayıtları"),
      ),
      body: yoklamaSayfasi(),
    );
  }
}

class yoklamaSayfasi extends StatefulWidget {
  const yoklamaSayfasi({Key? key}) : super(key: key);

  @override
  State<yoklamaSayfasi> createState() => _yoklamaSayfasiState();
}

class _yoklamaSayfasiState extends State<yoklamaSayfasi> {
  String gelenURLDATA = "";
  String gelenID = "";
  List<String> urlListesi = [];
  List<String> idListesi = [];
  kayitAl() async {
    int i = 0;
    for (i; i < 15; i++) {
      await FirebaseFirestore.instance
          .collection("facelist")
          .doc('$i')
          .get()
          .then((value) {
        setState(() {
          gelenURLDATA = value.data()?['urlData'];
          urlListesi.add(gelenURLDATA);
        });
      });
      print(urlListesi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("facelist").snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot docSnapshot = snapshot.data!.docs[index];

              return Center(
                child: Card(
                  margin: EdgeInsets.only(left: 90, top: 15),
                  color: Colors.black,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(docSnapshot["urlData"]),
                        radius: 45,
                      ),
                      Column(
                        children: [
                          Text(
                            " Giriş Zamanı",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          Text(
                            docSnapshot["cekilenZaman"],
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
