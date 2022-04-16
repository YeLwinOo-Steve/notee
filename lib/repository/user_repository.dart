import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:note_taker/models/models.dart';

class UserRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection("users");

  Future<bool> addUser(User user) async {
    QuerySnapshot querySnapshot =
        await collection.where("email", isEqualTo: user.email).get();
    List<QueryDocumentSnapshot> existingUser = querySnapshot.docs;
    if (existingUser.isNotEmpty) {
      return false;
    } else {
      collection.doc(user.id).set(user.toJson()).then((value) {
        return true;
      });
    }
    return true;
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getUser(
      String email, String password) async {
    QuerySnapshot querySnapshot = await collection
        .where("email", isEqualTo: email)
        .where("password", isEqualTo: password)
        .get();
    return querySnapshot.docs;
  }

  void updateUserId(String oldId, String newId) async {
    final CollectionReference collection =
        FirebaseFirestore.instance.collection("users");

    collection.doc(oldId).get().then((doc) {
      if (doc.exists) {
        var data = doc.data();
        collection.doc(newId).set(data).then((value) {
          collection.doc(oldId).delete();
        });
      }
    });
  }

  void updateUserName(String userId, String name) async {
    await collection.doc(userId).update({"name": name});
  }

  void updateEmail(String userId, String email) async {
    await collection.doc(userId).update({"email": email});
  }

  void updatePassword(String userId, String newPwd) async {
    await collection.doc(userId).update({"password": newPwd});
  }

  void deleteUser(String userId) async {
    await collection.doc(userId).delete();
  }
}
