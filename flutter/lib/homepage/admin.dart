import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/misc/function.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController c = Get.put(AdminController());
    return Row(
          children: [
            Expanded(
              child: c.isLoading.value
                ? Center(child: CircularProgressIndicator(),)
                : Column(
                  spacing: 24,
                  children: [
                    SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(onPressed: () => currentContext?.push('/admin/surat-keterangan'), child: Text('Surat Keterangan Praktikum')),
                          ElevatedButton(onPressed: c.SignOutDialog, child: Text('Logout')),
                        ],
                      ),
                    ),
                  ],
                ),
            ),
          ],
    );
  }
}