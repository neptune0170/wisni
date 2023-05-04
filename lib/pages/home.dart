import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:wsini/pages/qr_scan_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  // LEARN: What is collection Reference?  final CollectionReference _refUsers = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
  // Difference between Stream Builder and Future Builder
  DocumentReference documentReference = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: Icon(Icons.leave_bags_at_home))
          ],
        ),
        body: Center(
          child: Column(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: documentReference.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (!snapshot.hasData || snapshot.data!.data() == null) {
                    return Text('No data found');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading');
                  }
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  String name = data['name'];
                  String userId = data['user_id'];

                  return Column(
                    children: [
                      Text('Name: $name'),
                      Text('User: $userId'),
                      Container(
                        alignment: Alignment.center,
                        child: Text("Collection: " +
                            FirebaseAuth.instance.currentUser!.uid),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QrCodeScanner()),
                            );
                          },
                          child: Text('HelloWorld'))
                    ],
                  );
                },
              ),
            ],
          ),
        ));
  }
}
