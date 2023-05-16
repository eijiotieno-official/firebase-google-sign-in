
import 'package:ano/pages/home_page.dart';
import 'package:ano/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  Future authenticateUser({required BuildContext context}) async {
    await signInWithGoogle().then(
      (userCredential) async {
        await userExists(id: userCredential.user!.uid).then(
          (exists) async {
            if (exists) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const HomePage();
                  },
                ),
              );
            } else {
              await createUser(userCredential: userCredential).then(
                (created) {
                  if (created) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const HomePage();
                        },
                      ),
                    );
                  }
                },
              );
            }
          },
        );
      },
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<bool> createUser({required UserCredential userCredential}) async {
    bool created = false;
    await usersCollection.doc(userCredential.user!.uid).set(
      {
        'id': userCredential.user!.uid,
        'name': userCredential.user!.displayName,
        'email': userCredential.user!.email,
        'photo': userCredential.user!.photoURL,
      },
    ).then((value) => created = true);
    return created;
  }

  Future<bool> userExists({required String id}) async {
    bool exists = false;
    await usersCollection.where('id', isEqualTo: id).get().then(
      (user) {
        if (user.docs.isEmpty) {
          exists = false;
        } else if (user.docs.isNotEmpty) {
          exists = true;
        }
      },
    );
    return exists;
  }
}
