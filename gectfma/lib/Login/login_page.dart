import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gectfma/Complaint_Summary/complaint_summary.dart';
import 'package:gectfma/Complaint_Summary/sergeant_complaint_summary.dart';
import 'package:gectfma/Login/forgot_pw.dart';
import 'package:gectfma/NatureOfIssue/comp_verification.dart';
import 'package:gectfma/Requirements/show_my_dialog.dart';
import 'package:gectfma/NatureOfIssue/nature.dart';
import 'package:gectfma/View_Complaints/Principal/principal_view_all_complaint.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save email to SharedPreferences
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('email', email);

      // Fetch user role and department from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
      final dept = userDoc['dept'] as String?;
      final role = userDoc['role'] as String?;
      
      print("email : $email");
      print("dept : $dept");
      print("role : $role");
      if (dept != null && dept != '') {
        if (dept == 'ee') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
            return NatureOfIssue(dept: dept);
          }));
        }
        else{
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
            return ComplaintSummary(deptName: dept);
          }));
        }
      } 
      else {
        if(role != null && role != '' ){
          if(role == 'sergeant'){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
              return SergeantComplaintSummary(role: role);
            }));
          }
          else if(role == 'principal'){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
              return const PrincipalViewAllComplaint();
            }));
          }
          else{
             Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
              return const complaintVerification(nature: "Plumbing");
            }));
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Error logging in user: $e');
      MyDialog.showCustomDialog(context, "Login Failed", "Incorrect email or password. Please try again.");
    } catch (e) {
      print('Error: $e');
      MyDialog.showCustomDialog(context, "Error", "An error occurred. Please try again later.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: WillPopScope(
        onWillPop: () async {
          // Show exit confirmation dialog
          bool exit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.amber[50],
              title: Text('Are you sure you want to exit?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Close the dialog and return false
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: Colors.brown[800]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Close the dialog and return true
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Colors.brown[800]),
                  ),
                ),
              ],
            ),
          );

          // Return exit if user confirmed, otherwise don't exit
          return exit;
        },
        child: ListView(
          children: [
            Column(
              children: <Widget>[
                SizedBox(height: 90),
                Text(
                  "Government Engineering College Thrissur".toUpperCase(),
                  style: TextStyle(color: Colors.brown[800], fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 20),
                Container(
                  height: 150,
                  width: 150,
                  child: Image.asset("assets/images/logo.png"),
                ),
                SizedBox(height: 20),
                Text(
                  "LOGIN",
                  style: TextStyle(color: Colors.brown[800], fontSize: 25),
                ),
                SizedBox(height: 20),
                _buildTextField("Enter Email", emailController),
                _buildTextField("Enter Password", passwordController, obscureText: true),
                SizedBox(height: 10),
                _buildLoginButton(context),
                SizedBox(height: 10),
                _buildForgotPasswordButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.brown.shade800,),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
    child: Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.brown[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () => _login(context),
        child: Text(
          "LOGIN",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ),);
   
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      child: Text(
        "Forgot Password?",
        style: TextStyle(decoration: TextDecoration.underline, color: Colors.brown[800]),
      ),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ForgotPasswordPage();
        }));
      },
    );
  }
}

















// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:gectfma/Complaint_Summary/sergeant_complaint_summary.dart';
// import 'package:gectfma/Login/forgot_pw.dart';
// import 'package:gectfma/NatureOfIssue/comp_verification.dart';
// import 'package:gectfma/NatureOfIssue/nature.dart';
// import 'package:gectfma/Requirements/show_my_dialog.dart';
// import 'package:gectfma/View_Complaints/Principal/principal_view_all_complaint.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Requirements/DetailFields.dart';
// import '../Complaint_Summary/complaint_summary.dart';

// class Login extends StatefulWidget {
//   Login({
//     Key? key,
//   }) : super(key: key);
//   //final String plumbingInCharge = "vmeera";
//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final emailController = TextEditingController();
//   final paswdController = TextEditingController();
//   String email = "";
//   String pswd = "";
//   String? dept;
//   String? role;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       child: WillPopScope(
//         onWillPop: () async {
//           // Show exit confirmation dialog
//           bool exit = await showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               backgroundColor: Colors.amber[50],
//               title: Text('Are you sure you want to exit?'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     // Close the dialog and return false
//                     Navigator.of(context).pop(false);
//                   },
//                   child: Text(
//                     'No',
//                     style: TextStyle(color: Colors.brown[800]),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     // Close the dialog and return true
//                     Navigator.of(context).pop(true);
//                   },
//                   child: Text(
//                     'Yes',
//                     style: TextStyle(color: Colors.brown[800]),
//                   ),
//                 ),
//               ],
//             ),
//           );

//           // Return exit if user confirmed, otherwise don't exit
//           return exit;
//         },
//         child: ListView(
//           children: [
//             Column(
//               children: <Widget>[
//                 SizedBox(
//                   height: 90,
//                 ),
//                 Text(
//                   "Government Engineering College Thrissur".toUpperCase(),
//                   style: TextStyle(
//                     color: Colors.brown[800],
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Container(
//                   height: 150,
//                   width: 150,
//                   child: Image.asset("assets/images/logo.png"),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Text(
//                   "LOGIN",
//                   style: TextStyle(
//                     color: Colors.brown[800],
//                     fontSize: 25,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 DetailFields(
//                   hintText: "Enter Email",
//                   controller: emailController,
//                 ),
//                 DetailFields(
//                   hintText: "Enter Password",
//                   controller: paswdController,
//                   obscure: true,
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(8.0),
//                   width: 370,
//                   decoration: BoxDecoration(
//                     color: Colors.brown[800],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: TextButton(
//                     onPressed: () async {
//                       setState(() {
//                         email = emailController.text;
//                         pswd = paswdController.text;
//                       });
//                       await login(email, pswd, context);
//                     },
//                     child: Text(
//                       "LOGIN",
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 TextButton(
//                   child: Text(
//                     "Forgot Password?",
//                     style: TextStyle(
//                       decoration: TextDecoration.underline,
//                       color: Colors.brown[800],
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) {
//                         return ForgotPasswordPage();
//                       },
//                     ));
//                   },
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> login(String email, String password, BuildContext context) async {
//     try {
//       final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       preferences.setString('email', email);

//       await getUsers(email);

//       print("email : $email");
//       print("dept : $dept");
//       print("role : $role");

//       // Login successful, navigate to home page
//       if (dept == "ee") {
//         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
//           return NatureOfIssue(
//             dept: dept!,
//           );
//         }));
//       } else if (role == 'p-in-charge') {
//         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
//           return complaintVerification(nature: "Plumbing");
//         }));
//       } else if (role == "sergeant") {
//         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
//           return SergeantComplaintSummary(
//             deptName: role!,
//           );
//         }));
//       } else if (role == "principal") {
//         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
//           return PrincipalViewAllComplaint();
//         }));
//       } else {
//         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
//           return ComplaintSummary(
//             deptName: dept!,
//           );
//         }));
//       }
//       /*Handle New User Landing Page */
//       // else{}
//     } on FirebaseAuthException catch (e) {
//       // Login failed, handle error
//       print('Error logging in user: $e');
//       MyDialog.showCustomDialog(context, "LOGIN FAILED", "Incorrect email or password. Please try again.");
//     } catch (e) {
//       // Other errors
//       print('Error: $e');
//     }
//   }

//   Future<void> getUsers(String docID) async {
//     try {
//       print(email);
//       // Get the reference to the Firestore collection
//       CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');

//       // Get the document snapshot for the user's email
//       DocumentSnapshot documentSnapshot = await collectionRef.doc(docID).get();

//       // Check if the document exists
//       if (documentSnapshot.exists) {
//         // Extract the 'dept' and 'role' fields from the document data
//         Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
//         setState(() {
//           dept = data['dept'];
//           role = data['role'];
//         });
//       } else {
//         // Handle case where document doesn't exist
//         print('Document with id $docID does not exist');
//       }
//     } catch (e) {
//       // Handle any errors
//       print('Error fetching user details: $e');
//     }
//   }
// }


















// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:gectfma/Complaint_Summary/sergeant_complaint_summary.dart';
// // import 'package:gectfma/Login/forgot_pw.dart';
// // import 'package:gectfma/NatureOfIssue/comp_verification.dart';
// // import 'package:gectfma/NatureOfIssue/nature.dart';
// // import 'package:gectfma/Requirements/show_my_dialog.dart';
// // import 'package:gectfma/View_Complaints/Principal/principal_view_all_complaint.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../Requirements/DetailFields.dart';
// // import '../Complaint_Summary/complaint_summary.dart';

// // class Login extends StatefulWidget {
// //   Login({
// //     Key? key,
// //   }) : super(key: key);
// //   final String plumbingInCharge = "vmeera";
// //   @override
// //   State<Login> createState() => _LoginState();
// // }

// // class _LoginState extends State<Login> {
// //   final emailController = TextEditingController();
// //   String dept = '';
// //   String role = '';
// //   List<String> deptCollection = [
// //     'cse',
// //     'che',
// //     'ece',
// //     'ee',
// //     'pe',
// //     'ce',
// //     'me',
// //     'arch'
// //   ];
// //   final paswdController = TextEditingController();
// //   String deptOrDesignation = "";
// //   String email = "";
// //   String pswd = "";

// //   @override
// //   Widget build(BuildContext context) {
// //     return Material(
// //         color: Colors.white,
// //         child: WillPopScope(
// //             onWillPop: () async {
// //               // Show exit confirmation dialog
// //               bool exit = await showDialog(
// //                 context: context,
// //                 builder: (context) => AlertDialog(
// //                   backgroundColor: Colors.amber[50],
// //                   title: Text('Are you sure you want to exit?'),
// //                   actions: <Widget>[
// //                     TextButton(
// //                       onPressed: () {
// //                         // Close the dialog and return false
// //                         Navigator.of(context).pop(false);
// //                       },
// //                       child: Text(
// //                         'No',
// //                         style: TextStyle(color: Colors.brown[800]),
// //                       ),
// //                     ),
// //                     TextButton(
// //                       onPressed: () {
// //                         // Close the dialog and return true
// //                         Navigator.of(context).pop(true);
// //                       },
// //                       child: Text(
// //                         'yes',
// //                         style: TextStyle(color: Colors.brown[800]),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );

// //               // Return exit if user confirmed, otherwise don't exit
// //               return exit ?? false;
// //             },
// //             child: ListView(
// //               children: [
// //                 Column(children: <Widget>[
// //                   SizedBox(
// //                     height: 90,
// //                   ),
// //                   Text(
// //                     "Government Engineering College Thrissur".toUpperCase(),
// //                     style: TextStyle(
// //                         color: Colors.brown[800],
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 16),
// //                   ),
// //                   SizedBox(
// //                     height: 20,
// //                   ),
// //                   Container(
// //                       height: 150,
// //                       width: 150,
// //                       child: Image.asset("assets/images/logo.png")),
// //                   SizedBox(
// //                     height: 20,
// //                   ),
// //                   Text("LOGIN",
// //                       style: TextStyle(
// //                         color: Colors.brown[800],
// //                         fontSize: 25,
// //                       )),
// //                   SizedBox(
// //                     height: 20,
// //                   ),
// //                   DetailFields(
// //                     hintText: "Enter Email",
// //                     controller: emailController,
// //                   ),
// //                   DetailFields(
// //                     hintText: "Enter Password",
// //                     controller: paswdController,
// //                     obscure: true,
// //                   ),
// //                   SizedBox(
// //                     height: 10,
// //                   ),
// //                   Container(
// //                       padding: const EdgeInsets.all(8.0),
// //                       width: 370,
// //                       decoration: BoxDecoration(
// //                           color: Colors.brown[800],
// //                           borderRadius: BorderRadius.circular(10)),
// //                       child: TextButton(
// //                         onPressed: () {
// //                           setState(() {
// //                             email = emailController.text;
// //                             pswd = paswdController.text;
// //                             if (email.isNotEmpty)
// //                               deptOrDesignation =
// //                                   email.split("@")[0].substring(3);
// //                             if (email.split("@")[0] == "sergeant") {
// //                               deptOrDesignation = "Sergeant";
// //                             } else if (email.split("@")[0] == "principal") {
// //                               deptOrDesignation = "Principal";
// //                             } else if (email.split("@")[0] ==
// //                                 widget.plumbingInCharge) {
// //                               deptOrDesignation = widget.plumbingInCharge;
// //                             }
// //                           });
// //                           login(email, pswd, deptOrDesignation, context);
// //                         },
// //                         child: Text(
// //                           "LOGIN",
// //                           style: TextStyle(color: Colors.white, fontSize: 18),
// //                         ),
// //                       )),
// //                   SizedBox(
// //                     height: 10,
// //                   ),
// //                   TextButton(
// //                     child: Text("Forgot Password?",
// //                         style: TextStyle(
// //                           decoration: TextDecoration.underline,
// //                           color: Colors.brown[800],
// //                         )),
// //                     onPressed: () {
// //                       Navigator.of(context)
// //                           .push(MaterialPageRoute(builder: (context) {
// //                         return ForgotPasswordPage();
// //                       }));
// //                     },
// //                   )
// //                 ]),
// //               ],
// //             )));
// //   }

// //   void login(String email, String password, String deptOrDesignation,
// //       BuildContext context) async {
// //     try {
// //       await FirebaseAuth.instance.signInWithEmailAndPassword(
// //         email: email,
// //         password: password,
// //       );
// //       SharedPreferences preferences = await SharedPreferences.getInstance();
// //       preferences.setString('email', email);
// //       // Login successful, navigate to home page
// //       if (deptOrDesignation == "ee") {
// //         Navigator.of(context)
// //             .pushReplacement(MaterialPageRoute(builder: (context) {
// //           return NatureOfIssue(
// //             dept: deptOrDesignation,
// //           );
// //         }));
// //       } else if (email == 'vmeera@gectcr.ac.in') {
// //         Navigator.of(context)
// //             .pushReplacement(MaterialPageRoute(builder: (context) {
// //           return complaintVerification(nature: "Plumbing");
// //         }));
// //       } else if (deptOrDesignation == "Sergeant") {
// //         Navigator.of(context)
// //             .pushReplacement(MaterialPageRoute(builder: (context) {
// //           return SergeantComplaintSummary(
// //             deptName: deptOrDesignation,
// //           );
// //         }));
// //       } else if (deptOrDesignation == "Principal") {
// //         Navigator.of(context)
// //             .pushReplacement(MaterialPageRoute(builder: (context) {
// //           return PrincipalViewAllComplaint();
// //         }));
// //       } else if (deptCollection.contains(deptOrDesignation)) {
// //         Navigator.of(context)
// //             .pushReplacement(MaterialPageRoute(builder: (context) {
// //           return ComplaintSummary(
// //             deptName: deptOrDesignation,
// //           );
// //         }));
// //       }
// //       /*Handle New User Landing Page */
// //       // else{}
// //     } on FirebaseAuthException catch (e) {
// //       // Login failed, handle error
// //       // print('Error logging in user: $e');
// //       MyDialog.showCustomDialog(context, "LOGIN FAILED",
// //           "Incorrect email or password. Please try again.");
// //     }
// //   }
// // }
