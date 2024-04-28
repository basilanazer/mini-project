import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gectfma/Requirements/Headings.dart';
import '../Requirements/DetailFields.dart';
import '../Requirements/TopBar.dart';

class ViewComplaint extends StatefulWidget {
  final String dept;
  final String id;
  final String designation;
  const ViewComplaint(
      {super.key, required this.dept, this.id = "", this.designation = ""});

  @override
  State<ViewComplaint> createState() => _ViewComplaintState();
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
TextEditingController staffNameController = TextEditingController();
TextEditingController staffNumberController = TextEditingController();
String status = "";

class _ViewComplaintState extends State<ViewComplaint> {
  @override
  void initState() {
    // TODO: implement initState
    if (widget.id != "") {
      viewComplaint(widget.id, widget.dept);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          Headings(title: "Department Details*"),
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
          Headings(title: "Complaint Details*"),
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
          Headings(title: "Additional documents*"),
          //Image To be added
          DetailFields(isEnable: false, hintText: "Image"),
          SizedBox(
            height: 20,
          ),
          Headings(title: "Urgency level*"),
          DetailFields(
            isEnable: false,
            controller: urgencyController,
            hintText: "Level",
          ),
          SizedBox(
            height: 20,
          ),
          Headings(title: "Assigned Staff Details"),
          DetailFields(
            isEnable: false,
            hintText: "Assigned Staff Name",
            controller: staffNameController,
          ),
          DetailFields(
            isEnable: false,
            hintText: "Assigned Staff Number",
            controller: staffNumberController,
          ),
          /*
          Handles the case of sergeant assigned complaints to be marked as completed
           */
          if (widget.designation != "")
            ElevatedButton(
              onPressed: () {
                setState(() {
                  status = "completed";
                });
                updateStatus(widget.id, widget.dept);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.brown[50],
                backgroundColor: Colors.brown[800], // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Corner radius
                ),
                minimumSize: Size(150, 50), // Width and height
              ),
              child: Text('MARK AS COMPLETED'),
            ),
        ],
      ),
    )));
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
        //image
        'nature': documentSnapshot['nature'],
        'status': documentSnapshot['status'],
        'title': documentSnapshot['title'],
        'urgency': documentSnapshot['urgency'],
        'assigned_staff': documentSnapshot['assigned_staff'],
        'assigned_staff_no': documentSnapshot['assigned_staff_no'],
      };
      contactController.text = data['contact'];
      descController.text = data['desc'];
      hodController.text = data['hod'];
      natureController.text = data['nature'];
      statusController.text = data['status'];
      titleController.text = data['title'];
      urgencyController.text = data['urgency'];
      staffNameController.text = data['assigned_staff'];
      staffNumberController.text = data['assigned_staff_no'];

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

Future<void> updateStatus(String id, String dept) async {
  try {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(dept);

    // Update the document
    await collectionRef.doc(id).update({
      'status': status,
    });
  } catch (e) {
    // Handle errors
    print("Error updating data: $e");
  }
}
