import 'package:eform_ldte/misc/global.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/function.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    final c = getFindPut(AdminController());
    return c.isLoading.value
      ? Center(child: CircularProgressIndicator())
      : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.config), child: Text('Global Config')),
                ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.pinjamAdmin), child: Text('Peminjaman Peralatan')),
                ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.keteranganAdmin), child: Text('Surat Keterangan Praktikum')),
              ],
            ),
            ElevatedButton(onPressed: c.SignOutDialog, child: Text('Logout')),
          ],
        ),
      );
  }
}