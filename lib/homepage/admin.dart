import 'package:eform_ldte/misc/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/function.dart';

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
                          ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.pinjamAdmin), child: Text('Peminjaman Peralatan')),
                          ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.keteranganAdmin), child: Text('Surat Keterangan Praktikum')),
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