import 'dart:async';
import 'dart:typed_data';

import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/core/pdf_worker.dart';
import 'package:ldte_stei_itb/misc/widget.dart';
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

  Future<Uint8List> bytesImage(String route) async {
    final ByteData bytes = await rootBundle.load(route);
    return bytes.buffer.asUint8List();
  }
  
  static void f(VoidCallback f) => f();
  

  void preview(Uint8List savedFile, String fileName, [Function(VoidCallback) customCallback = f, RxBool? isLoading]) async {
    final action = Row(
      spacing: 8,
      children: [
        Expanded(child: ElevatedButton.icon(
          onPressed: isLoading?.value == true ? null : () => customCallback(() => printPdf(savedFile, fileName)), 
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B2E3C)),
          label: Text(isLoading?.value == true ? 'Loading' : 'Print'),
          icon: isLoading?.value == true ? null : Icon(Icons.print_rounded),
        )),
        Expanded(child: ElevatedButton.icon(
          onPressed: isLoading?.value == true ? null : () => customCallback(() => downloadPdf(savedFile, fileName)),
          style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.tertiary),
          label: Text(isLoading?.value == true ? 'Please wait' : 'Download'), 
          icon: isLoading?.value == true ? null : Icon(Icons.download_rounded),
        )),
      ],
    );
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          color: appTheme.colorScheme.background,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: EdgeInsets.all(8), child: Column(
              children: [
                Text(fileName),
                Text('Mohon periksa kesesuaian data yang telah diisi.'),
              ],
            )),
            Container(
              width: Get.width,
              constraints: BoxConstraints(
                maxHeight: Get.height / 1.24
              ),
              height: Get.width * 1.32,
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
              child: isLoading == null
                ? action : Obx(() => action),
            ),
          ],
        ),
      ),
    );
  }

  void downloadPdf(Uint8List savedFile, String fileName) async {
    await savePdf(savedFile, fileName);
  }

  void printPdf(Uint8List savedFile, String fileName) async {
    await Printing.layoutPdf(
      name: fileName,
      onLayout: (format) => savedFile,
    );
  }
}

class DateTimePickerService {
  Future<DateTime?> selectDate({DateTime? initial, DateTime? first, DateTime? last, String? helpText}) async {
    final DateTime? picked = await showDatePicker(
      context: currentContext!,
      initialDate: initial,
      firstDate: first ?? now.subtract(Duration(days: 365)),
      lastDate: last ?? now.add(Duration(days: 365)),
      helpText: helpText,
    );

    return picked;
  }

  Future<TimeOfDay?> selectTime({TimeOfDay? initial, String? helpText}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: currentContext!,
      initialTime: initial ?? TimeOfDay.now(),
      helpText: helpText,
      builder: (BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        alwaysUse24HourFormat: true,
      ),
      child: child!,
    );
  },
    );

    return picked;
  }
}

class StorageService {
  Box<StorageCacheModel>? box;
  StorageCacheModel cached = StorageCacheModel(
    globalConfig: GlobalConfigModel(),
    mataKuliahPraktikum: [],
    lastSync: null
  );

  Future<void> initialize() async {
    if (box == null) {
      box = await Hive.openBox<StorageCacheModel>('local');
      cached = box?.get('cached_storage') ?? cached;
      NC.lastSync.value = cached.lastSync;
      sync();
    }
  }

  Future<void> dispose() async {
    box?.close();
    box = null;
  }

  Future<void> save() async {
    box?.put('cached_storage', cached);
  }

  Future<void> sync() async {
    final lastSync = cached.lastSync;
    List<MataKuliahPraktikumModel>? latest;
    GlobalConfigModel? global;

    if (lastSync == null) {
      NC.isSyncing.value = true;
      latest = await getLatestFieldData();
      global = await getLatestGlobalConfig();
    } else {
      final outdated = await getOutdatedField(lastSync);
      print('outdated field : $outdated');

      if (outdated.any((v) => v.type == 'global')) {
        outdated.removeWhere((v) => v.type == 'global');
        NC.isSyncing.value = true;
        global = await getLatestGlobalConfig();
      }

      if (outdated.isNotEmpty) {
        NC.isSyncing.value = true;
        latest = await getLatestFieldData(outdated);
      }
    }

    print('synced matkul data : $latest');
    print('synced global settings : $global');
    if (latest != null) updateOutdatedField(latest);
    if (global != null) updateGlobalConfig(global);
    if (latest != null || global != null) {
      cached.lastSync = now;
      NC.lastSync.value = now;
      await save();
      print('device synced at : ${cached.lastSync}');
    }

    NC.isSyncing.value = false;
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

  Future<Uri?> getLineOALDTEUrl([String? message]) async {
    var lineID = storage.cached.globalConfig.lineOALDTE;
    if (lineID == null) {
      await storage.sync();
      lineID = storage.cached.globalConfig.lineOALDTE;
      if (lineID == null) return null;
    }
    return Uri(
      scheme: 'https',
      host: 'line.me',
      path: 'R/oaMessage/$lineID',
      query: message == null ? null :Uri.encodeComponent(message)
    );
  }

  Future<List<MataKuliahPraktikumModel>?> getLatestFieldData([List<LastUpdatedModel>? outdated]) async {
    try {
      var query = auth.supabase
        .from('mata_kuliah')
        .select();

      if(outdated != null) {
        String filter = '';
        outdated.forEach((v) {
          filter = '$filter,and(fakultas.eq.${v.fakultas!},is_praktikum.eq.${v.type == 'praktikum'})';
        });
        filter = filter.substring(1);
        query = query.or(filter);
        print('uutdated query filter : $filter');
      }

      final data = await query;
      print('outdated field : $data');

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
    print('fetched matkul set : $set');
    for (final Map<String, bool> v in set) {
      cached.mataKuliahPraktikum.removeWhere(
        (v1) => v1.fakultas == v.keys.first && v1.isPraktikum == v.values.first,
      );
    }
    cached.mataKuliahPraktikum.addAll(latest);
  }

  Future<void> updateGlobalConfig(GlobalConfigModel global) async {
    cached.globalConfig = global;
  }

  Future<GlobalConfigModel?> getLatestGlobalConfig() async {
    try {
      var data = await auth.supabase
        .from('global')
        .select()
        .limit(1)
        .single();

      print('fetched global settings : $data');

      return GlobalConfigModel.fromJson(data);
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', '(getLatestGlobalConfig) PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '(getLatestGlobalConfig) $error');
    }
    return null;
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
        NC.navigateToPage('/admin');
      }
      
      if (event == AuthChangeEvent.signedOut) {
        NC.isLoggedIn.value = false;
        NC.navigateToPage('/login');
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

  List<T> query<T>(List<T> raw, QFSPController c, List<String?> Function(T) match) {
    return raw.where((item) => match(item).any((text) => text == null ? false : text.toLowerCase().contains(c.queryController.text))).toList();
  }

  List<T> filter<T>(List<T> raw, QFSPController c, [String? itemKey, String? filterKey, List<DateTime?>? date, DateTime? Function(T)? dateAttribure]) {
    if (itemKey != null && filterKey != null) updateButton(c.getFilterEnrty(filterKey), itemKey);
    var entries = raw;
    if (date?.every((d) => d != null) == true && dateAttribure != null) {
      entries = entries.where((e) => dateAttribure(e) == null ? false : dateAttribure(e)!.isAfter(date![0]!) && dateAttribure(e)!.isBefore(date[1]!)).toList();
    }
    for (var item in c.filter) {
      List<T> temp = [];
      if (!item.filterEntry.value['all']!) {
        item.filterEntry.value.forEach((key, value) {
          if (value) temp.addAll(entries.where((m) => item.function(m).any((v) => v == key)));
        });
        entries = temp;
      }
    }
    return entries.toSet().toList();
  }

  List<T> sort<T>(List<T> raw, QFSPController c) {
    final temp = raw.cast<dynamic>();
    switch (c.sortController.value) {
      case 'Latest': temp.sort((a, b) => b.id.compareTo(a.id)); break;
      case 'Oldest': temp.sort((a, b) => a.id.compareTo(b.id)); break;
      case 'Name (A-Z)': temp.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase())); break;
      case 'Name (Z-A)': temp.sort((a, b) => b.nama.toLowerCase().compareTo(a.nama.toLowerCase())); break;
    }
    return temp.cast<T>();
  }

  List<T> page<T>(List<T> raw, QFSPController c, RxInt pn) {
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
    if (kIsWeb) return;
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
      imageQuality: 65,
      maxWidth: 1280,    
      maxHeight: 1280, 
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
              closeAllDialog();
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
                closeAllDialog();
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

  void previewImage(XFile imageFile) async {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          children: [
            Text(imageFile.name),
            Expanded(child: Image.memory(await imageFile.readAsBytes())),
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

class PeminjamanPeralatanService extends PDFService {
  final IsolateManager<Uint8List, dynamic> _pdfWorker = IsolateManager.create(
    peminjamanPeralatanCompilePdfWorker,
    workerName: 'peminjamanPeralatanCompilePdfWorker',
    concurrent: 1,
  );

  void initWorker() async {
    if (!_pdfWorker.isStarted) {
      await _pdfWorker.start();
      print('worker started');
    } else print('worker already started');
  }
  void closeWorker() async {
    if (_pdfWorker.isStarted) {
      await _pdfWorker.stop();
      print('worker stoped');
    } else print('worker already stoped');
  }

  final imagePicker = ImagePickerService();

  Future<Uint8List?> compilePDF(Map<String, dynamic> form, [Uint8List? idCard]) async {
    try {
      final ttf = await rootBundle.load("fonts/calibri.ttf");
      final ttfBold = await rootBundle.load("fonts/calibri-bold.ttf");
      final ttfItalic = await rootBundle.load("fonts/calibri-italic.ttf");

      form['mulai'] = '${form['mulai']}'.toDateTime() == null ? null : DateFormat('d MMMM yyyy', 'id_ID').format('${form['mulai']}'.toDateTime()!);
      form['akhir'] = '${form['akhir']}'.toDateTime() == null ? null : DateFormat('d MMMM yyyy', 'id_ID').format('${form['akhir']}'.toDateTime()!);

      final params = {
        'ttf': ttf,
        'ttfBold': ttfBold,
        'ttfItalic': ttfItalic,
        'idCard' : idCard,
        ...form
      };

      final compiled = await _pdfWorker.compute(params);

      return compiled;
      }
    catch (e) {
      alertDialog('Errr', '$e');
      print('(PeminjamanPeralatanService.compilePDF) $e');
    }
    return null;
  }

  Future<bool> submitForm(Map<String, dynamic> form) async {
    try {
      await auth.supabase
        .from('peminjaman_peralatan')
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

class SuratKeteranganPraktikumService {
  final imagePicker = ImagePickerService();

  Future<String?> uploadImage(XFile bukti) async {
    try {
      final path = '${now.millisecondsSinceEpoch}-${bukti.name}';
      await auth.supabase.storage
        .from('uploads')
        .uploadBinary(path, await bukti.readAsBytes());
      return path;
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

class AdminPeminjamanPeralatanService {
  final QFSP = QFSPService();

  Future<List<PeminjamanPeralatanModel>?> getAllSubmissions() async {
    try {
      final data = await auth.supabase
        .from('peminjaman_peralatan')
        .select();
      var res = <PeminjamanPeralatanModel>[];
      data.forEach((item) => res.add(PeminjamanPeralatanModel.fromJson(item)));
      return res;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }

  Future<List<PeminjamanPeralatanModel>?> updateStatus(List<int> ids, String status) async {
    try {
      final res = await auth.supabase
        .from('peminjaman_peralatan')
        .update({'status' : status})
        .inFilter('id', ids)
        .select();
      return res.map((e) => PeminjamanPeralatanModel.fromJson(e)).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }
}

class AdminSuratKeteranganPraktikumService extends PDFService {
  final QFSP = QFSPService();

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

  final IsolateManager<Uint8List, dynamic> _pdfWorker = IsolateManager.create(
    suratKeteranganPraktikumCompilePdfWorker,
    workerName: 'suratKeteranganPraktikumCompilePdfWorker',
  );

  void initWorker() async {
    if (!_pdfWorker.isStarted) {
      print('worker started');
      await _pdfWorker.start();
    } else print('worker already started');
  }
  void closeWorker() async {
    if (_pdfWorker.isStarted) {
      print('worker stoped');
      await _pdfWorker.stop();
    } else print('worker already stoped');
  }

  Future<List<SuratKeteranganPraktikumModel>?> updateStatus(List<int> ids, String status) async {
    try {
      final res = await auth.supabase
        .from('surat_keterangan_praktikum')
        .update({'status' : status})
        .inFilter('id', ids)
        .select();
      return res.map((e) => SuratKeteranganPraktikumModel.fromJson(e)).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }

  Future<Uint8List?> compilePDF(SuratKeteranganPraktikumModel data) async {
    try {
      final ttf = await rootBundle.load("fonts/tahoma.ttf");
      final fontBytes = ttf.buffer.asUint8List();

      final today = DateFormat('d MMMM yyyy', 'id_ID').format(now);
      final timeStart = data.timeStart.toFormatedString();
      final timeEnd = data.timeEnd.toFormatedString();
      final nama = data.nama;
      final nim = data.nim;
      final matkul = data.matkul;
      final praktikum = data.praktikum;
      final modul = data.modul;
      final date = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(data.date);

      final buktiBytes = await auth.supabase
        .storage
        .from('uploads')
        .download(data.bukti);

      final headerBytes = await bytesImage('assets/Header ITB STEI.png');
      final footerBytes = await bytesImage('assets/Footer ITB STEI.png');

      final Map<String, dynamic> params = {
        'fontBytes': fontBytes,
        'headerBytes': headerBytes,
        'footerBytes': footerBytes,
        'buktiBytes': buktiBytes,
        'today': today,
        'timeStart': timeStart,
        'timeEnd': timeEnd,
        'matkul': data.matkul,
        'praktikum': data.praktikum,
        'modul': data.modul,
        'date': date,
        'nama': data.nama,
        'nim': data.nim,
      };

      final compiled = await _pdfWorker.compute(params);
      return compiled;
    }
    catch (e) {
      alertDialog('Errr', '$e');
      print('(SuratKeteranganPraktikum.compilePDF) $e');
    }
    return null;
  }
}