import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference? getUserReference() {
    User? user = _auth.currentUser;
    if(user != null){
      return _firestore.collection('users').doc(user.uid);
    }else{
      return null;
    }
  }
}
