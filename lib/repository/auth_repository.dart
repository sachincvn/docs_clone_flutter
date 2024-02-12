import 'dart:convert';

import 'package:docs_clone_flutter/common/constants.dart';
import 'package:docs_clone_flutter/models/response_model.dart';
import 'package:docs_clone_flutter/models/user_model.dart';
import 'package:docs_clone_flutter/repository/local_storage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
      googleSignIn: GoogleSignIn(),
      client: Client(),
      localStorageRepository: LocalStorageRepository(),
    ));

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required Client client,
      required LocalStorageRepository localStorageRepository})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ResponseModel> signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = UserModel(
          name: user.displayName!,
          email: user.email,
          profilePic: user.photoUrl!,
          uid: '',
          token: '',
        );
        var response = await _client.post(Uri.parse(Constants.signUpApi),
            body: userAcc.toJson(),
            headers: {'Content-Type': 'application/json; charset=UTF-8'});
        switch (response.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(response.body)["user"]["_id"],
              token: jsonDecode(response.body)["token"],
            );
            _localStorageRepository.setToken(newUser.token);
            return ResponseModel(data: newUser, error: null);
          case 500:
            return ResponseModel(data: null, error: "Server eroor");
        }
      }
    } catch (e) {
      return ResponseModel(data: null, error: e.toString());
    }
    return ResponseModel(data: null, error: "Something went wrong!");
  }

  Future<ResponseModel> getUserData() async {
    try {
      final token = await _localStorageRepository.getToken();
      if (token != null) {
        var response = await _client.get(Uri.parse(Constants.getUserApi),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': token
            });

        switch (response.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
                    jsonEncode(jsonDecode(response.body)['user']))
                .copyWith(token: token);
            _localStorageRepository.setToken(token);
            return ResponseModel(data: newUser, error: null);
          case 500:
            return ResponseModel(data: null, error: "Server eroor");
        }
      }
    } catch (e) {
      return ResponseModel(data: null, error: e.toString());
    }
    return ResponseModel(data: null, error: "Something went wrong!");
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.setToken('');
  }
}
