import 'dart:async';
import 'dart:typed_data';

import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:eform_ldte/hive/hive_registrar.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/core/pdf_worker.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:eform_ldte/core/download/save_pdf.dart';
import 'package:eform_ldte/core/model.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/misc/extension.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  

  void preview(Uint8List savedFile, String fileName, [Function(VoidCallback) customCallback = f, RxBool? isLoadingRx]) async {
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
              constraints: BoxConstraints(maxHeight: Get.height / 1.24),
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
              child: Obx(() { 
                final isLoading = isLoadingRx?.value == true || NC.isSyncing.value;
                return Row(
                  spacing: 8,
                  children: [
                    Expanded(child: ElevatedButton.icon(
                      onPressed: isLoading ? null : () => customCallback(() => printPdf(savedFile, fileName)), 
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B2E3C)),
                      label: Text(isLoading ? NC.isSyncing.value ? 'Syncing...' : 'Loading...' : 'Print'),
                      icon: isLoading ? null : Icon(Icons.print_rounded),
                    )),
                    Expanded(child: ElevatedButton.icon(
                      onPressed: isLoading ? null : () => customCallback(() => downloadPdf(savedFile, fileName)),
                      style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.tertiary),
                      label: Text(isLoading ? 'Please wait' : 'Download'), 
                      icon: isLoading ? null : Icon(Icons.download_rounded),
                   )),
                  ],
                );
              }),
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
  late Box<StorageCacheModel> box;
  StorageCacheModel cached = StorageCacheModel(
    globalConfig: GlobalConfigModel(),
    fakultas: [],
    lastSync: null,
    userPreference: UserPreferenceModel()
  );
  
  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapters();

    try {
      box = await Hive.openBox<StorageCacheModel>('local');
      cached = box.get('cached_storage') ?? cached;
    } catch (e) {
      await Hive.deleteBoxFromDisk('local');
      box = await Hive.openBox<StorageCacheModel>('local');
    }

    NC.lastSync.value = cached.lastSync;
    await sync();
  }

  Future<void> save() async {
    await box.put('cached_storage', cached);
  }

  Future<void> sync([bool force = false]) async {
    NC.isSyncing.value = true;

    final lastSync = cached.lastSync;
    List<FakultasModel>? latest;
    GlobalConfigModel? global;

    if (lastSync == null || force) {
      latest = await getLatestFieldData();
      global = await getLatestGlobalConfig();
    } else {
      final lastUpdated = await getFieldLastUpdated();
      if (lastUpdated != null) {
        final outdated = lastUpdated.where((v) => v.timestamp.isAfter(lastSync) || (v.field != null && !storage.cached.formatedProgramStudi().contains(v.field))).toList();
        if (outdated.isNotEmpty) {
          print('outdated field : ${outdated.map((v) => v.field ?? "Global Config")}');
          if (outdated.any((v) => v.field == null)) {
            outdated.removeWhere((v) => v.field == null);
            global = await getLatestGlobalConfig();
          }
          if (outdated.isNotEmpty) latest = await getLatestFieldData(outdated);
        }
        removeUnregisteredField(lastUpdated);
      }
    }
    
    if (latest != null || global != null) {
      await updateOutdatedField(latest);
      await updateGlobalConfig(global);
      NC.lastSync.value = cached.lastSync = now.add(Duration(seconds: 1));
      print('device synced at : ${cached.lastSync}');
    }

    await save();
    NC.isSyncing.value = false;
  }

  Future<List<LastUpdatedModel>?> getFieldLastUpdated() async {
    try {
      final data = await auth.supabase
        .from('last_updated') 
        .select();

      return data.map((v) => LastUpdatedModel.fromJson(v)).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', '(getOutdatedField) PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '(getOutdatedField) $error');
    }
    return null;
  }

  void removeUnregisteredField(List<LastUpdatedModel> list) {
    for (final f in storage.cached.fakultas) {
      f.programStudi.removeWhere((ps) {
        final isNotRegistered = !list.any((v) => v.field == ps.name);
        if (isNotRegistered) print('removed program studi : ${ps.name}');
        return isNotRegistered;
      });
      final i = storage.cached.fakultas.indexWhere((v) => v.name == f.name);
      if (f.programStudi.isEmpty) storage.cached.fakultas.removeAt(i);
      else storage.cached.fakultas[i] = f;
    }
  }

  Future<Uri?> getLineOALDTEUrl([String? message]) async {
    final lineID = storage.cached.globalConfig.lineOALDTE;
    if (lineID == null) return null;
    return Uri(
      scheme: 'https',
      host: 'line.me',
      path: 'R/oaMessage/@$lineID',
      query: message == null ? null :Uri.encodeComponent(message)
    );
  }

  Future<List<FakultasModel>?> getLatestFieldData([List<LastUpdatedModel>? outdated]) async {
    try {
      var query = auth.supabase
        .from('fakultas')
        .select('''
          *, 
          program_studi !inner (
            id, created_at, name,
            mata_kuliah (*)
          )
        ''');

      if (outdated != null) {
        String filter = '';
        outdated.forEach((v) => filter = '$filter,name.eq."${v.field?.replaceAll('"', '""')}"');
        filter = filter.substring(1);
        query = query.or(filter, referencedTable: 'program_studi');
        print('query filter : $filter');
      }

      final data = await query;
      print('outdated field data : $data');

      List<FakultasModel> list = [];
      for (final v in data) {
        final temp = FakultasModel.fromJson(v);
        if (temp.programStudi.isNotEmpty) list.add(temp);
      }
      
      return list;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', '(getLatestFieldData) PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '(getLatestFieldData) $error');
    }
    return null;
  }

  Future<void> updateOutdatedField(List<FakultasModel>? latestList) async {
    if (latestList == null) return;
    for (final lf in latestList) {
      final tempf = cached.fakultas.where((v) => v.name == lf.name).firstOrNull;
      if (tempf != null) {
        for (final lps in lf.programStudi) {
          final tempps = tempf.programStudi.where((v) => v.name == lps.name).firstOrNull;
          if (tempps != null) {
            final i = tempf.programStudi.indexWhere((v) => v.name == lps.name);
            tempf.programStudi[i] = tempps;
            print('update program studi : ${lps.name}');
          } else {
            tempf.programStudi.add(lps);
            print('added new program studi : ${lps.name}');
          }
        }
        final i = cached.fakultas.indexWhere((v) => v.name == lf.name);
        cached.fakultas[i] = tempf;
        print('update fakultas : ${lf.name}');
      } else {
        cached.fakultas.add(lf);
        print('added new fakultas : ${lf.name}');
      }
    }
  }

  Future<void> updateGlobalConfig(GlobalConfigModel? global) async {
    if (global == null) return;
    cached.globalConfig = global;
  }

  Future<GlobalConfigModel?> getLatestGlobalConfig() async {
    try {
      final data = await auth.supabase
        .from('global')
        .select()
        .eq('id', 1)
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
  
  void updateButton(QFSPController c, String filterKey, String itemkey) {
    final filter = c.getFilterEnrty(filterKey);
    if (c.filter.where((v) => v.filterKey == filterKey).first.multiSelect) {
      filter.value[itemkey] = !filter.value[itemkey]!;
      filter.value['all'] = false;
      if (itemkey == 'all') {
        filter.value.updateAll((k,v) => false);
      }
    } else {
      filter.value.updateAll((k,v) => false);
      filter.value[itemkey] = true;
    }
    if (filter.value.values.every((v) => v == false)) filter.value['all'] = true;
    filter.refresh();
  }

  List<T> query<T>(List<T> raw, QFSPController c, List<String?> Function(T) match) {
    return raw.where((item) => match(item).any((text) => text == null ? false : text.toLowerCase().contains(c.queryController.text.toLowerCase().trim()))).toList();
  }

  List<T> filter<T>(List<T> raw, QFSPController<T> c, [String? itemKey, String? filterKey, List<DateTime?>? date, DateTime? Function(T)? dateAttribure]) {
    if (itemKey != null && filterKey != null) updateButton(c, filterKey, itemKey);
    var entries = raw;
    if (date?.every((d) => d != null) == true && dateAttribure != null) {
      entries = entries.where((e) => dateAttribure(e) == null ? false : dateAttribure(e)!.isAfter(date![0]!) && dateAttribure(e)!.isBefore(date[1]!)).toList();
    }
    for (var item in c.filter) {
      if (!item.filterEntry.value['all']!) {
        final List<T> temp = [];
        item.filterEntry.value.forEach((key, value) {
          if (value) temp.addAll(entries.where((v) => item.reference(v) == key));
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

class QFSPController<T> {
  QFSPController({
    this.filter = const [],
    required this.onChanged,
    required this.pageC,
    this.dataPerPage = 25,
  });

  final List<FilterController<T>> filter;
  final Function onChanged;
  final NumberPaginatorController pageC;
  final int dataPerPage;

  var queryController = TextEditingController();
  var sortController = SingleSelectController<String>('Latest');

  RxMap<String, bool> getFilterEnrty(String key) {
    return filter.where((v) => v.filterKey == key).toList().first.filterEntry;
  }
}

class FilterController<T> {
  String filterKey;
  List<String> filterList;
  String? Function(T) reference;
  bool multiSelect;
  
  FilterController({
    required this.filterKey,
    required this.filterList,
    required this.reference,
    this.multiSelect = true
  });

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
    }
  }
  void closeWorker() async {
    if (_pdfWorker.isStarted) {
      await _pdfWorker.stop();
    }
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

  Future<PeminjamanPeralatanModel?> updateFormData(int id, Map<String, dynamic> form) async {
    try {
      final res = await auth.supabase
        .from('peminjaman_peralatan')
        .update(form)
        .eq('id', id)
        .select()
        .single();
      return PeminjamanPeralatanModel.fromJson(res);
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

  Future<SuratKeteranganPraktikumModel?> updateFormData(int id, Map<String, dynamic> form) async {
    try {
      final res = await auth.supabase
        .from('surat_keterangan_praktikum')
        .update(form)
        .eq('id', id)
        .select()
        .single();
      return SuratKeteranganPraktikumModel.fromJson(res);
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }
}

class GlobalConfigService {
  Future<bool> updateGlobalConfig(Map<String, dynamic> form) async {
    try {
      await auth.supabase
        .from('global')
        .update(form)
        .eq('id', 1);

      return true;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return false;
  }
}

class FakultasService {
  final QFSP = QFSPService();

  Future<List<FakultasModel>?> insertData(List<Map<String, dynamic>> form) async {
    try {
      final res = await auth.supabase
        .from('fakultas')
        .insert(form);
      return res.map((v) => FakultasModel.fromJson(v)).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }

  Future<List<FakultasModel>?> updateData(List<Map<String, dynamic>> form) async {
    try {
      final res = await auth.supabase
        .from('fakultas')
        .upsert(form)
        .select();
      return res.map((v) => FakultasModel.fromJson(v)).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }

  Future<bool> deleteData(List<int> ids) async {
    try {
      await auth.supabase
        .from('fakultas')
        .delete()
        .inFilter('id', ids);
      return true;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return false;
  }
}

class ProgramStudiService {
  final QFSP = QFSPService();

  Future<List<ProgramStudiModel>?> insertData(List<Map<String, dynamic>> form) async {
    try {
      final res = await auth.supabase
        .from('program_studi')
        .insert(form);
      return res.map((v) => ProgramStudiModel.fromJson(v)).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }

  Future<List<ProgramStudiModel>?> updateData(List<Map<String, dynamic>> form) async {
    try {
      final res = await auth.supabase
        .from('program_studi')
        .upsert(form)
        .select();
      return res.map((v) => ProgramStudiModel.fromJson(v)).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }

  Future<bool> deleteData(List<int> ids) async {
    try {
      await auth.supabase
        .from('program_studi')
        .delete()
        .inFilter('id', ids);
      return true;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return false;
  }
}

class MataKuliahPraktikumService {
  final QFSP = QFSPService();

  Future<List<MataKuliahPraktikumModel>?> insertData(List<Map<String, dynamic>> form) async {
    try {
      final res = await auth.supabase
        .from('mata_kuliah')
        .insert(form);
      return res.map((v) => MataKuliahPraktikumModel.fromJson(v)).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }

  Future<List<MataKuliahPraktikumModel>?> updateData(List<Map<String, dynamic>> form) async {
    try {
      final res = await auth.supabase
        .from('mata_kuliah')
        .upsert(form)
        .select();
      return res.map((v) => MataKuliahPraktikumModel.fromJson(v)).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }

  Future<bool> deleteData(List<int> ids) async {
    try {
      await auth.supabase
        .from('mata_kuliah')
        .delete()
        .inFilter('id', ids);
      return true;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return false;
  }
}