import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/core/custom-widget.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController c = Get.put(AdminController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      drawer: Get.width.isGreaterThan(800) ? null : SideMenuNavigation(context, 'admin'),
      body: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            if (Get.width.isGreaterThan(800)) SideMenuNavigation(context, 'admin'),
            Expanded(
              child: Obx(() => c.isLoading.value
                ? Center(child: CircularProgressIndicator(),)
                : Column(
                  spacing: 24,
                  children: [
                    SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        spacing: kIsWeb ? 8 : 0,
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
            ),
          ],
        ),
      ),
    );
  }
}