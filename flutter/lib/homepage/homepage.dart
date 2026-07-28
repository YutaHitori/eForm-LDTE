import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ldte_stei_itb/misc/function.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  spacing: 8,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Center(child: Text('eFormulir LDTE STEI ITB', textScaleFactor: 1.8,)),
                    ),
                    ElevatedButton(onPressed: () => currentContext?.push('/peminjaman-peralatan'), child: Text('Pinjam Peralatan')),
                    ElevatedButton(onPressed: () => currentContext?.push('/surat-keterangan'), child: Text('Keterangan praktikum'))
                  ],
                ),
              ),
            ),
          ),
        ],
    );
  }
}