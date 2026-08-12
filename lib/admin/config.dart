import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class GlobalConfig extends StatelessWidget {
  const GlobalConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GlobalConfigController>();
    return Obx(() => PopScope(
      canPop: c.isSaved.value,
      onPopInvoked: (didPop) {
        if (didPop) return;
        c.saveAllDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Global Config'),
          actions: c.isSaved.value || c.isLoading.value ? null : [
            TextButton(onPressed: c.saveAll, child: Text('Save All'))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: c.isLoading.value
            ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 24,
                children: [
                  CircularProgressIndicator(),
                  Text(c.loadingMessage.value ?? 'Loading...', textAlign: TextAlign.center)
                ],
              ),
            ) 
            : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Column(
                children: [
                  CustomTextField(
                    controller: c.lineOA,
                    focusNode: c.lineOAFocus,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Line Official Account LDTE',
                    decoration: InputDecoration(
                      fillColor: c.lineOACanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.lineOACanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.lineOACanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      prefix: Text('@'),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: c.lineOASaved.value 
                            ? () {
                              c.lineOACanEdit.value = !c.lineOACanEdit.value;
                              if (c.lineOACanEdit.value) c.lineOAFocus.requestFocus();
                            }
                            : c.saveLineOa,
                          icon: Icon(
                            c.lineOASaved.value 
                            ? c.lineOACanEdit.value
                              ? Icons.edit_off_rounded
                              : Icons.edit_rounded
                            : Icons.save_rounded
                          ),
                        ),
                      )
                    ),
                    readOnly: !c.lineOACanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.nomorSurat,
                    focusNode: c.nomorSuratFocus,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Nomor Surat Keterangan Praktikum',
                    decoration: InputDecoration(
                      fillColor: c.nomorSuratCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.nomorSuratCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.nomorSuratCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: c.nomorSuratSaved.value 
                            ? () {
                              c.nomorSuratCanEdit.value = !c.nomorSuratCanEdit.value;
                              if (c.nomorSuratCanEdit.value) c.nomorSuratFocus.requestFocus();
                            }
                            : c.saveNomorSurat,
                          icon: Icon(
                            c.nomorSuratSaved.value 
                            ? c.nomorSuratCanEdit.value
                              ? Icons.edit_off_rounded
                              : Icons.edit_rounded
                            : Icons.save_rounded
                          ),
                        ),
                      )
                    ),
                    readOnly: !c.nomorSuratCanEdit.value,
                  ),
                ],
              ),
              ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.list), child: Text('Daftar Fakultas')),
            ],
          ),
        )
      ),
    ));
  }
}