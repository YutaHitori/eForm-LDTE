import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/core/controller.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController c = Get.put(AdminController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
        leading: canPop
          ? null : IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Get.offNamed('/'),
          ),
      ),
      body: Obx(() => c.isLoading.value
        ? Center(child: CircularProgressIndicator(),)
        : Column(
          spacing: 24,
          children: [
            SizedBox(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(onPressed: () => Get.toNamed('/admin/keterangan'), child: Text('Surat Keterangan Praktikum')),
                  ElevatedButton(onPressed: c.SignOutDialog, child: Text('Logout')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}