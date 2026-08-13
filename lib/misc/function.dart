
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/misc/extension.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:go_router/go_router.dart';
import "package:universal_html/universal_html.dart" as html;

BuildContext? get currentContext => Get.key.currentContext;

Future<void> hardRefresh() async {
  if (kIsWeb) html.window.location.reload();
}

void phoneValidateFormatFocus(TextEditingController phone, FocusNode phoneFN, Rxn<String> phoneE) {
  String result = phone.text.trim();
  if (phoneFN.hasFocus) {
    result = result.replaceAll(' - ', '');
  } else if (!phoneFN.hasFocus) {
    phoneE.value = null;
    if (!result.verifyPhone()) {
      phoneE.value = '*phone number invalid';
      return;
    }
    result = '${result.substring(0, 3)} - ${result.substring(3, 7)} - ${result.substring(7)}';
  }
  phone.text = result;
}

void alertDialog<T>(String title, String? subtitle, {double? titleFontSize, double? subtitleFontSize, double? height, double? width = 256 + 32, Color? backgroundColor, String? image, Widget? message, List<Widget>? actions,  VoidCallback? cancelAction, Function(bool, T?)? onPopInvokedWithResult, String cancelText = 'Close', VoidCallback? confirmAction, String confirmText = 'Confirm', bool dismissible = true}) {
  Future(() => Get.dialog(
    PopScope(
      onPopInvokedWithResult: onPopInvokedWithResult,
      canPop: dismissible,
      child: AlertDialog(
        title: Text(title, style: TextStyle(fontSize: titleFontSize)),
        content: SizedBox(
          height: height,
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (image != null) Image.asset(image, scale: 5, alignment: AlignmentGeometry.center,),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: subtitleFontSize)) : message,
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 24),
        actions: [
          TextButton(onPressed: cancelAction ?? currentContext?.pop, child: Text(cancelText)),
          if (confirmAction != null) ElevatedButton(onPressed: confirmAction, child: Text(confirmText)),
          if (actions != null) for (var action in actions) action
        ],
        actionsPadding: EdgeInsets.only(bottom: 8, right: 16),
      ),
    ),
    barrierDismissible: dismissible,
  ));
}

void snackbar(String title, String message, [IconData ? icon]) {
  Future(() => Get.snackbar(
    title, message, 
    margin: EdgeInsets.all(12),
    titleText: icon == null ? null : Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Text(title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
    ),
    messageText: icon == null ? null : Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Text(message,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
      ),
    ),
    icon: icon == null ? null : Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Icon(icon, size: 32),
    ),
    barBlur: 16
  ));
}

Color? getColorFromSubmissionStatus(String? status) =>
  status == 'exported' || status == 'returned' || status == 'insert'
  ? Colors.green
  : status == 'borrowed'
    ? Colors.blue
    : status == 'update'
      ? Colors.amber
      : status == 'pending' || status == 'overdue'
        ? Colors.orange
        : status == 'damaged'
          ? Colors.deepOrange
          : status == 'lost'
            ? Colors.purpleAccent
            : status == 'unchecked'
              ? Colors.grey
              : status == 'spam' || status == 'delete'
                ? Colors.red
                : null;

Future<bool> hasInternet([bool throwException = true]) async {
    final isConnected = await connection.hasInternetAccess;
    if (isConnected) return true;
    for (int i = 0; i < 4; i++) {
      await Future.delayed(Duration(milliseconds: 500));
      final temp = await connection.hasInternetAccess;
      if (temp) return true;
    }
    if (throwException) throw Exception('You are offline, Please check your internet connection and try again.');
    return false;
  }

  T getFindPut<T>(T controller) {
    return Get.isRegistered<T>() ? Get.find<T>() : Get.put(controller);
  }
  
  T? getFindCall<T>() {
    return Get.isRegistered<T>() ? Get.find<T>() : null;
  }

  void closeAllDialog() {
    if (currentContext != null) {
      Navigator.of(currentContext!).popUntil((route) => route.settings.name != null || route.isFirst);
    }
  }

  void debounceCallback(VoidCallback callback, [Timer? debounce, Duration duration = const Duration(milliseconds: 500)]) {
   
    if (debounce?.isActive ?? false) debounce?.cancel();
    
    debounce = Timer(duration, () {
      callback();
    });
  }