import 'dart:async';

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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

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
  static Future<DateTime?> selectDate({DateTime? initial, DateTime? first, DateTime? last, String? helpText}) async {
    final DateTime? picked = await showDatePicker(
      context: currentContext!,
      initialDate: initial,
      firstDate: first ?? now.subtract(Duration(days: 365)),
      lastDate: last ?? now.add(Duration(days: 365)),
      helpText: helpText,
    );

    return picked;
  }

  static Future<TimeOfDay?> selectTime({TimeOfDay? initial, String? helpText}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: currentContext!,
      initialTime: initial ?? TimeOfDay(hour: 0, minute: 0),
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
    item: [],
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
    await box.compact();

    NC.lastSync.value = cached.lastSync;
  }

  Future<void> save() async {
    await box.clear();
    await box.put('cached_storage', cached);
  }

  Future<void> sync([bool force = false]) async {
    NC.isSyncing.value = true;

    final lastSync = cached.lastSync;
    GlobalConfigModel? global;
    List<FakultasModel>? latest;
    List<ItemModel>? item;

    if (lastSync == null || force) {
      (global, latest, item) = await getLatestFieldData();
    } else {
      final lastUpdated = await getFieldLastUpdated();
      if (lastUpdated != null) {
        final outdated = lastUpdated.where((v) => v.timestamp.isAfter(lastSync) || (v.field == null && !storage.cached.formatedProgramStudi().contains(v.reference))).toList();
        if (outdated.isNotEmpty) {
          print('outdated field : ${outdated.map((v) => v.field ?? v.reference)}');
          (global, latest, item) = await getLatestFieldData(outdated);
        }
        final list = outdated.any((v) => v.field == 'fakultas') ? latest?.map((v) => v.name).toList() : null;
        removeUnregisteredField(lastUpdated, list);
      }
    }
    
    if (latest != null || global != null || item != null) {
      await updateOutdatedField(latest);
      await updateGlobalConfig(global);
      await updateItem(item);
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
      alertDialog('PostgrestException', '(getFieldLastUpdated) PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '(getFieldLastUpdated) $error');
    }
    return null;
  }

  void removeUnregisteredField(List<LastUpdatedModel> list, [List<String>? fakultas]) {
    for (final f in storage.cached.fakultas.toList()) {
      f.programStudi.removeWhere((ps) {
        final isNotRegistered = !list.any((v) => v.reference == ps.name);
        if (isNotRegistered) print('removed program studi : ${ps.name}');
        return isNotRegistered;
      });
      final i = storage.cached.fakultas.indexWhere((v) => v.name == f.name);
      if (fakultas?.contains(f.name) == false) {
        print("remove fakultas ${f.name}");
        storage.cached.fakultas.removeAt(i);
      } else {
        storage.cached.fakultas[i] = f;
      }
    }
  }

  Future<(GlobalConfigModel?, List<FakultasModel>?, List<ItemModel>?)> getLatestFieldData([List<LastUpdatedModel>? outdated]) async {
    final outdatedField = outdated?.where((v) => v.field != null && v.reference == null);
    final outdatedProdi = outdated?.where((v) => v.reference != null && v.field == null);
    
    final includeGlobal = outdatedField?.any((v) => v.field == 'global') ?? true;
    final includeFakultas = outdatedField?.any((v) => v.field == 'fakultas') ?? true;
    final includeItem = outdatedField?.any((v) => v.field == 'item') ?? true;
    final includeProdi = (outdatedProdi?.isNotEmpty ?? true) || includeFakultas;

    GlobalConfigModel? g;
    List<FakultasModel>? f;
    List<ItemModel>? i;
    
    try {
      var query = auth.supabase
        .from('global')
        .select([
            if (includeGlobal) '*',
            if (includeProdi)'''fakultas (
              *,
              program_studi ${includeFakultas ? '' : '!inner'} (
                id, created_at, name,
                mata_kuliah (*)
              )
            )''',
          if (includeItem) 'item (*)'
        ].join(','))
        .eq('id', 1);

      final fakultas = storage.cached.formatedFakultas();
      if (includeFakultas && fakultas.isNotEmpty) {
        final filter = fakultas.map((v) => 'name.neq."${v.replaceAll('"', '""')}"').join(',');
        query = query.or(filter, referencedTable: 'fakultas');
        print('fakultas filter : $filter');
      }

      if (outdatedProdi?.isNotEmpty ?? false) {
        final filter = outdatedProdi!.map((v) => 'name.eq."${v.reference?.replaceAll('"', '""')}"').join(',');
        query = query.or(filter, referencedTable: 'fakultas.program_studi');
        print('query filter : $filter');
      }
      
      final data = await query.single();

      print('fetched global config : $data');

      try { if (includeGlobal) g = GlobalConfigModel.fromJson(data); } 
      catch (e) { alertDialog('Unexpected error', '(getLatestGlobalConfig: global) $e'); }
      try { if (includeProdi) f = List.from(data['fakultas']).map((v) => FakultasModel.fromJson(v)).toList(); } 
      catch (e) { alertDialog('Unexpected error', '(getLatestGlobalConfig: fakultas) $e'); }
      try { if (includeItem) i = List.from(data['item']).map((v) => ItemModel.fromJson(v)).toList(); } 
      catch (e) { alertDialog('Unexpected error', '(getLatestGlobalConfig: item) $e'); }
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', '(getLatestGlobalConfig) PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '(getLatestGlobalConfig) $error');
    }
    return (g, f, i);
  }

  Future<void> updateOutdatedField(List<FakultasModel>? latestList) async {
    if (latestList == null) return;
    for (final lf in latestList) {
      final tempf = cached.fakultas.firstWhereOrNull((v) => v.name == lf.name);
      if (tempf != null) {
        if (lf.programStudi.isEmpty) continue;
        for (final lps in lf.programStudi) {
          final tempps = tempf.programStudi.firstWhereOrNull((v) => v.name == lps.name);
          if (tempps != null) {
            final i = tempf.programStudi.indexWhere((v) => v.name == lps.name);
            tempf.programStudi[i] = lps;
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

  Future<void> updateItem(List<ItemModel>? item) async {
    if (item == null) return;
    cached.item = item;
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
}

class AuthService {
  SupabaseClient get supabase => Supabase.instance.client;

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
    supabase.auth.onAuthStateChange.listen((data) async {
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

  Future<void> verify() async {
    if (!auth.isLoggedIn) return;
    try {
      await Supabase.instance.client.auth.getUser();
    } catch (e) {
      snackbar('Unauthorized!', 'Invalid token, please re-login.');
      await auth.supabase.auth.signOut();
    }
  }
}

class QFSPService {
  void updateButton(QFSPController c, String filterKey, String itemkey) {
    final filter = c.getFilterEnrty(filterKey);
    if (c.filter.firstWhere((v) => v.filterKey == filterKey).multiSelect) {
      filter[itemkey] = !filter[itemkey]!;
      filter['all'] = false;
      if (itemkey == 'all') {
        filter.updateAll((k,v) => false);
      }
    } else {
      filter.updateAll((k,v) => false);
      filter[itemkey] = true;
    }
    if (filter.values.every((v) => v == false)) filter['all'] = true;
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
      if (!item.filterEntry['all']!) {
        final List<T> temp = [];
        item.filterEntry.forEach((key, value) {
          if (value) temp.addAll(entries.where((v) => item.reference(v) == key));
        });
        entries = temp;
      }
    }
    return entries.toSet().toList();
  }

  List<T> sort<T>(List<T> raw, QFSPController c) {
    final temp = raw.cast<dynamic>();
    1.compareTo(2);
    switch (c.sortController.value) {
      case 'Latest': temp.sort((a, b) => (a.id < 0 && b.id >= 0) ? -1 : (b.id < 0 && a.id >= 0) ? 1 : b.id.compareTo(a.id)); break;
      case 'Oldest': temp.sort((a, b) => (a.id < 0 && b.id >= 0) ? 1 : (b.id < 0 && a.id >= 0) ? -1 : a.id.compareTo(b.id)); break;
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
    return filter.firstWhere((v) => v.filterKey == key).filterEntry;
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
      name: "${file.name.substring(7)}",
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
      final ttf = (await rootBundle.load("fonts/calibri.ttf")).buffer.asUint8List();
      final ttfBold = (await rootBundle.load("fonts/calibri-bold.ttf")).buffer.asUint8List();
      final ttfItalic = (await rootBundle.load("fonts/calibri-italic.ttf")).buffer.asUint8List();

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


class IzinTidakPraktikumService {
  final imagePicker = ImagePickerService();

  Future<String?> uploadImage(XFile image) async {
    final url = Uri.parse('https://proxy.corsfix.com/?' 'https://catbox.moe/user/api.php');
  
    try {
      final request = http.MultipartRequest('POST', url);

      request.fields['reqtype'] = 'fileupload';

      request.files.add(
        http.MultipartFile.fromBytes(
          'fileToUpload',
          await image.readAsBytes(),
          filename: '${now.millisecondsSinceEpoch}-${image.name}',
        )
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        return response.body.trim();
      } else {
        throw('Upload failed with status: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (error) {
      print(error);
      alertDialog('Unexpected error', '$error');
    }
    return null;
  }
}

class AdminPeminjamanPeralatanService {
  final QFSP = QFSPService();

  Future<List<PeminjamanPeralatanModel>?> getAllSubmissions() async {
    try {
      final data = await auth.supabase
        .from('peminjaman_peralatan')
        .select();
      return data.map(PeminjamanPeralatanModel.fromJson).toList();
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
      final ttf = (await rootBundle.load("fonts/tahoma.ttf")).buffer.asUint8List();

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
        'ttf': ttf,
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
        'nomor_surat' : storage.cached.globalConfig.nomorSurat,
        'nama_kepala_ldte' : storage.cached.globalConfig.namaKepalaLDTE,
        'nip_kepala_ldte' : storage.cached.globalConfig.nipKepalaLDTE,
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
  
  final qfsp = QFSPService();

  Future<List<T>?> upsertData<T>(List<Map<String, dynamic>> form) async {
    try {
      final res = await auth.supabase
        .from(T == FakultasModel ? 'fakultas' : T == ProgramStudiModel ? 'program_studi' : T == MatprakModel ? 'mata_kuliah' : 'item')
        .upsert(form, onConflict: 'id')
        .select();
      return res.map((json) => (T == FakultasModel ? FakultasModel.fromJson(json) : T == ProgramStudiModel ? ProgramStudiModel.fromJson(json) : T == MatprakModel ? MatprakModel.fromJson(json) : ItemModel.fromJson(json)) as T).toList();
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error ($T)', '$error');
    }
    return null;
  }

  Future<bool> deleteData<T>(List<T> model) async {
    try {
      // if (T == ProgramStudiModel) {
      //   await auth.supabase
      //     .from('last_updated')
      //     .delete()
      //     .inFilter('field', model.map((dynamic v) => v.name).toList());
      // }
      await auth.supabase
        .from(T == FakultasModel ? 'fakultas' : T == ProgramStudiModel ? 'program_studi' : 'mata_kuliah')
        .delete()
        .inFilter('id', model.map((dynamic v) => v.id).toList());
      return true;
    } on PostgrestException catch (error) {
      alertDialog('PostgrestException', 'PostgreSQL Error Code: ${error.code}\nError Message: ${error.message}\nHint from DB: ${error.hint}');
    } catch (error) {
      alertDialog('Unexpected error', '$error');
    }
    return false;
  }
}