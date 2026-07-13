import 'dart:typed_data';

import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/core/custom-widget.dart';
import 'package:ldte_stei_itb/core/download/save_pdf.dart';
import 'package:ldte_stei_itb/core/model.dart';
import 'package:ldte_stei_itb/misc/function.dart';
import 'package:ldte_stei_itb/misc/global.dart';
import 'package:ldte_stei_itb/misc/extension.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PDFService {
  Future<pw.MemoryImage> pdfImage(String route) async {
    final ByteData bytes = await rootBundle.load(route);
    final Uint8List imageBytes = bytes.buffer.asUint8List();
    return pw.MemoryImage(imageBytes);
  }
  
  void preview(Uint8List savedFile, String fileName) async {
    Get.bottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          color: appTheme.colorScheme.background,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text(fileName)),
            Container(
              constraints: BoxConstraints(
                maxHeight: Get.height / 1.20
              ),
              height: Get.width * 1.294,
              child: PdfPreview(
                enableScrollToPage: true,
                maxPageWidth: double.infinity,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                pdfFileName: fileName,
                build: (PdfPageFormat format) => savedFile,
                useActions: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(child: ElevatedButton(onPressed: () => print(savedFile, fileName), child: Text('Print'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B2E3C)))),
                  Expanded(child: ElevatedButton(onPressed: () => download(savedFile, fileName), child: Text('Download'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.tertiary))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void download(Uint8List savedFile, String fileName) async {
    await savePdf(savedFile, fileName);
  }

  void print(Uint8List savedFile, String fileName) async {
    await Printing.layoutPdf(
      name: fileName,
      onLayout: (format) => savedFile,
    );
  }
}

class DateTimePickerService {
  Future<DateTime?> selectDate(BuildContext context, {DateTime? initial, DateTime? first, DateTime? last, String? helpText}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first ?? now.subtract(Duration(days: 365)),
      lastDate: last ?? now.add(Duration(days: 365)),
      helpText: helpText,
    );

    return picked;
  }

  Future<TimeOfDay?> selectTime(BuildContext context, {TimeOfDay? initial, String? helpText}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
      helpText: helpText,
    );

    return picked;
  }
}

class StorageService {
  Box<StorageCacheModel>? box;
  StorageCacheModel? cached;

  Future<void> initialize() async {
    if (box == null) {
      box = await Hive.openBox<StorageCacheModel>('local');
      await assignStorage();
      await sync();
    }
    print(cached?.lastSync);
  }

  Future<void> dispose() async {
    box?.close();
    box = null;
    cached = null;
  }

  Future<void> save() async {
    box!.put('cached_storage', cached!);
  }

  Future<void> sync() async {
    final outdated = cached!.lastSync == null ? null : await getOutdatedField(cached!.lastSync!);
    print('(sync) $outdated');
    if (outdated?.isEmpty == true) return; 
    
    final latest = await getLatestFieldData(outdated);
    print('(sync) $latest');

    if (latest != null) {
      updateOutdatedField(latest);
      cached!.lastSync = DateTime.now();
      await save();
    }
  }

  Future<void> assignStorage() async {
    cached ??= box!.get('cached_storage') ?? StorageCacheModel(
        globalConfig: GlobalConfigModel(),
        mataKuliahPraktikum: [],
        lastSync: null
      );
  }

  Future<List<LastUpdatedModel>> getOutdatedField(DateTime lastSync) async {
      List<LastUpdatedModel> list = [];
    try {
      final data = await auth.supabase
        .from('last_updated')
        .select();

      data.forEach((v) {
        final temp = LastUpdatedModel.fromJson(v);
        final isOutdated = temp.timestamp!.isAfter(lastSync);
        if (isOutdated) list.add(temp);
      });

    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', '(getOutdatedField) PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '(getOutdatedField) $error');
    }
    return list;
  }

  Future<void> getGlobalConfig() async {
    try {
      final global = await auth.supabase
       .from('global')
       .select();
       
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', '(getGlobalConfig) PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '(getGlobalConfig) $error');
    }
  }

  Future<List<MataKuliahPraktikumModel>?> getLatestFieldData([List<LastUpdatedModel>? outdated]) async {
    try {
      var query = auth.supabase
        .from('mata_kuliah')
        .select();

      if(outdated != null) {
        String filter = '';
        outdated.forEach((v) {
          filter = '$filter,and(fakultas.eq.${v.fakultas!},is_praktikum.eq.${v.isPraktikum!})';
        });
        filter = filter.substring(1);
        query = query.or(filter);
        print('(getLatestFieldData) $filter');
      }

      final data = await query;
      print('(getLatestFieldData) $data');

      List<MataKuliahPraktikumModel> list = [];
      data.forEach((v) {
        final temp = MataKuliahPraktikumModel.fromJson(v);
        list.add(temp);
      });
      
      return list;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', '(getLatestFieldData) PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '(getLatestFieldData) $error');
    }
    return null;
  }

  Future<void> updateOutdatedField(List<MataKuliahPraktikumModel> latest) async {
    final Set<Map<String, bool>> set = latest.map((v) => {v.fakultas: v.isPraktikum}).toSet();
    print('(updateOutdatedField) $set');
    for (final Map<String, bool> v in set) {
      cached!.mataKuliahPraktikum.removeWhere(
        (v1) => v1.fakultas == v.keys.first && v1.isPraktikum == v.values.first,
      );
    }
    cached!.mataKuliahPraktikum.addAll(latest);
  }
}

class AuthService {
  SupabaseClient get supabase => Supabase.instance.client;

  Stream<AuthState> get onAuthChanged =>
    supabase.auth.onAuthStateChange;

  User? get user => supabase.auth.currentUser;
  Session? get session => supabase.auth.currentSession;
  Future<String> get token async => await refreshExpiredToken() ?? session!.accessToken;
  bool get isLoggedIn => session != null;

  Future<String?> refreshExpiredToken() async {
    if (session?.isExpired == true) {
      final res = await Supabase.instance.client.auth.refreshSession();
      return res.session?.accessToken;
    }
    return null;
  }

  void listenAuthChange() {
    onAuthChanged.listen((data) async {
      final event = data.event;
  
      if (event == AuthChangeEvent.signedIn) {
        Future(() => snackbar('Success!', 'Logged in as ${user!.email}'));
        NC.isLoggedIn.value = true;
        Get.offAllNamed('/admin');
      }
      
      if (event == AuthChangeEvent.signedOut) {
        NC.isLoggedIn.value = false;
        Get.offAllNamed('/login');
      }
    });
  } 

  Future<bool> signInWithPassword(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      return true;
    } catch (e) {
      if (e is AuthApiException && e.code == 'invalid_credentials') {
        snackbar('Login Error', 'Invalid email or password.');
        return false;
      }
      alertDialog('Login Error', '$e');
    }
    return false;
  } 
}

class QFSPService {
  List entries = [];
  
  void updateButton(RxMap<String, bool> filter, String key) {
    filter.value[key] = !filter.value[key]!;
    filter.value['all'] = false;
    if (key == 'all') {
      filter.value.updateAll((k,v) => false);
    }
    if (filter.value.values.every((v) => v == false)) filter.value['all'] = true;
    filter.refresh();
  }

  List query(List raw, QFSPController c) {
    var query = c.queryController.text;
    return raw
        .where((item) => item is SuratKeteranganPraktikumModel
          ? (item.nama + item.nim).any((a) => a.toLowerCase().contains(query.toLowerCase()))
          : false
        )
        .toList();
  }
    
  List filter(List raw, String? itemKey, String? filterKey, List<DateTime>? date, QFSPController c) {
    if (itemKey != null && filterKey != null) updateButton(c.getFilterEnrty(filterKey), itemKey);
    var entries = raw;
    if (date != null) {
      entries = entries.where((e) {
        return e is SuratKeteranganPraktikumModel
          ? e.createdAt.isAfter(date[0]) && e.createdAt.isBefore(date[1])
            : e;
      }).toList();
    }
    for (var item in c.filter) {
      var temp = [];
      if (!item.filterEntry.value['all']!) {
        item.filterEntry.value.forEach((key, value) {
          if (value)
            temp.addAll(entries.where((m) => item.function(m).any((v) => v == key)));
        });
        entries = temp;
      }
    }
    return entries.toSet().toList();
  }

  List sort(List raw, QFSPController c) {
    switch (c.sortController.value) {
      case 'Latest': raw.sort((a, b) => b.id.compareTo(a.id)); break;
      case 'Oldest': raw.sort((a, b) => a.id.compareTo(b.id)); break;
      case 'Name (A-Z)': raw.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())); break;
      case 'Name (Z-A)': raw.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase())); break;
    }
    return raw;
  }

  List page(List raw, QFSPController c, RxInt pn) {
    int dpp = c.dataPerPage,
        cp = c.pageC.currentPage,
        lp = (raw.length / dpp).ceil(),
        length = dpp;
    if (lp == 0) lp = 1;
    if (cp >= lp) {
      cp = lp - 1;
      c.pageC.navigateToPage(cp);
    }
    pn.value = lp;
    if (raw.length - (cp * dpp) < dpp) length = raw.length % dpp;
    return List.generate(length, (i) => raw[i + (cp * dpp)]);
  }
}

class QFSPController {
  QFSPController({
    required this.filter,
    required this.onChanged,
    required this.pageC,
    this.dataPerPage = 15,
  });

  final List<FilterController> filter;
  final Function onChanged;
  final NumberPaginatorController pageC;
  final int dataPerPage;

  var queryController = TextEditingController();
  var sortController = SingleSelectController<String>('Latest');

  RxMap<String, bool> getFilterEnrty(String key) {
    return filter.where((e) => e.filterKey == key).toList().first.filterEntry;
  }
}

class FilterController {
  FilterController({
    required this.filterKey,
    required this.filterList,
    required this.function,
    this.multi = false
  });

  String filterKey;
  List<String> filterList;
  List<dynamic> Function(dynamic) function;
  bool multi;

  late RxMap<String, bool> filterEntry = {
    'all': true,
    for (var e in filterList) e: false
  }.obs;
}

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  static Map<String, XFile?> lastImages = {'default' : null};

  Future<void> retrieveLostData(Rxn<XFile> imageFiles, {Rxn<Uint8List>? memory, String key = 'default'}) async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
    }
    if (response.files != null) {
      imageFiles.value = response.files!.first;
      if (memory != null) memory.value = await lastImages[key]?.readAsBytes();
      else lastImages[key] = response.files!.first;
    }
  }

  Future<XFile> setPrefix(XFile file, String prefix) async {
  final bytes = await file.readAsBytes();
  return XFile.fromData(
    bytes,
    name: "${prefix == 'default' ? '': '$prefix-'}${file.name.substring(7)}",
    mimeType: file.mimeType,
  );
  } 

  Future<XFile?> selectImageFrom(ImageSource s, {String key = 'default'}) async {
    XFile? pickedFile = await _picker.pickImage(
      source: s,
      imageQuality: 80,
      maxWidth: 1920,    
      maxHeight: 1920, 
    );
    if (pickedFile != null) return setPrefix(pickedFile, key);
    return lastImages[key];
  }

  Future<void> selectImage(Rxn<XFile> imageFile, {Rxn<Uint8List>? memory, String key = 'default'}) async {
    await Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            MaterialButton(onPressed: () async {
              final pickedFile = await selectImageFrom(ImageSource.gallery, key: key);
              imageFile.value = pickedFile;
              if (memory != null) memory.value = await pickedFile!.readAsBytes();
              else lastImages[key] = pickedFile;
              Get.back();
            }, child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo, size: 50),
                Text('Gallery'),
              ],
            )),
            MaterialButton(onPressed: () async {
              await PermissionController().requestCameraPermission(onGranted: () async {
                final pickedFile = await selectImageFrom(ImageSource.camera, key: key);
                imageFile.value = pickedFile!;
                if (memory != null) memory.value = await pickedFile.readAsBytes();
                else lastImages[key] = pickedFile;
                Get.back();
              }); 
            }, child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, size: 50),
                Text('Camera'),
              ],
            ))
          ],
        ),
      ),
      backgroundColor: appTheme.cardColor, 
    );
  }

  void previewImage(Rxn<XFile> imageFile) async {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Preview: ${imageFile.value!.name}'),
            Expanded(child: Image.memory(await imageFile.value!.readAsBytes())),
          ],
        ),
      ),
      backgroundColor: appTheme.canvasColor,
    );
  }

  void resetImage(Rxn<XFile> imageFile, {Rxn<Uint8List>? memory, String key = 'default'}) {
    imageFile.value = null;
    if (memory != null) memory.value = null;
    else lastImages[key] = null;
  }
}

class PinjamService extends PDFService {
  final imagePicker = ImagePickerService();

  Future<Uint8List> compilePDF(Map<String, dynamic> form) async {
    final ttf = await rootBundle.load("fonts/calibri.ttf");
    final ttfBold = await rootBundle.load("fonts/calibri-bold.ttf");
    final ttfItalic = await rootBundle.load("fonts/calibri-italic.ttf");
    
    var pdf = pw.Document();

    final nama = form['nama'];
    final nim = form['nim'];
    final fakultas = form['fakultas'];
    final prodi = form['prodi'];
    final dosen = form['dosen'];
    final nipDosen = form['nipDosen'];
    final ketua = form['ketua'];
    final nipKetua = form['nipKetua'];
    final mulai = form['mulai'];
    final akhir = form['akhir'];
    final barang = form['barang'];
    final banyak = form['banyak'];

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(ttf),
        bold: pw.Font.ttf(ttfBold),
        italic: pw.Font.ttf(ttfItalic),
      ),
      margin: pw.EdgeInsets.fromLTRB(72, 36, 72, 36),
      footer: (context) {
        if (context.pageNumber == 1) {
          return pw.DefaultTextStyle(
            style: textStyle(fontSize: 11),
            child: pw.Transform.translate(
              offset: PdfPoint(0, 0), 
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Catatan:", textAlign: pw.TextAlign.justify),
                  pw.SizedBox(height: 2.0),
                  pw.Text("1. Surat pernyataan ini sekaligus sebagai tanda terima barang.", textAlign: pw.TextAlign.justify),
                  pw.SizedBox(height: 2.0),
                  pw.Text("2. Peminjam selain Prodi Teknik Elektro wajib menyertakan tanda tangan kaprodi.", textAlign: pw.TextAlign.justify),
                ]
              )
            )
          );
        } 
        return pw.Container();
      }, 
      build: (pw.Context context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text("FORM PEMINJAMAN PERALATAN", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text("LABORATORIUM DASAR TEKNIK ELEKTRO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text("SEKOLAH TEKNIK ELEKTRO DAN INFORMATIKA", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]
              )
            ),
            pw.SizedBox(height: 22),
            pw.Text("Saya yang bertanda tangan dibawah ini:"),
            pw.SizedBox(height: 22),
            pw.Text("Nama/NIM : ${nama ?? "______________________________"} / ${nim ?? "_________________"}"),
            pw.SizedBox(height: 22),
            pw.Text("adalah mahasiswa program studi ${prodi ?? "__________"} ${fakultas ?? "__________"} ITB, dengan pembimbing:"),
            pw.SizedBox(height: 22),
            pw.Text("Dosen Pembimbing: ${dosen ?? "______________________________"}"),
            pw.SizedBox(height: 22),
            pw.Text("Hendak meminjam sejumlah peralatan dari Laboratorium Dasar Teknik Elektro STEI:"),
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 18),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(18),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  for (int i = 0; i < barang.length; i++) ...[
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text('${i + 1}.'),
                      pw.Text('${barang[i]}${banyak[i]}'),
                    ]),
                  ]
                ],
              )
            ),
            pw.SizedBox(height: 22),
            pw.Text("Peminjaman saya lakukan mulai tanggal ${mulai ?? "_______________________"}"),
            pw.SizedBox(height: 5),
            pw.Text("dan akan dikembalikan tanggal ${akhir ?? "_____________________"}"),
            pw.SizedBox(height: 22),
            pw.Text("Saya berjanji untuk bertanggung jawab sepenuhnya terhadap barang yang saya pinjam dengan:"),
            pw.SizedBox(height: 22),
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 18),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(18),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(children: [
                    pw.Text("1."),
                    pw.Text("Tidak menyalahgunakan peralatan tersebut, termasuk untuk kegiatan diluar akademis", textAlign: pw.TextAlign.justify),
                  ]),
                  pw.TableRow(children: [pw.SizedBox(height: 5)]),
                  pw.TableRow(children: [
                    pw.Text("2."),
                    pw.Text("Mengembalikan dalam kondisi baik sebagaimana saat diterima, dan bersedia bertanggung jawab sepenuhnya terhadap segala macam kerusakan dan kehilangan.", textAlign: pw.TextAlign.justify),
                  ]),
                ]
              ),
            ),
            pw.SizedBox(height: 22),
            pw.Center(
              child: pw.Text("Bandung, ${mulai ?? "_____________________"}"),
            ),
            pw.SizedBox(height: 5),
            pw.Padding(
              padding: pw.EdgeInsets.symmetric(horizontal: 57),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Peminjam,'),
                      pw.SizedBox(height: 40),
                      pw.Text('Nama: ${nama ?? ''}'),
                      pw.SizedBox(height: 5),
                      pw.Text('NIM: ${nim ?? ''}'),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Dosen Pembimbing,'),
                      pw.SizedBox(height: 40,),
                      pw.Text('Nama: ${dosen ?? ''}'),
                      pw.SizedBox(height: 5),
                      pw.Text('NIP: ${nipDosen ?? ''}'),
                    ]
                  ),
                ]
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text("Mengetahui,"),
                  pw.SizedBox(height: 5),
                  pw.Text("Ketua Prodi ${prodi ?? "__________"}"),  
                  pw.SizedBox(height: 40,),
                  pw.Container(
                    constraints: pw.BoxConstraints(minWidth: 160),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Nama: ${ketua ?? ""}"),
                        pw.SizedBox(height: 5),
                        pw.Text('NIP: ${nipKetua ?? ''}'),
                      ]
                    ),
                  )
                ],
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(left :18),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 36),
                  pw.Text("ATURAN PEMINJAMAN PERALATAN LABORATORIUM DASAR TEKNIK ELEKTRO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 17),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(18),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      pw.TableRow(children: [pw.SizedBox(height: 5)]),
                      pw.TableRow(children: [
                        pw.Text('1.'),
                        pw.Text('Peminjam adalah mahasiswa program S1 Teknik Elektro ITB, dengan rekomendasi dosen pembimbing, atau sivitas akademik lain di lingkungan STEI.'),
                      ]),
                      pw.TableRow(children: [pw.SizedBox(height: 5)]),
                      pw.TableRow(children: [
                        pw.Text('2.'),
                        pw.Text('Peminjam selain mahasiswa S1/S2 Teknik Elektro, selain menyertakan rekomendasi dosen pembimbing, juga wajib mendapatkan rekomendasi dari KaProdi bersangkutan.'),
                      ]),
                      pw.TableRow(children: [pw.SizedBox(height: 5)]),
                      pw.TableRow(children: [
                        pw.Text('3.'),
                        pw.Text('Peralatan seperti signal generator, multimeter, osciloscope, logic analyzer, spektrum analyzer, dan sejenisnya hanya boleh dipinjam dan dipergunakan di lab dasar.'),
                      ]),
                      pw.TableRow(children: [pw.SizedBox(height: 5)]),
                      pw.TableRow(children: [
                        pw.Text('4.'),
                        pw.Text('Peminjam bertanggungjawab sepenuhnya terhadap barang/peralatan yang dipinjam.'),
                      ]),
                      pw.TableRow(children: [pw.SizedBox(height: 5)]),
                      pw.TableRow(children: [
                        pw.Text('5.'),
                        pw.Text('Cara melakukan peminjaman (development kit):'),
                      ]),
                      pw.TableRow(children: [pw.SizedBox(height: 5)]),
                      pw.TableRow(children: [
                        pw.Text(''),
                        pw.Table(
                          columnWidths: {
                            0: const pw.FixedColumnWidth(18),
                            1: const pw.FlexColumnWidth(),
                          },
                          children: [
                            pw.TableRow(children: [pw.SizedBox(height: 5)]),
                            pw.TableRow(children: [
                              pw.Text('a.'),
                              pw.Text('mahasiswa menghubungi teknisi Lab Dasar untuk menanyakan ketersediaan alat.'),
                            ]),
                            pw.TableRow(children: [pw.SizedBox(height: 5)]),
                            pw.TableRow(children: [
                              pw.Text('b.'),
                              pw.Text('mahasiswa mengisi form peminjaman online dan offline serta meminta tanda tangan / rekomendasi pembimbing dan kaprodi (jika diperlukan).'),
                            ]),
                            pw.TableRow(children: [pw.SizedBox(height: 5)]),
                            pw.TableRow(children: [
                              pw.Text('c.'),
                              pw.Text('mahasiswa menyerahkan form peminjaman yang telah diisi dan ditandatangani secara lengkap kepada teknisi, dan teknisi mencocokkan identitas peminjam.'),
                            ]),
                            pw.TableRow(children: [pw.SizedBox(height: 5)]),
                            pw.TableRow(children: [
                              pw.Text('d.'),
                              pw.Text('Mahasiswa menerima peralatan yang dipinjam. Jika ingin mencoba di Lab, harus dilakukan oleh teknisi didepan peminjam.'),
                            ]),
                            pw.TableRow(children: [pw.SizedBox(height: 5)]),
                            pw.TableRow(children: [
                              pw.Text('e.'),
                              pw.Text('Pada tanggal yang ditentukan, mahasiswa mengembalikan peralatan yang dipinjam ke teknisi. Teknisi mencoba / melakukan pengetesan dan memeriksa bahwa peralatan masih dalam kondisi baik dan lengkap.'),
                            ]),
                            pw.TableRow(children: [pw.SizedBox(height: 5)]),
                            pw.TableRow(children: [
                              pw.Text('f.'),
                              pw.Text('Proses pengambilan dan pengembalian harus dilakukan oleh mahasiswa yang namanya tertera di form peminjaman.'),
                            ]),
                          ]
                        )
                      ]),
                      pw.TableRow(children: [pw.SizedBox(height: 5)]),
                      pw.TableRow(children: [
                        pw.Text('6.'),
                        pw.Text('Segala hal yang belum tercantum dalam aturan ini akan ditetapkan kemudian.'),
                      ]),
                      pw.TableRow(children: [pw.SizedBox(height: 5)]),
                      pw.TableRow(children: [
                        pw.Text('7.'),
                        pw.Text('Peserta melampirkan foto KTM dan KTP pada form ini.'),
                      ]),
                    ],
                  )
                ]
              )
            ),
            pw.SizedBox(height: 22),
            pw.Text('Bandung, Maret 2021'),
            pw.SizedBox(height: 5),
            pw.Text('Lab Dasar Teknik Elektro'),
            pw.SizedBox(height: 5),
            pw.Text('STEI - ITB'),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 36),
                pw.Text("Lamipran", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('\n'),
                pw.Text('Foto / Scan KTM :'),
                if (form['ktm'] is Uint8List) ...[
                  pw.Container(
                    constraints: pw.BoxConstraints(
                      maxHeight: 10.cm,
                      maxWidth: 10.cm,
                    ),
                    child: pw.Image(pw.MemoryImage(form['ktm'])),
                  ),
                  pw.Text('\n'),
                ]
                else pw.SizedBox(height: 10.cm),
                pw.Text('Foto / Scan KTP :'),
                if (form['ktp'] is Uint8List) pw.Container(
                  constraints: pw.BoxConstraints(
                    maxHeight: 10.cm,
                    maxWidth: 10.cm,
                  ),
                  child: pw.Image(pw.MemoryImage(form['ktp'])),
                ),
              ]
            ),
          ]
        ),
      ]
    ));
    return pdf.save();
  }
}

class SuratKeteranganPraktikumService {
  final imagePicker = ImagePickerService();
  final QFSP = QFSPService();

  Future<String?> uploadImage(XFile bukti) async {
    try {
      final path = '${now.millisecondsSinceEpoch}-${bukti.name}';
      await auth.supabase.storage
        .from('uploads')
        .uploadBinary(path, await bukti.readAsBytes());
      return auth.supabase.storage.from('uploads').getPublicUrl(path);
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }

  Future<bool> submitForm(Map<String, dynamic> form) async {
    try {
      await auth.supabase
        .from('surat_keterangan_praktikum')
        .insert(form);
      return true;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return false;
  }
}

class GlobalSettingService {
   Future<List<MataKuliahPraktikumModel>?> getAllMatkul() async {
    try {
      final data = await auth.supabase
        .from('mata_kuliah')
        .select();
      var res = <MataKuliahPraktikumModel>[];
      data.forEach((item) => res.add(MataKuliahPraktikumModel.fromJson(item)));
      return res;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }
}

class AdminSuratKeteranganPraktikumService extends PDFService {
  Future<List<SuratKeteranganPraktikumModel>?> getAllSubmissions() async {
    try {
      final data = await auth.supabase
        .from('surat_keterangan_praktikum')
        .select();
      var res = <SuratKeteranganPraktikumModel>[];
      data.forEach((item) => res.add(SuratKeteranganPraktikumModel.fromJson(item)));
      return res;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }
  
  Future<Uint8List> compilePDF(SuratKeteranganPraktikumModel data) async {
    final ttf = await rootBundle.load("fonts/tahoma.ttf");
    
    var pdf = pw.Document();
    final today = DateFormat('d MMMM yyyy', 'id_ID').format(now);
    final timeStart = data.timeStart.toFormatedString();
    final timeEnd = data.timeEnd.toFormatedString();
    final nama = data.nama;
    final nim = data.nim;
    final matkul = data.matkul;
    final praktikum = data.praktikum;
    final modul = data.modul;
    final date = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(data.date);
    final bukti = await networkImage(data.bukti);

    final headerImage = await pdfImage('assets/Header ITB STEI.png');
    final footerImage = await pdfImage('assets/Footer ITB STEI.png');

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(ttf)
      ),
      margin: pw.EdgeInsets.fromLTRB(2.cm, 0, 2.cm, 5.mm),
      header: (context) => pw.Image(headerImage, width: PdfPageFormat.a4.availableWidth),
      footer: (context) => pw.Image(footerImage, width: PdfPageFormat.a4.availableWidth),
      build: (pw.Context context) => [
        pw.DefaultTextStyle(
          style: textStyle(fontSize: 11, lineSpacing: 1),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Table(
                columnWidths: {
                  0: pw.FixedColumnWidth(26.mm),
                  1: pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Nomor'),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(': 2603/IT1.C12.6.11/DA.10/2026'),
                          pw.Text(today),
                        ],
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                     pw.Text('Lampiran'),
                     pw.Text(': -'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('Perihal'),
                      pw.Text(': Surat Keterangan Praktikum'),
                    ],
                  ),
                ],
              ),  

              pw.Text('\n\n\n'),

              pw.Center(
                child: pw.Text(
                  'SURAT KETERANGAN PRAKTIKUM',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.Text('\n\n'),

              pw.Text(
                'Melalui surat ini, diberitahukan bahwa mahasiswa dengan '
                'nama dan NIM di bawah ini tidak dapat mengikuti mata '
                'kuliah $matkul karena mengikuti '
                '$praktikum modul $modul yang '
                'dilaksanakan secara luring di Laboratorium Dasar '
                'Teknik Elektro pada',
                textAlign: pw.TextAlign.justify,
              ),

              pw.Text('\n'),

              pw.Center(
                child: pw.SizedBox(
                  width: 8.82.cm,
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(100),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Text('Hari, Tanggal'),
                          pw.Text(': $date'),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('Pukul'),
                          pw.Text(': $timeStart – $timeEnd WIB'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              pw.Text('\n'),

              pw.Center(
                child: pw.SizedBox(
                  width: 8.82.cm,
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(60),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      for (var i = 0; i < nama.length; i++) ...[
                        pw.TableRow(children: [
                          pw.Text('${nim[i]}', textAlign: pw.TextAlign.center),
                          pw.Text('  ${nama[i]}'),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),

              pw.Text('\n'),

              pw.Text('Demikian surat keterangan ini dibuat agar dapat dipergunakan sebagaimana mestinya.' ),

              pw.Text('\n\n'),

              pw.Container(
                padding: pw.EdgeInsets.only(right: 2.cm),
                alignment: pw.Alignment.topRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Kepala Lab. Dasar Teknik Elektro,'),

                    pw.Text('\n\n\n\n\n\n'),

                    pw.Text(
                      'Dr. Waskita Adijarto, ST., MT.',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.Text('NIP.: 19720403 199803 1 003'),
                  ],
                ),
              ),
            ]
          ),
        ),
        pw.NewPage(),
        pw.Text('Bukti Screenshot Jadwal Praktikum :', style: pw.TextStyle(fontSize: 11)),
        pw.Text('\n'),
        if (true) pw.Container(
          constraints: pw.BoxConstraints(
            maxHeight: 15.cm,
            maxWidth: 15.cm,
          ),
          child: pw.Image(bukti),
        ),
      ]
    ));
    return pdf.save();
  }
}