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
        body: c.isLoading.value
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
          : RefreshIndicator(
            onRefresh: c.isSaved.value && !c.isAnyQueued && !c.itemQueue.isAnyQueued ? hardRefresh : () async {},
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.lineOASaved.value)
                            IconButton(
                              onPressed: c.lineOAUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.lineOASaved.value 
                                ? () {
                                  c.lineOACanEdit.value = !c.lineOACanEdit.value;
                                  if (c.lineOACanEdit.value) {
                                    c.lineOAFocus.requestFocus();
                                  } else {
                                    c.lineOAFocus.unfocus();
                                  }
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
                          ],
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.nomorSuratSaved.value)
                            IconButton(
                              onPressed: c.nomorSuratUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.nomorSuratSaved.value 
                                ? () {
                                  c.nomorSuratCanEdit.value = !c.nomorSuratCanEdit.value;
                                  if (c.nomorSuratCanEdit.value) {
                                    c.nomorSuratFocus.requestFocus();
                                  } else {
                                    c.nomorSuratFocus.unfocus();
                                  }
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
                          ],
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.namaKepalaLDTESaved.value)
                            IconButton(
                              onPressed: c.namaKepalaLDTEUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.namaKepalaLDTESaved.value 
                                ? () {
                                  c.namaKepalaLDTECanEdit.value = !c.namaKepalaLDTECanEdit.value;
                                  if (c.namaKepalaLDTECanEdit.value) {
                                    c.namaKepalaLDTEFocus.requestFocus();
                                  } else {
                                    c.namaKepalaLDTEFocus.unfocus();
                                  }
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
                          ],
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.nipKepalaLDTESaved.value)
                            IconButton(
                              onPressed: c.nipKepalaLDTEUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.nipKepalaLDTESaved.value 
                                ? () {
                                  c.nipKepalaLDTECanEdit.value = !c.nipKepalaLDTECanEdit.value;
                                  if (c.nipKepalaLDTECanEdit.value) {
                                    c.nipKepalaLDTEFocus.requestFocus();
                                  } else {
                                    c.nipKepalaLDTEFocus.unfocus();
                                  }
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
                          ],
                        ),
                      )
                    ),
                    readOnly: !c.nipKepalaLDTECanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.caraPinjam,
                    focusNode: c.caraPinjamFocus,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Cara Pengisian Formulir Peminjaman Peralatan',
                    scrollbar: false,
                    maxHeight: 384,
                    decoration: InputDecoration(
                      fillColor: c.caraPinjamCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.caraPinjamCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.caraPinjamCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      hintText: '\n\n',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.caraPinjamSaved.value)
                            IconButton(
                              onPressed: c.caraPinjamUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.caraPinjamSaved.value 
                                ? () {
                                  c.caraPinjamCanEdit.value = !c.caraPinjamCanEdit.value;
                                  if (c.caraPinjamCanEdit.value) {
                                    c.caraPinjamFocus.requestFocus();
                                  } else {
                                    c.caraPinjamFocus.unfocus();
                                  }
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
                          ],
                        ),
                      )
                    ),
                    maxLines: c.caraPinjamCanEdit.value ? null : 3,
                    keyboardType: TextInputType.multiline,
                    readOnly: !c.caraPinjamCanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.caraKeterangan,
                    focusNode: c.caraKeteranganFocus,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Cara Pengisian Surat Keterangan Praktikum',
                    scrollbar: false,
                    maxHeight: 384,
                    decoration: InputDecoration(
                      fillColor: c.caraKeteranganCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.caraKeteranganCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.caraKeteranganCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      hintText: '\n\n',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.caraKeteranganSaved.value)
                            IconButton(
                              onPressed: c.caraKeteranganUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.caraKeteranganSaved.value 
                                ? () {
                                  c.caraKeteranganCanEdit.value = !c.caraKeteranganCanEdit.value;
                                  if (c.caraKeteranganCanEdit.value) {
                                    c.caraKeteranganFocus.requestFocus();
                                  } else {
                                    c.caraKeteranganFocus.unfocus();
                                  }
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
                          ],
                        ),
                      )
                    ),
                    maxLines: c.caraKeteranganCanEdit.value ? null : 3,
                    keyboardType: TextInputType.multiline,
                    readOnly: !c.caraKeteranganCanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.caraPertukaran,
                    focusNode: c.caraPertukaranFocus,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Cara Pengisian Formulir Pertukaran Jadwal Praktikum',
                    scrollbar: false,
                    maxHeight: 384,
                    decoration: InputDecoration(
                      fillColor: c.caraPertukaranCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.caraPertukaranCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.caraPertukaranCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      hintText: '\n\n',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.caraPertukaranSaved.value)
                            IconButton(
                              onPressed: c.caraPertukaranUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.caraPertukaranSaved.value 
                                ? () {
                                  c.caraPertukaranCanEdit.value = !c.caraPertukaranCanEdit.value;
                                  if (c.caraPertukaranCanEdit.value) {
                                    c.caraPertukaranFocus.requestFocus();
                                  } else {
                                    c.caraPertukaranFocus.unfocus();
                                  }
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
                          ],
                        ),
                      )
                    ),
                    maxLines: c.caraPertukaranCanEdit.value ? null : 3,
                    keyboardType: TextInputType.multiline,
                    readOnly: !c.caraPertukaranCanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.caraIzin,
                    focusNode: c.caraIzinFocus,
                    onChanged: (v) => c.isSavedCheck(),
                    labelText: 'Cara Pengisian Formulir Izin Tidak Mengikuti Praktikum',
                    scrollbar: false,
                    maxHeight: 384,
                    decoration: InputDecoration(
                      fillColor: c.caraIzinCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.caraIzinCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.caraIzinCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      hintText: '\n\n',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.caraIzinSaved.value)
                            IconButton(
                              onPressed: c.caraIzinUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.caraIzinSaved.value 
                                ? () {
                                  c.caraIzinCanEdit.value = !c.caraIzinCanEdit.value;
                                  if (c.caraIzinCanEdit.value) {
                                    c.caraIzinFocus.requestFocus();
                                  } else {
                                    c.caraIzinFocus.unfocus();
                                  }
                                }
                                : c.saveCaraIzin,
                              icon: Icon(
                                c.caraIzinSaved.value 
                                ? c.caraIzinCanEdit.value
                                  ? Icons.edit_off_rounded
                                  : Icons.edit_rounded
                                : Icons.save_rounded
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    maxLines: c.caraIzinCanEdit.value ? null : 3,
                    keyboardType: TextInputType.multiline,
                    readOnly: !c.caraIzinCanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.templatePertukaran,
                    focusNode: c.templatePertukaranFocus,
                    errorText: c.templatePertukaranE.value,
                    onChanged: (v) {
                      c.isSavedCheck();
                      c.isTemplateValid('pertukaran');
                    },
                    labelText: 'Template Pesan Pertukaran Jadwal Praktikum',
                    scrollbar: false,
                    maxHeight: 384,
                    decoration: InputDecoration(
                      fillColor: c.templatePertukaranCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.templatePertukaranCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.templatePertukaranCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      hintText: '\n\n',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.templatePertukaranSaved.value)
                            IconButton(
                              onPressed: c.templatePertukaranUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.templatePertukaranSaved.value 
                                ? () {
                                  c.templatePertukaranCanEdit.value = !c.templatePertukaranCanEdit.value;
                                  if (c.templatePertukaranCanEdit.value) {
                                    c.templatePertukaranFocus.requestFocus();
                                  } else {
                                    c.templatePertukaranFocus.unfocus();
                                  }
                                }
                                : c.templatePertukaranE.value != null ? null : c.savetemplatePertukaran,
                              icon: Icon(
                                c.templatePertukaranSaved.value 
                                ? c.templatePertukaranCanEdit.value
                                  ? Icons.edit_off_rounded
                                  : Icons.edit_rounded
                                : Icons.save_rounded
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    maxLines: c.templatePertukaranCanEdit.value ? null : 3,
                    keyboardType: TextInputType.multiline,
                    readOnly: !c.templatePertukaranCanEdit.value,
                  ),
                  CustomTextField(
                    controller: c.templateIzin,
                    focusNode: c.templateIzinFocus,
                    errorText: c.templateIzinE.value,
                    onChanged: (v) {
                      c.isSavedCheck();
                      c.isTemplateValid('izin');
                    },
                    labelText: 'Template Pesan Surat Izin Praktikum',
                    scrollbar: false,
                    maxHeight: 384,
                    decoration: InputDecoration(
                      fillColor: c.templateIzinCanEdit.value ? null : Color(0xFF181818),
                      hoverColor: c.templateIzinCanEdit.value ? null : Colors.transparent,
                      focusedBorder: c.templateIzinCanEdit.value ? null : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ), 
                      hintText: '\n\n',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!c.templateIzinSaved.value)
                            IconButton(
                              onPressed: c.templateIzinUndo,
                              icon: Icon(Icons.undo_rounded, color: Colors.amber),
                            ),
                            IconButton(
                              onPressed: c.templateIzinSaved.value 
                                ? () {
                                  c.templateIzinCanEdit.value = !c.templateIzinCanEdit.value;
                                  if (c.templateIzinCanEdit.value) {
                                    c.templateIzinFocus.requestFocus();
                                  } else {
                                    c.templateIzinFocus.unfocus();
                                  }
                                }
                                : c.templateIzinE.value != null ? null : c.savetemplateIzin,
                              icon: Icon(
                                c.templateIzinSaved.value 
                                ? c.templateIzinCanEdit.value
                                  ? Icons.edit_off_rounded
                                  : Icons.edit_rounded
                                : Icons.save_rounded
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    maxLines: c.templateIzinCanEdit.value ? null : 3,
                    keyboardType: TextInputType.multiline,
                    readOnly: !c.templateIzinCanEdit.value,
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
              ),
            ),
          )
      ),
    ));
  }
}