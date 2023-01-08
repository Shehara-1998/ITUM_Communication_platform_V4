import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

///poll creating page

class PollsHome extends StatefulWidget {
  const PollsHome({Key? key}) : super(key: key);

  @override
  _PollsHomeState createState() => _PollsHomeState();
}

class _PollsHomeState extends State<PollsHome> {
  TextEditingController question = TextEditingController();
  TextEditingController option1 = TextEditingController();
  TextEditingController option2 = TextEditingController();
  TextEditingController duration = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1EDF4),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            ),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Color(0xFFA88BEB), Color(0xFFD5ADC8)]),
          ),
        ),
        title: const Text("Add a Poll",
          style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w600),),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                    children: [
                      Lottie.network('https://assets3.lottiefiles.com/packages/lf20_EyJRUV.json',
                        width: 280,
                        height: 250,
                        fit: BoxFit.fill,),
                      formWidget(question, label: "Question"),
                      const SizedBox(height: 15),
                      formWidget(option1, label: "Option 1"),
                      const SizedBox(height: 15),
                      formWidget(option2, label: "Option 2"),
                      const SizedBox(height: 15),
                      formWidget(duration, label: "Duration",onTap: () {
                        showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.utc(2027))
                            .then((value) {
                          if (value == null) {
                            duration.clear();
                          } else {
                            duration.text = value.toString();
                          }
                        });
                      }),
                      const SizedBox(height: 35),

                      Consumer<DbProvider>(builder: (context, db, child) {
                        WidgetsBinding.instance.addPostFrameCallback(
                              (_){
                            if(db.message !=""){
                              if(db.message.contains("Poll Created")){
                                success(context, message: db.message);
                                db.clear();
                              }else{
                                error(context, message: db.message);
                                db.clear();
                              }
                            }
                          },
                        );
                        return GestureDetector(
                          onTap:  db.status == true
                              ? null
                              :(){
                            if(_formKey.currentState!.validate()){
                              List<Map> options =[{
                                "answer": option1.text.trim(),
                                "percent": 0,
                              },{
                                "answer": option2.text.trim(),
                                "percent": 0},
                              ];
                              db.addPoll(
                                  question: question.text.trim(),
                                  duration: duration.text.trim(),
                                  options: options);
                            }
                          },
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width-190,
                            decoration: BoxDecoration(
                                color: db.status == true
                                    ? Colors.grey
                                    : Color(0xFFA88BEB),
                                borderRadius: BorderRadius.circular(25)),
                            alignment: Alignment.center,
                            child: Text(db.status == true ? "please wait..":"post poll",
                              style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w600),),
                          ),
                        );
                      }
                      ),
                    ]
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///error or success message
void error(BuildContext? context, {required String message}) {
  ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Colors.red,
  ));
}

void success(BuildContext? context, {required String message}) {
  ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Colors.blue,
  ));
}

///form widget
Widget formWidget (TextEditingController controller,
    {String? label, VoidCallback? onTap}){
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      onTap: onTap,
      readOnly: onTap == null ? false : true,
      controller: controller,
      validator: (value){
        if (value!.isEmpty) {
          return "input is required";
        }
        return null;
      },
      decoration: InputDecoration(
          errorBorder:const OutlineInputBorder(),
          labelText:label!,
          border:const OutlineInputBorder()
      ),
    ),
  );
}

///Db provider class

class DbProvider extends ChangeNotifier {
  String _message = "";

  bool _status = false;

  // bool _deleteStatus = false;

  String get message => _message;

  bool get status => _status;

  // bool get deleteStatus => _deleteStatus;

  User? user = FirebaseAuth.instance.currentUser;

  CollectionReference pollCollection =
  FirebaseFirestore.instance.collection("polls");

  void addPoll({required String question,
    required String duration,
    required List<Map> options}) async {
    _status = true;
    notifyListeners();
    try {
      ///
      final data = {
        "author": {
          "name": user!.email,
          "uid": user!.uid,
        },
        "dateCreated": DateTime.now(),
        "poll": {
          "total_votes": 0,
          "voters": <Map>[],
          "question": question,
          "duration": duration,
          "options": options,
        }
      };

      await pollCollection.add(data);
      _message = "Poll Created";
      _status = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _message = e.message!;
      _status = false;
      notifyListeners();
    } catch (e) {
      _message = "Please try again....";
      _status = false;
      notifyListeners();
    }
  }

  void votePoll({
    required String? pollId,
    required DocumentSnapshot pollData,
    required int previousTotalVotes,
    required String seletedOptions
  }) async {
    _status = true;
    notifyListeners();

    try {
      List voters = pollData['poll']["voters"];

      voters.add({
        "name": user!.email,///=======changed
        "uid": user!.uid,
        "selected_option": seletedOptions,
      });



      ///create option and add items
      ///options
      ///options
      List options = pollData["poll"]["options"];
      for (var i in options) {
        if (i["answer"] == seletedOptions) {
          i["percent"]++;
        } else {
          if (i["percent"] > 0) {
            i["percent"]--;
          }
        }
      }

      ///update poll

      final data = {
        "author": {
          "uid": pollData["author"]["uid"],
          // "profileImage": pollData["author"]["profileImage"],
          "name": pollData["author"]["name"],
        },
        "dateCreated": pollData["dateCreated"],
        "poll": {
          "total_votes": previousTotalVotes + 1,
          "voters": voters,
          "question": pollData["poll"]["question"],
          "duration": pollData["poll"]["duration"],
          "options": options,
        }
      };

      await pollCollection.doc(pollId).update(data);
      _message = "Vote Recorded";
      _status = false;
      notifyListeners();


    } on FirebaseException catch (e) {
      _message = e.message!;
      _status = false;
      notifyListeners();
    } catch (e) {
      _message = "Please try again...";
      _status = false;
      notifyListeners();
    }
  }

  void clear() {
    _message = "";
    notifyListeners();
  }

}