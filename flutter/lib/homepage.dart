import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/misc/global.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
        actions: [
          if (NC.isLoggedIn.value) TextButton(onPressed: () => Get.toNamed('/admin'),child: Text('admin'))
          else TextButton(onPressed: () => Get.toNamed('/login'),child: Text('login')),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            spacing: 16,
            children: [
              SizedBox(),
              Text('Formulir LDTE STEI ITB', textScaleFactor: 1.6,),
              ElevatedButton(onPressed: () => Get.toNamed('/form/pinjam'), child: Text('Pinjam Peralatan')),
              ElevatedButton(onPressed: () => Get.toNamed('/form/keterangan'), child: Text('Keterangan praktikum'))
            ],
          ),
        ),
      ),
    ));
  }
}