import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gectfma/NatureOfIssue/comp_verification.dart';
import 'package:gectfma/NatureOfIssue/list_complints.dart';
import 'package:gectfma/Requirements/Headings.dart';
import 'package:gectfma/Requirements/show_my_dialog.dart';
import '../Requirements/DetailFields.dart';
import '../Requirements/TopBar.dart';

class approveOrDecline extends StatefulWidget {
  final String dept;
  final String id;
  //final int number;
  const approveOrDecline({super.key, required this.dept, this.id = ""});

  @override
  State<approveOrDecline> createState() => _approveOrDeclineState();
}

List<String> levels = ["High", "Medium", "Low"];
String urgency = levels[0];
String? nature;
TextEditingController contactController = TextEditingController();
TextEditingController descController = TextEditingController();
TextEditingController hodController = TextEditingController();
TextEditingController titleController = TextEditingController();
TextEditingController natureController = TextEditingController();
TextEditingController statusController = TextEditingController();
TextEditingController urgencyController = TextEditingController();
TextEditingController remarkController = TextEditingController();
String imageURL = '';

class _approveOrDeclineState extends State<approveOrDecline> {
  String remark = '';
  @override
  void initState() {
    // TODO: implement initState
    if (widget.id != "") {
      viewComplaint(widget.id, widget.dept);
    }
    remarkController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> evictImage(String imageURL) async {
      final NetworkImage provider = NetworkImage(imageURL);
      return await provider.evict();
    }

    return SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          TopBar(
            dept: "DEPARTMENT OF " + widget.dept,
            iconLabel: 'Go Back',
            title: "${widget.id}".toUpperCase(),
            icon: Icons.arrow_back,
            goto: () {
              Navigator.of(context).pop();
            },
          ),
          Headings(title: "Department Details"),
          DetailFields(
            isEnable: false,
            hintText: widget.dept.toUpperCase(),
          ),
          DetailFields(
            isEnable: false,
            hintText: "Name of HOD",
            controller: hodController,
          ),
          DetailFields(
            isEnable: false,
            hintText: "Contact No",
            controller: contactController,
          ),
          Headings(title: "Complaint Details"),
          DetailFields(
              isEnable: false,
              controller: natureController,
              hintText: "Nature"),
          DetailFields(
              isEnable: false,
              controller: statusController,
              hintText: "Status"),
          DetailFields(
            isEnable: false,
            controller: titleController,
            hintText: "Title",
          ),
          DetailFields(
            isEnable: false,
            controller: descController,
            hintText: "Description",
          ),
          Headings(title: "Images"),
          //Image To be added
          Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
            child: Image.network(
              imageURL,
              key: ValueKey(widget.id),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Text('Error loading image');
              },
            ),
          ),
          Headings(title: "Urgency level"),
          DetailFields(
            isEnable: false,
            controller: urgencyController,
            hintText: "Level",
          ),
          SizedBox(
            height: 20,
          ),
          Headings(title: "Remarks*"),
          DetailFields(
            hintText: "Remarks",
            controller: remarkController,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    remark = remarkController.text;
                  });
                  addRemark(widget.dept, widget.id, remark, "approved");
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.green,
                  backgroundColor: Colors.green[100], // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Corner radius
                  ),
                  minimumSize: Size(150, 50), // Width and height
                ),
                child: Text('APPROVE'),
              ),
              ElevatedButton(
                onPressed: () {
                  addRemark(widget.dept, widget.id, remarkController.text,
                      "declined");
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.red[100], // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Corner radius
                  ),
                  minimumSize: Size(150, 50), // Width and height
                ),
                child: Text('DECLINE'),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    )));
  }

  void addRemark(String dept, String id, String remark, String status) async {
    try {
      if (remark == '') {
        MyDialog.showCustomDialog(
          context,
          "ERROR!!",
          "Remark should be given",
        );
      } else {
        // Get a reference to the specific document with the custom ID
        DocumentReference docRef =
            FirebaseFirestore.instance.collection(dept).doc(id);

        // Set the data in the document with the custom ID
        await docRef.update({'verification_remark': remark, 'status': status});
        // Navigator.of(context)
        //     .pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
        //       return complaintVerification(nature: natureController.text);
        //     }),(Route<dynamic> route) => false,);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return listComplaints(status: status, nature: natureController.text);
        }), (route) => route is complaintVerification);
        MyDialog.showCustomDialog(
            context, "STATUS UPDATED", "Remarks added and Status is updated");
      }
    } catch (e) {
      print("Error adding document: $e");
      MyDialog.showCustomDialog(
        context,
        "ERROR!!",
        "Some error occured. Please try again",
      ); // Handle errors here
    }
  }
}

Future<Map<String, dynamic>> viewComplaint(String id, String dept) async {
  try {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(dept);

    DocumentSnapshot documentSnapshot = await collectionRef.doc(id).get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data = {
        'contact': documentSnapshot['contact'],
        'desc': documentSnapshot['desc'],
        'hod': documentSnapshot['hod'],
        'image': documentSnapshot['image'],
        'nature': documentSnapshot['nature'],
        'status': documentSnapshot['status'],
        'title': documentSnapshot['title'],
        'urgency': documentSnapshot['urgency'],
      };

      contactController.text = data['contact'];
      descController.text = data['desc'];
      hodController.text = data['hod'];
      natureController.text = data['nature'];
      statusController.text = data['status'];
      titleController.text = data['title'];
      urgencyController.text = data['urgency'];
      imageURL = data['image'];
      print(imageURL);
      return data;
    } else {
      print('Document not found');
      return {};
    }
  } catch (e) {
    // Handle errors
    print("Error getting data: $e");
    return {};
  }
}