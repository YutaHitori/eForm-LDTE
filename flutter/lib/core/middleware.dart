import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/misc/function.dart';
import 'package:ldte_stei_itb/misc/global.dart';

class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({
    this.reqLogin = true,
  });

  final bool reqLogin;

  @override
  RouteSettings? redirect(String? nroute) {
    bool isNewRoute = Get.previousRoute == '';

    if (!reqLogin) {
      if (auth.isLoggedIn) {
        snackbar('Warning!', 'User already logged in');
        if (isNewRoute) return RouteSettings(name: '/');
        Get.offAll('/');
        return RouteSettings();
      }
      return null;
    }
    
    if (!auth.isLoggedIn) { 
      snackbar('Unauthorized!', 'User not logged in');
      if (isNewRoute) return RouteSettings(name: '/login');
      Get.offAll('/login');
      return RouteSettings();
    }
    return null;
  }
}