import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class GlobalConfig extends StatelessWidget {
  const GlobalConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GlobalConfigController>();
    return Obx(() => PopScope(
      canPop: c.isSaved.value && !c.isAnyQueued && !c.itemQueue.isAnyQueued,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        c.saveAllDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Global Config'),
          actions: (c.isSaved.value && !c.isAnyQueued & !c.itemQueue.isAnyQueued) || c.isLoading.value ? null : [
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
                spacing: 8,
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
                  CustomTextField(
                    controller: c.namaKepalaLDTE,
                    focusNode: c.namaKepalaLDTEFocus,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Nama Kepala LDTE',
                    decoration: InputDecoration(
                      fillColor: c.namaKepalaLDTECanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.namaKepalaLDTECanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.namaKepalaLDTECanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: c.namaKepalaLDTESaved.value 
                            ? () {
                              c.namaKepalaLDTECanEdit.value = !c.namaKepalaLDTECanEdit.value;
                              if (c.namaKepalaLDTECanEdit.value) c.namaKepalaLDTEFocus.requestFocus();
                            }
                            : c.saveNamaKepalaLDTE,
                          icon: Icon(
                            c.namaKepalaLDTESaved.value 
                            ? c.namaKepalaLDTECanEdit.value
                              ? Icons.edit_off_rounded
                              : Icons.edit_rounded
                            : Icons.save_rounded
                          ),
                        ),
                      )
                    ),
                    readOnly: !c.namaKepalaLDTECanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.nipKepalaLDTE,
                    focusNode: c.nipKepalaLDTEFocus,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'NIP Kepala LDTE',
                    keyboardType: TextInputType.number,
                    inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')) ],
                    decoration: InputDecoration(
                      fillColor: c.nipKepalaLDTECanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.nipKepalaLDTECanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.nipKepalaLDTECanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: c.nipKepalaLDTESaved.value 
                            ? () {
                              c.nipKepalaLDTECanEdit.value = !c.nipKepalaLDTECanEdit.value;
                              if (c.nipKepalaLDTECanEdit.value) c.nipKepalaLDTEFocus.requestFocus();
                            }
                            : c.saveNipKepalaLDTE,
                          icon: Icon(
                            c.nipKepalaLDTESaved.value 
                            ? c.nipKepalaLDTECanEdit.value
                              ? Icons.edit_off_rounded
                              : Icons.edit_rounded
                            : Icons.save_rounded
                          ),
                        ),
                      )
                    ),
                    readOnly: !c.nipKepalaLDTECanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.caraPinjam,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Cara Pengisian Formulir Peminjaman Peralatan',
                    scrollbar: false,
                    decoration: InputDecoration(
                      fillColor: c.caraPinjamCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.caraPinjamCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.caraPinjamCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: c.caraPinjamSaved.value 
                            ? () {
                              c.caraPinjamCanEdit.value = !c.caraPinjamCanEdit.value;
                              if (c.caraPinjamCanEdit.value) c.caraPinjamFocus.requestFocus();
                            }
                            : c.saveCaraPinjam,
                          icon: Icon(
                            c.caraPinjamSaved.value 
                            ? c.caraPinjamCanEdit.value
                              ? Icons.edit_off_rounded
                              : Icons.edit_rounded
                            : Icons.save_rounded
                          ),
                        ),
                      )
                    ),
                    maxLines: c.caraPinjamCanEdit.value ? null : 3,
                    keyboardType: TextInputType.multiline,
                    readOnly: !c.caraPinjamCanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.caraKeterangan,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Cara Pengisian Surat Keterangan Praktikum',
                    scrollbar: false,
                    decoration: InputDecoration(
                      fillColor: c.caraKeteranganCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.caraKeteranganCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.caraKeteranganCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: c.caraKeteranganSaved.value 
                            ? () {
                              c.caraKeteranganCanEdit.value = !c.caraKeteranganCanEdit.value;
                              if (c.caraKeteranganCanEdit.value) c.caraKeteranganFocus.requestFocus();
                            }
                            : c.saveCaraKeterangan,
                          icon: Icon(
                            c.caraKeteranganSaved.value 
                            ? c.caraKeteranganCanEdit.value
                              ? Icons.edit_off_rounded
                              : Icons.edit_rounded
                            : Icons.save_rounded
                          ),
                        ),
                      )
                    ),
                    maxLines: c.caraKeteranganCanEdit.value ? null : 3,
                    keyboardType: TextInputType.multiline,
                    readOnly: !c.caraKeteranganCanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.caraPertukaran,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Cara Pengisian Formulir Pertukaran Jadwal Praktikum',
                    scrollbar: false,
                    decoration: InputDecoration(
                      fillColor: c.caraPertukaranCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.caraPertukaranCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.caraPertukaranCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: c.caraPertukaranSaved.value 
                            ? () {
                              c.caraPertukaranCanEdit.value = !c.caraPertukaranCanEdit.value;
                              if (c.caraPertukaranCanEdit.value) c.caraPertukaranFocus.requestFocus();
                            }
                            : c.saveCaraPertukaran,
                          icon: Icon(
                            c.caraPertukaranSaved.value 
                            ? c.caraPertukaranCanEdit.value
                              ? Icons.edit_off_rounded
                              : Icons.edit_rounded
                            : Icons.save_rounded
                          ),
                        ),
                      )
                    ),
                    maxLines: c.caraPertukaranCanEdit.value ? null : 3,
                    keyboardType: TextInputType.multiline,
                    readOnly: !c.caraPertukaranCanEdit.value,
                  ),
                ],
              ),
              Row(
                spacing: 8,
                children: [
                  Expanded(child: ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.list), child: Text('Daftar Fakultas/Sekolah ${c.isAnyQueued ? '(Unsaved)' : ''}'))),
                  if (c.isAnyQueued) ElevatedButton(onPressed: c.saveQueuedAction, child: Text('Save'))
                ],
              ),
              Row(
                spacing: 8,
                children: [
                  Expanded(child: ElevatedButton(onPressed: () => currentContext?.push(NamedRoute.barang), child: Text('Daftar Barang ${c.itemQueue.isAnyQueued ? '(Unsaved)' : ''}'))),
                  if (c.itemQueue.isAnyQueued) ElevatedButton(onPressed: c.saveItemAction, child: Text('Save'))
                ],
              ),
            ],
          ),
        )
      ),
    ));
  }
}