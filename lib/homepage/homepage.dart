import 'package:eform_ldte/misc/global.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eform_ldte/misc/function.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Image.asset('assets/logo.png', width: 182),
          Text('Formulir Elektronik\nLab Dasar Teknik Elektro\nSTEI ITB', textScaleFactor: 1.64, textAlign: TextAlign.center,),
          SizedBox(height: 4),
          Column(
            spacing: 8,
            children: [
              ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.pinjam), child: Text('Pinjam Peralatan')),
              ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.keterangan), child: Text('Keterangan Praktikum')),
              ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.pertukaran), child: Text('Pertukaran Jadwal Praktikum')),
            ],
          ),
        ],
      ),
    );
  }
}