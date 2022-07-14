import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:proje/ogr.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:camera/camera.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Iskele(),
    );
  }
}

class Iskele extends StatelessWidget {
  const Iskele({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text("Giriş "),
      ),
      body: AnaEkran(),
      backgroundColor: Color.fromARGB(255, 252, 252, 252), //body
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({Key? key}) : super(key: key);

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  final picker = ImagePicker();
  late File image;
  late Image resim;
  late InputImage resim2;
  TextEditingController t1 = new TextEditingController();
  dynamic gelenVeri = "";

  late dynamic bugun;

  late String currentURL = "";
  //late UploadTask uploadTask;

  Future<void> firestoreKayit() async {
    final docSave =
        FirebaseFirestore.instance.collection('facelist').doc('$bugun');

    final json = {
      'cekilenZaman': bugun,
      'urlData': currentURL,
      'id': docSave.id
    };
    await docSave.set(json);
  }

  Future<void> firestoreKayit2() async {
    int i = 1;
    for (i; i < 100; i++) {
      await FirebaseFirestore.instance
          .collection('facelist')
          .doc(i.toString())
          .get()
          .then((value) {
        setState(() {
          gelenVeri = value.data()?['id'];
        });
      });

      if (gelenVeri == i.toString()) {
        print("i ARTTI");
      } else {
        final docSave =
            FirebaseFirestore.instance.collection('facelist').doc('$i');
        final json = {
          'cekilenZaman': bugun,
          'urlData': currentURL,
          'id': i.toString()
        };
        await docSave.set(json);
        print('TAMAMLANDI');
        break;
      }
    }
    // final docSave =
    //   FirebaseFirestore.instance.collection('facelist').doc('$bugun');
  }

  bugunFonksiyonu() async {
    final xxx = DateTime.now();

    late final year = xxx.year;
    late final month = xxx.month;
    late final day = xxx.day;
    late final hour = xxx.hour + 3;
    late final minute = xxx.minute;
    late final milisec = xxx.millisecond;
    late String xbugun = "$day-$month-$year-$hour-$minute-$milisec";

    setState(() {
      bugun = xbugun;
    });
  }

  downloadURL() async {
    Reference ref =
        FirebaseStorage.instance.ref().child('test/').child('$bugun.jpg');
    String downloadURL = await ref.getDownloadURL();
    setState(() {
      currentURL = downloadURL;
    });
  }

  Future fotocek() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      image = File(pickedFile!.path);
      resim2 = InputImage.fromFile(image);
    });
    FaceDetectorOptions options = FaceDetectorOptions();
    FaceDetector detect = FaceDetector(options: options);

    final faces = await detect.processImage(resim2);

    if (faces.isNotEmpty) {
      await bugunFonksiyonu();
      Reference ref =
          FirebaseStorage.instance.ref().child('test/').child('$bugun.jpg');
      UploadTask yuklemeGorevi = ref.putFile(image);
      await yuklemeGorevi;
      /* String currentUser = await ref.getDownloadURL();
      setState(() {
        currentURL = currentUser;
      });*/

      await downloadURL();
      firestoreKayit2();

      t1.text = "Giriş Yapıldı Geçebilirsiniz!";
      // String url = await ref.getDownloadURL() as String;
      // print("URL BURDAA:" + url);
    } else {
      t1.text = "Tekrar Deneyiniz Giriş Başarısız!";
    }
  }

  Future fotoSec() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedFile!.path);
      resim2 = InputImage.fromFile(image);
    });
    FaceDetectorOptions options = FaceDetectorOptions();
    FaceDetector detect = FaceDetector(options: options);

    final faces = await detect.processImage(resim2);

    if (faces.isNotEmpty) {
      await bugunFonksiyonu();
      Reference ref =
          FirebaseStorage.instance.ref().child('test/').child('$bugun.jpg');
      UploadTask yuklemeGorevi = ref.putFile(image);
      await yuklemeGorevi;
      /* String currentUser = await ref.getDownloadURL();
      setState(() {
        currentURL = currentUser;
      });*/

      await downloadURL();
      firestoreKayit2();

      t1.text = "Veritabanına Aktarıldı ve Yüz Tespit Edildi!";
      // String url = await ref.getDownloadURL() as String;
      // print("URL BURDAA:" + url);
    } else {
      t1.text = "Yoklama Başarısız!";
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(""),
          /*  Center(
            child: ElevatedButton(
                onPressed: fotoSec, child: const Text("Galeriden Seç")),
          ),*/
          Center(
            child: RaisedButton(
              onPressed: fotocek,
              color: Colors.black,
              textColor: Colors.white,
              child: const Text("Giriş Yap"),
            ),
          ),
          /* Center(
            child: ElevatedButton(
                onPressed: null, child: const Text("Liste cevir")),
          ),*/
          Center(
            child: TextField(
              cursorColor: Colors.black,
              textAlign: TextAlign.center,
              showCursor: false,
              enableSuggestions: false,
              readOnly: true,
              decoration: InputDecoration(border: InputBorder.none),
              controller: t1,
            ),
          ),
          Center(
            child: RaisedButton(
              child: Text("Giriş Kayıtlarına Ulaşın"),
              color: Colors.black,
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OgretmenEkrani()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
