import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/core/custom-widget.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
      ),
      drawer: Get.width.isGreaterThan(800) ? null : SideMenuNavigation(context, 'homepage'),
      body: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            if (Get.width.isGreaterThan(800)) SideMenuNavigation(context, 'homepage'),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    spacing: kIsWeb ? 16 : 8,
                    children: [
                      SizedBox(
                        height: 80,
                        child: Center(child: Text('Formulir LDTE STEI ITB', textScaleFactor: 1.8,)),
                      ),
                      ElevatedButton(onPressed: () => Get.toNamed('/form/pinjam'), child: Text('Pinjam Peralatan')),
                      ElevatedButton(onPressed: () => Get.toNamed('/form/keterangan'), child: Text('Keterangan praktikum'))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}