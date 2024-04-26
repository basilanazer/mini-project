import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gectfma/Requirements/Headings.dart';
import 'package:gectfma/Requirements/TopBar.dart';

class complaintVerification extends StatefulWidget{
  final String nature;
  const complaintVerification({Key? key, required this.nature}) : super(key: key);
  @override
  State<complaintVerification> createState() => _complaintVerificationState();
}

class _complaintVerificationState extends State<complaintVerification>{
 
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: getCounts(widget.nature),
          builder: (context, AsyncSnapshot<Map<String, int>> snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
            } 
            else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
            } 
            else {
                int? total = snapshot.data?['total'];
                int? approved = snapshot.data?['approved'];
                int? declined = snapshot.data?['declined'];
                int? pending = snapshot.data?['pending'];

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: <Widget>[
                      TopBar(
                        iconLabel: widget.nature =='Electrical'? "Go Back":"Log Out",
                        title: "Total ${widget.nature} complaints $total",
                        icon: widget.nature =='Electrical'? Icons.arrow_back:Icons.logout,
                        dept: "${widget.nature} complaints",
                      ),
                      ComplaintsType(
                              goto: () {},
                              complainttype: "Approved",
                              complaintstatus: approved
                      ),
                      ComplaintsType(
                              goto: () {},
                              complainttype: "Declined",
                              complaintstatus: declined
                      ),
                      Divider(thickness: 1,color: Colors.black,),
                      Headings(title: "Complaints to Verify")
                    ]
                  )
                );
            }
          },
      ),
      ),
    );
  }
  Future<Map<String, int>> getCounts(String nature) async {
    try {
      int pendingCount = 0;
      int approvedCount = 0;
      int declinedCount = 0;
      int completedCount = 0;
      List<String> deptCollection = ['cse','che','ece','ee','pe','ce','me','arch'];
      // Get a reference to the collection
      for(int i = 0; i < 8; i++){
        String dept = deptCollection[i];
        CollectionReference collectionRef =
          FirebaseFirestore.instance.collection(dept);

        // Query the collection for documents with status 'pending'
        QuerySnapshot pendingSnapshot =
            await collectionRef.where('status', isEqualTo: 'pending').where('nature', isEqualTo: nature).get();
        pendingCount += pendingSnapshot.size;
        QuerySnapshot completedSnapshot =
            await collectionRef.where('status', isEqualTo:'completed').where('nature', isEqualTo: nature).get();
        completedCount += completedSnapshot.size;

        // Query the collection for documents with status 'accepted'
        QuerySnapshot acceptedSnapshot =
            await collectionRef.where('status', isEqualTo: 'approved').where('nature', isEqualTo: nature).get();
        approvedCount += acceptedSnapshot.size;

        // Query the collection for documents with status 'declined'
        QuerySnapshot declinedSnapshot =
            await collectionRef.where('status', isEqualTo: 'declined').where('nature', isEqualTo: nature).get();
        declinedCount += declinedSnapshot.size;        
      }
      int totalCount = pendingCount + approvedCount + declinedCount + completedCount;
      return {
        'pending': pendingCount,
        'approved': approvedCount,
        'declined': declinedCount,
        'completed': completedCount,
        'total': totalCount
      };
    } catch (e) {
      // Handle errors
      print("Error getting counts: $e");
      return {'pending': 0, 'accepted': 0, 'declined': 0, 'total': 0};
    }
  }
}
class ComplaintsType extends StatelessWidget {
  final String complainttype;
  final Function goto;
  final int? complaintstatus;
  const ComplaintsType({
    super.key,
    required this.complainttype,
    required this.complaintstatus,
    required this.goto,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: goto(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.brown[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$complainttype complaints".toUpperCase(),
                style: TextStyle(fontSize: 17, color: Colors.brown[600]),
              ),
              Text(
                "$complaintstatus",
                style: TextStyle(fontSize: 17, color: Colors.brown[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}