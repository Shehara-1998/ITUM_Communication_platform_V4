import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itum_communication_platform/pages/groups/groups_home_page.dart';
import 'package:itum_communication_platform/service/auth_service.dart';
import 'package:itum_communication_platform/widgets/widegets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../auth/Login_Page.dart';
import '../home/profile_page.dart';

class JobsHomePage extends StatefulWidget {
  const JobsHomePage({Key? key}) : super(key: key);

  @override
  _JobsHomePageState createState() => _JobsHomePageState();
}

class _JobsHomePageState extends State<JobsHomePage> {

  String userName = "";
  String email = "";
  AuthService authService = AuthService();

  ///

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController link = TextEditingController();
  TextEditingController duration = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  ///

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1EDF4),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
              onPressed: (){
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu, color: Color(0xff649EFF),)),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffE5F9FF),
        centerTitle: true,
        title: const Text("Create a Job",
          style: TextStyle(color: Colors.black, fontSize: 27, fontWeight: FontWeight.w600),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(Icons.account_circle, size: 150, color: Colors.grey[700],),
            const SizedBox(height: 15,),
            Text(userName, textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
            const SizedBox(height: 30,),
            const Divider(height: 2,),
            ListTile(
              onTap: (){
                nextScreen(context,  GroupHome());
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text('Groups', style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: (){
                nextScreenReplace(context,  ProfilePage(userName: userName,email: email,));
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.person),
              title: const Text('Profile', style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: (){},
              selectedColor: const Color(0xff649EFF),
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.work),
              title: const Text('Create Jobs', style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: ()async{
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        title: Text('LogOut'),
                        content: Text('Are you sure you want to LogOut?'),
                        actions: [
                          IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.cancel, color: Colors.red,)),
                          IconButton(
                              onPressed: ()async{
                                await authService.signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context)=>const LoginPage()),
                                        (route)=>false );
                              },
                              icon: Icon(Icons.done, color: Colors.green,))
                        ],
                      );
                    });

              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text('LogOut', style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                    children: [
                      Lottie.network('https://assets3.lottiefiles.com/packages/lf20_s5dhjbui.json',
                        width: 280,
                        height: 250,
                        fit: BoxFit.fill,),
                      formWidget(title, label: "Job title"),
                      const SizedBox(height: 15),
                      formWidget(description, label: "job description"),///
                      const SizedBox(height: 15),
                      formWidget(link, label: "Add a link"),
                      const SizedBox(height: 15),
                      formWidget(duration, label: "Added time",onTap: () {
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

                      Consumer<JobDbProvider>(builder: (context, db, child) {
                        WidgetsBinding.instance.addPostFrameCallback(
                              (_){
                            if(db.message !=""){
                              if(db.message.contains("Job Created")){
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
                              db.addJob(
                                  title: title.text.trim(),
                                  description:description.text.trim(),
                                  link:link.text.trim(),
                                  duration: duration.text.trim(),
                                  );
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
                            child: Text(db.status == true ? "please wait..":"post Job",
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

class JobDbProvider extends ChangeNotifier {
  String _message = "";

  bool _status = false;

  // bool _deleteStatus = false;

  String get message => _message;

  bool get status => _status;

  // bool get deleteStatus => _deleteStatus;

  User? user = FirebaseAuth.instance.currentUser;

  CollectionReference jobCollection =
  FirebaseFirestore.instance.collection("Jobs");
  void addJob(
      {required String title,
        required String description,
        required String link,
        required String duration,}) async {
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
        "Job": {
          "total_votes": 0,
          "title": title,
          "description":description,
          "link":link,
          "duration": duration,
        }
      };

      await jobCollection.add(data);
      _message = "Job Created";
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
  void clear() {
    _message = "";
    notifyListeners();
  }

}