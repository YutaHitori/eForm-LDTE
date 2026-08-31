import 'package:eform_ldte/misc/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eform_ldte/core/model.dart';
import 'package:eform_ldte/core/service.dart';
import 'package:eform_ldte/homepage/admin.dart';
import 'package:eform_ldte/homepage/homepage.dart';
import 'package:eform_ldte/homepage/login.dart';
import 'package:eform_ldte/misc/extension.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import "package:universal_html/universal_html.dart" as html;

bool get canPop => Get.key.currentState?.canPop() ?? false;

class PermissionController {
  static d(){}

  Future<bool> requestCameraPermission({VoidCallback onGranted = d, VoidCallback onDenied = d, VoidCallback onPermanentlyDeniedGranted = d}) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      onGranted();
      return true;
    } else if (status.isDenied) {
      onDenied();
    } else if (status.isPermanentlyDenied) {
      if (kIsWeb) return false;
      onDenied();
      alertDialog(
        'Permission Request', 'Allow our app to Open Camera',
        confirmAction: () async {
          if(await openAppSettings()) {
            late final AppLifecycleListener listen;
            listen = AppLifecycleListener(onResume: () async {
              listen.dispose();
              if (await Permission.camera.isGranted) {
                currentContext?.pop();
                onPermanentlyDeniedGranted();
              }
            });
          } else {
            snackbar('Error', 'Unnable to open Settings');
          }
        },
        confirmText: 'Open Settings',
      );
    }
    return false;
  }
}

class NavigationController extends GetxController {
  var isSyncing = true.obs;
  var lastSync = Rxn<DateTime>(null);
  var buildVersion = ''.obs;
  var isLoggedIn = auth.isLoggedIn.obs;

  final Map<String, String> title = {
    '/': 'Homepage',
    '/login': 'Login',
    '/admin': 'Admin',
  };

  final Map<String, Widget> pages = {
    '/': Homepage(),
    '/login': Login(),
    '/admin': Admin(),
  };

  @override
  void onInit() async {
    super.onInit();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    buildVersion.value = 'App Version ${packageInfo.version} Build ${packageInfo.buildNumber}';
  }

  void navigateToPage(String route, [BuildContext? context]) {
    if (route == NamedRoute.login) {
      if (Get.isRegistered<LoginController>()) Get.find<LoginController>().resetValue();
    }
    if (canPop && context != null) Navigator.pop(context);
    if (kIsWeb) html.window.history.pushState(null, '', route);
    currentPage.value = route;
  }
  
  var currentPage = RxnString(null);

  var constraints = Rx<BoxConstraints>(BoxConstraints());
}

class LoginController extends GetxController {
  var isLoading = false.obs;

  var isLoggedIn = auth.isLoggedIn;
  var email = TextEditingController();
  var password = TextEditingController();
  var emailE = Rxn<String>(null); 
  var passwordE = Rxn<String>(null);  
  var isObscured = true.obs;

  void resetValue() {
    email.text = '';
    password.text = '';
    emailE.value = null;
    passwordE.value = null;
  }

  void signInWithPassword() async {
    if (email.text.isBlank() || password.text.isBlank()) {
      emailE.value = email.text.isBlank() ? '*required' : null;
      passwordE.value = password.text.isBlank() ? '*required' : null;
      return;
    }
    emailE.value = passwordE.value = null;
    isLoading.value = true;
    if (!await auth.signInWithPassword(email.text, password.text)) {
      passwordE.value = '';
      password.clear();
    }
    isLoading.value = false;
  }
}

class PeminjamanPeralatanController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    namaF.addListener(() {
      if (!namaF.hasFocus) namaC.text = namaC.text.trim().capitalCase(false);
    });
    nimF.addListener(() {
      if (!nimF.hasFocus) nimC.text = nimC.text.trim();
    });
    dosenF.addListener(() {
      if (!dosenF.hasFocus) dosenC.text = dosenC.text.trim().capitalCase();
    });
    nipDosenF.addListener(() {
      if (!nipDosenF.hasFocus) nipDosenC.text = nipDosenC.text.trim();
    });
    ketuaF.addListener(() {
      if (!ketuaF.hasFocus) ketuaC.text = ketuaC.text.trim().capitalCase();
    });
    nipKetuaF.addListener(() {
      if (!nipKetuaF.hasFocus) nipKetuaC.text = nipKetuaC.text.trim();
    });
    for (int i = 0; i < 4; i++) {
      barangF[i].addListener(() {
        if (!barangF[i].hasFocus) barangC[i].text = barangC[i].text.trim().capitalCase();
      });
    }
    init();
  }

  void init() async {
    service.initWorker();
    await service.imagePicker.retrieveLostData(idCard, key: 'idCard');
    showReminderDialog();
  }

  @override
  void onClose() {
    service.closeWorker();
    super.onClose();
    for (int i = 0; i < 4; i++) {
      barangF[i].dispose();
    }
    namaF.dispose();
    nimF.dispose();
    dosenF.dispose();
    nipDosenF.dispose();
    ketuaF.dispose();
    nipKetuaF.dispose();
  }

  List<String> get items => storage.cached.formatedItem();

  final service = PeminjamanPeralatanService();
  var isLoading = false.obs;

  String get cara => storage.cached.globalConfig.caraPinjam ?? "Didn't exist, please refresh browser or contact our Line OA";
  List<String> get fakultasList => storage.cached.formatedFakultas();

  var idCard = Rxn<XFile>(null); 

  final namaC = TextEditingController();
  final nimC = TextEditingController();
  final fakultasC = SingleSelectController<String>(null);
  final prodiC = SingleSelectController<String>(null);
  final dosenC = TextEditingController();
  final nipDosenC = TextEditingController();
  final ketuaC = TextEditingController();
  final nipKetuaC = TextEditingController();
  var itemN = 1.obs;
  final barangC = List.generate(4, (i) => TextEditingController());
  final barangDC = List.generate(4, (i) => SingleSelectController<String>('custom'));
  final banyakC = List.generate(4, (i) => SingleSelectController<int>(null));
  final mulaiC = TextEditingController();
  final akhirC = TextEditingController();

  final namaF = FocusNode();
  final nimF = FocusNode();
  final dosenF = FocusNode();
  final nipDosenF = FocusNode();
  final ketuaF = FocusNode();
  final nipKetuaF = FocusNode();
  final barangF = List.generate(4, (i) => FocusNode());

  var enabled = true;

  void addItem() => itemN++;

  void removeItem(int index) {
    enabled = false;
    itemN--;
    while (index < itemN.value) {
      barangDC[index].value = barangDC[index + 1].value;
      barangC[index].text = barangC[index + 1].text;
      banyakC[index].value = banyakC[index + 1].value;
      barangE[index] = barangE[index + 1];
      banyakE[index] = banyakE[index + 1];
      index++;
    }
    barangDC[index].value = 'custom';
    barangC[index].clear();
    banyakC[index].clear();
    barangE[index] = null;
    banyakE[index] = null;
    enabled = true;
  } 


  void changeText(int index, String? value) {
    if (!enabled) return;
    var text = value;
    if (value == 'custom') text = null;
    barangC[index].text = text ?? '';
  }

  void selectIfExist(int index, String value) {
    if (!enabled) return;
    enabled = false;
    final contain = items.firstWhereOrNull((v) => v.toLowerCase() == value.trim().toLowerCase());
    barangDC[index].value = contain ?? 'custom';
    enabled = true;
  }

  Future<void> selectDateStart() async {
    final picked = await DateTimePickerService.selectDate(initial: mulaiC.text.toDateTime() ?? today, helpText: "Tanggal Peminjaman");
    if (picked != null) mulaiC.text = picked.toDateString();
  }

  Future<void> selectDateEnd() async {
    final picked = await DateTimePickerService.selectDate(initial: akhirC.text.toDateTime() ?? today, helpText: "Tanggal Pengembalian");
    if (picked != null) akhirC.text = picked.toDateString();
  }

  var prodiList = <String>[].obs;

  Map<String, dynamic> get dbform => {
    'nama' : namaC.text.trim().capitalCase(false),
    'nim' : nimC.text.trim(),
    'mulai' : mulaiC.text.trim(),
    'akhir' : akhirC.text.trim(),
    'barang' : List.generate(itemN.value, (i) => barangC[i].text.trim().capitalCase()),
    'banyak' : List.generate(itemN.value, (i) => banyakC[i].value),
  };

  Map<String, dynamic> get form => {
    ...dbform,
    if (fakultasC.hasValue) 'fakultas' : parentheses.firstMatch(fakultasC.value ?? '')?.group(1),
    if (prodiC.hasValue) 'prodi' : prodiC.value?.replaceAll(parentheses, '').trim(),
    if (!dosenC.text.isBlank()) 'dosen' : dosenC.text.trim().capitalCase(),
    if (!nipDosenC.text.isBlank()) 'nipDosen' : nipDosenC.text.trim(),
    if (!ketuaC.text.isBlank()) 'ketua' : ketuaC.text.trim().capitalCase(),
    if (!nipKetuaC.text.isBlank()) 'nipKetua' : nipKetuaC.text.trim(),
  };

  void selectImage() async {
    service.imagePicker.selectImage(idCard, key: 'idCard');
  }

  void previewImage() {
    service.imagePicker.previewImage(idCard.value!);
  }

  void resetImage() {
    service.imagePicker.resetImage(idCard, key: 'idCard');
  }
  
  void setProdi() {
    prodiC.value = null;
    prodiList.value = fakultasC.hasValue ? storage.cached.getFakultas(fakultasC.value!)?.formatedProgramStudi() ?? [] : [];
  }

  var namaE = Rxn<String>(null); 
  var nimE = Rxn<String>(null); 
  var mulaiE = Rxn<String>(null); 
  var akhirE = Rxn<String>(null); 
  var barangE = RxList<String?>([null, null, null, null]); 
  var banyakE = RxList<String?>([null, null, null, null]); 
  var idCardE = Rxn<String>(null); 

  bool checkEmptyFields([bool reqId = true]) {
    for (int i = 0; i < itemN.value; i++) {
      barangE[i] = barangC[i].text.isBlank() ? '*required' : null;
      banyakE[i] = !banyakC[i].hasValue ? '*required' : null;
    }

    namaE.value = namaC.text .isBlank() ? '*required' : null;
    nimE.value = nimC.text .isBlank() ? '*required' : null;
    final mulai = mulaiC.text.toDateTime();
    final akhir = akhirC.text.toDateTime();
    mulaiE.value = mulaiC.text.isBlank() ? '*required' : mulai == null ? '*invalid' : akhir != null && mulai.isAfter(akhir) ? '*melebihi tgl pengembalian' : null;
    akhirE.value = akhirC.text.isBlank() ? '*required' : akhir == null ? '*invalid' : mulai != null && akhir.isBefore(mulai) ? '*kurang dari tgl pinjam' : null;
    if (reqId) idCardE.value = idCard.value == null ? '*required' : null;
    
    return barangE.every((v) => v == null) && banyakE.every((v) => v == null) && namaE.value == null && nimE.value == null && mulaiE.value == null && akhirE.value == null && idCardE.value == null;
  }
  
  var lastForm = <String, dynamic>{};
  void submit() async {
    if (!checkEmptyFields()) return;
    final cdbform = dbform;
    isLoading.value = true;
    final savedFile = await service.compilePDF(form, await idCard.value?.readAsBytes());
    if (savedFile != null) {
      final fileName = "Formulir_Peminjaman-${DateTime.now().millisecondsSinceEpoch}.pdf";
      service.preview(savedFile, fileName, (f) async {
        if (cdbform.entries.every((e) => lastForm[e.key].toString() == e.value.toString())) {
          f();
          return;
        }
        isLoading.value = true;
        final isSuccess = await service.submitForm(cdbform);
        if (isSuccess) {
          lastForm = cdbform;
          f();
        }
        isLoading.value = false;
      }, isLoading);
    }
    isLoading.value = false;
  }

  void showReminderDialog() {
    var remindMe = storage.cached.userPreference.remindPeminjamanPeralatan.obs;
    if (remindMe.value) {
      alertDialog(
        'Cara Pengisian Formulir Peminjaman Peralatan:',
        null,
        message: Obx(() => Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(maxHeight: 152),
              decoration: BoxDecoration(
                color: appTheme.colorScheme.background,
                borderRadius: BorderRadius.circular(8)
              ),
              padding: const EdgeInsets.all(8),
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(4),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(NC.isSyncing.value ? 'Syncingin progress, please wait...' : cara, style: TextStyle(fontSize: 12.8)),
                  )
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Switch(value: remindMe.value, onChanged: NC.isSyncing.value ? null : (v) {
                  remindMe.value = v;
                  storage.cached.userPreference.remindPeminjamanPeralatan = v;
                  storage.save();
                })
              ],
            ),
          ],
        )),
        titleFontSize: 20,
      );
    }
  }
} 

class SusulanPraktikumController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    setModulList();
    namaF.addListener(() {
      if (!namaF.hasFocus) namaC.text = namaC.text.trim().capitalCase(false);
    });
    nimF.addListener(() {
      if (!nimF.hasFocus) nimC.text = nimC.text.trim();
    });
    dosenF.addListener(() {
      if (!dosenF.hasFocus) dosenC.text = dosenC.text.trim().capitalCase();
    });
    nipF.addListener(() {
      if (!nipF.hasFocus) nipC.text = nipC.text.trim();
    });
    namaPraktikumF.addListener(() {
      if (!namaPraktikumF.hasFocus) namaPraktikum.text = namaPraktikum.text.trim().capitalCase();
    });
    kodePraktikumF.addListener(() {
      if (!kodePraktikumF.hasFocus) kodePraktikum.text = kodePraktikum.text.trim().toUpperCase();
    });
    for (int i = 0; i < judulModulF.length; i++) {
      judulModulF[i].addListener(() {
        if (!judulModulF[i].hasFocus) judulModulC[i].text = judulModulC[i].text.trim().capitalCase();
      });
    }
    alasanF.addListener(() {
      if (!alasanF.hasFocus) alasanC.text = alasanC.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    });
    init();
  }

  void init() async {
    service.initWorker();
    showReminderDialog();
  }

  @override
  void onClose() {
    service.closeWorker();
    super.onClose();
    for (int i = 0; i < judulModulF.length; i++) {
      judulModulF[i].dispose();
    }
    namaF.dispose();
    nimF.dispose();
    dosenF.dispose();
    nipF.dispose();
    namaPraktikumF.dispose();
    kodePraktikumF.dispose();
    alasanF.dispose();
  }

  List<String> get items => storage.cached.formatedItem();

  final service = SusulanPraktikumService();
  var isLoading = false.obs;

  String get cara => storage.cached.globalConfig.caraSusulan ?? "Didn't exist, please refresh browser or contact our Line OA";
  List<String> get fakultasList => storage.cached.formatedFakultas();

  final namaC = TextEditingController();
  final nimC = TextEditingController();
  final prodiC = SingleSelectController<String>(null);
  final dosenC = TextEditingController();
  final nipC = TextEditingController();
  final alasanC = TextEditingController();
  var alasanN = 0.obs;
  var itemN = 1.obs;
  final judulModulC = List.generate(7, (i) => TextEditingController());
  final modulC = List.generate(7, (i) => SingleSelectController<int>(null));
  
  final praktikum = SingleSelectController<String>(null);
  var isPraktikumLainnya = false.obs;
  final kodePraktikum = TextEditingController();
  final namaPraktikum = TextEditingController();

  final namaF = FocusNode();
  final nimF = FocusNode();
  final dosenF = FocusNode();
  final nipF = FocusNode();
  final judulModulF = List.generate(7, (i) => FocusNode());
  final namaPraktikumF = FocusNode();
  final kodePraktikumF = FocusNode();
  final alasanF = FocusNode();

  var enabled = true;

  void addItem() => itemN++;

  void removeItem(int index) {
    enabled = false;
    itemN--;
    while (index < itemN.value) {
      judulModulC[index].text = judulModulC[index + 1].text;
      modulC[index].value = modulC[index + 1].value;
      modulE[index] = modulE[index + 1];
      judulModulE[index] = judulModulE[index + 1];
      index++;
    }
    modulE[index] = null;
    judulModulE[index] = null;
    judulModulC[index].clear();
    modulC[index].clear();
    enabled = true;
  } 

  void setPraktikumList() {
    praktikum.value = null;
    praktikumList.value = prodiC.hasValue ? storage.cached.getProgramStudi(prodiC.value!)?.formatedPraktikum() ?? [] : [];
  }

  List<String> get prodiList => storage.cached.getFakultas('(STEI)')?.formatedProgramStudi() ?? [];
  // List<String> get praktikumList => storage.cached.getFakultas('(STEI)')?.formatedPraktikum() ?? [];
  var praktikumList = <String>[].obs;
  var modulList = <int>[].obs;
  void setModulList() {
    modulList.value = List.generate(9, (i) => i + 1).toSet().difference(modulC.map((v) => v.value).where((v) => v != null).toSet()).toList();
  }

  Map<String, dynamic> get form => {
    'nama' : namaC.text.trim().capitalCase(false),
    'nim' : nimC.text.trim(),
    'dosen' : dosenC.text.trim().capitalCase(),
    'nip' : nipC.text.trim(),
    'prodi' : prodiC.value?.replaceAll(parentheses, '').trim(),
    'praktikum' : praktikum.value == 'Lainnya...' ? '${kodePraktikum.text.trim().toUpperCase()} ${namaPraktikum.text.trim().capitalCase()}' : praktikum.value,
    'modul' : List.generate(itemN.value, (i) => '${modulC[i].value} - ${judulModulC[i].text.trim().capitalCase()}'),
    'alasan' : alasanC.text.trim().replaceAll(RegExp(r'\s+'), ''),
  };

  var namaE = Rxn<String>(null); 
  var nimE = Rxn<String>(null); 
  var dosenE = Rxn<String>(null); 
  var nipE = Rxn<String>(null); 
  var prodiE = Rxn<String>(null); 
  var praktikumE = Rxn<String>(null); 
  var namaPraktikumE = Rxn<String>(null); 
  var kodePraktikumE = Rxn<String>(null); 
  var judulModulE = RxList<String?>([null, null, null, null, null, null, null]); 
  var modulE = RxList<String?>([null, null, null, null, null, null, null]); 
  var alasanE = Rxn<String>(null); 

  bool checkEmptyFields([bool reqId = true]) {
    for (int i = 0; i < itemN.value; i++) {
      judulModulE[i] = judulModulC[i].text.isBlank() ? '*required' : null;
      modulE[i] = !modulC[i].hasValue ? '*required' : null;
    }
    namaE.value = namaC.text.isBlank() ? '*required' : null;
    nimE.value = nimC.text.isBlank() ? '*required' : null;
    dosenE.value = dosenC.text.isBlank() ? '*required' : null;
    nipE.value = nipC.text.isBlank() ? '*required' : null;
    prodiE.value = !prodiC.hasValue ? '*required' : null;
    praktikumE.value = !praktikum.hasValue ? '*required' : null;
    namaPraktikumE.value = praktikum.value == 'Lainnya...' && namaPraktikum.text .isBlank() ? '' : null;
    kodePraktikumE.value = praktikum.value == 'Lainnya...' && kodePraktikum.text .isBlank() ? '' : null;
    alasanE.value = alasanC.text.isBlank() ? '*required' : alasanC.text.length > 500 ? '*character limit exceeded' : null;
    
    return judulModulE.every((v) => v == null) && modulE.every((v) => v == null) && namaE.value == null && nimE.value == null && dosenE.value == null && nipE.value == null && prodiE.value == null && alasanE.value == null && praktikumE.value == null && (praktikum.value != 'Lainnya...' || (namaPraktikumE.value == null && kodePraktikumE.value == null));
  }
  
  void submit() async {
    if (!checkEmptyFields()) return;
    isLoading.value = true;
    final savedFile = await service.compilePDF(form);
    if (savedFile != null) {
      final fileName = "Surat_Permohonan_Praktikum_Susulan-${DateTime.now().millisecondsSinceEpoch}.pdf";
      service.preview(savedFile, fileName);
    }
    isLoading.value = false;
  }

  void showReminderDialog() {
    var remindMe = storage.cached.userPreference.remindSusulanPraktikum.obs;
    if (remindMe.value) {
      alertDialog(
        'Cara Pengisian Template Permohonan Susulan:',
        null,
        message: Obx(() => Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(maxHeight: 152),
              decoration: BoxDecoration(
                color: appTheme.colorScheme.background,
                borderRadius: BorderRadius.circular(8)
              ),
              padding: const EdgeInsets.all(8),
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(4),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(NC.isSyncing.value ? 'Syncingin progress, please wait...' : cara, style: TextStyle(fontSize: 12.8)),
                  )
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Switch(value: remindMe.value, onChanged: NC.isSyncing.value ? null : (v) {
                  remindMe.value = v;
                  storage.cached.userPreference.remindSusulanPraktikum = v;
                  storage.save();
                })
              ],
            ),
          ],
        )),
        titleFontSize: 20,
      );
    }
  }
} 

class SuratKeteranganPraktikumController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    for (int i = 0; i < 4; i++) {
      namaF[i].addListener(() {
        if (!namaF[i].hasFocus) namaC[i].text = namaC[i].text.trim().capitalCase(false);
      });
    }
    namaMatkulF.addListener(() {
      if (!namaMatkulF.hasFocus) namaMatkul.text = namaMatkul.text.trim().capitalCase();
    });
    kodeMatkulF.addListener(() {
      if (!kodeMatkulF.hasFocus) kodeMatkul.text = kodeMatkul.text.trim().toUpperCase();
    });
    namaPraktikumF.addListener(() {
      if (!namaPraktikumF.hasFocus) namaPraktikum.text = namaPraktikum.text.trim().capitalCase();
    });
    kodePraktikumF.addListener(() {
      if (!kodePraktikumF.hasFocus) kodePraktikum.text = kodePraktikum.text.trim().toUpperCase();
    });
    init();
  }

  void init() async {
    await service.imagePicker.retrieveLostData(bukti, key: 'bukti');
    showReminderDialog();
  }

  @override
  void onClose() {
    super.onClose();
    for (int i = 0; i < 4; i++) {
      namaF[i].dispose();
    }
    namaMatkulF.dispose();
    kodeMatkulF.dispose();
    namaPraktikumF.dispose();
    kodePraktikumF.dispose();
  }

  var isLoading = false.obs;
  var message = RxnString(null);

  String get cara => storage.cached.globalConfig.caraKeterangan ?? "Didn't exist, please refresh browser or contact our Line OA";
  final service = SuratKeteranganPraktikumService();
  List<String> get matkulList => storage.cached.formatedMataKuliah();
  List<String> get praktikumList => storage.cached.formatedPraktikum();

  Future<void> selectDate() async {
    final picked = await DateTimePickerService.selectDate(initial: dateC.text.toDateTime() ?? today, helpText: "Tanggal Praktikum");
    if (picked != null) dateC.text = picked.toDateString();
  }

  Future<void> selectTimeStart() async {
    final picked = await DateTimePickerService.selectTime(initial: timeStartC.value, helpText: "Waktu Mulai Praktikum");
    if (picked != null) {
      timeStartC.value = picked;
    }
  }

  Future<void> selectTimeEnd() async {
    final picked = await DateTimePickerService.selectTime(initial: timeEndC.value, helpText: "Waktu Selesai Praktikum");
    if (picked != null) {
      timeEndC.value = picked;
    }
  }

  final namaC = List.generate(4, (i) => TextEditingController());
  final nimC = List.generate(4, (i) => TextEditingController());
  final matkul = SingleSelectController<String>(null);
  var isMatkulLainnya = false.obs;
  final kodeMatkul = TextEditingController();
  final namaMatkul = TextEditingController();
  final praktikum = SingleSelectController<String>(null);
  var isPraktikumLainnya = false.obs;
  final kodePraktikum = TextEditingController();
  final namaPraktikum = TextEditingController();
  final modul = SingleSelectController<int>(null);
  final dateC = TextEditingController();
  var timeStartC = Rxn<TimeOfDay>(null);
  var timeEndC = Rxn<TimeOfDay>(null);

  var namaE = RxList<String?>([null, null, null, null]); 
  var nimE = RxList<String?>([null, null, null, null]); 
  var matkulE = Rxn<String>(null); 
  var namaMatkulE = Rxn<String>(null); 
  var kodeMatkulE = Rxn<String>(null); 
  var praktikumE = Rxn<String>(null); 
  var namaPraktikumE = Rxn<String>(null); 
  var kodePraktikumE = Rxn<String>(null); 
  var modulE = Rxn<String>(null); 
  var dateE = Rxn<String>(null); 
  var timeStartE = Rxn<String>(null); 
  var timeEndE = Rxn<String>(null); 
  var buktiE = Rxn<String>(null); 

  final namaF = List.generate(4, (i) => FocusNode());
  final namaMatkulF = FocusNode();
  final kodeMatkulF = FocusNode();
  final namaPraktikumF = FocusNode();
  final kodePraktikumF = FocusNode();

  var prodiList = <String>[].obs;

  var itemN = 1.obs;

  void addItem() => itemN++;

  void removeItem(int index) {
    itemN--;
    while (index < itemN.value) {
      namaC[index].text = namaC[index + 1].text;
      nimC[index].text = nimC[index + 1].text;
      namaE[index] = namaE[index + 1];
      nimE[index] = nimE[index + 1];
      index++;
    }
    namaC[index].clear();
    nimC[index].clear();
    namaE[index] = null;
    nimE[index] = null;
  } 

  Rxn<XFile> bukti = Rxn<XFile>(null); 

  Map<String, dynamic> get form => {
    'nama' : List.generate(itemN.value, (i) => namaC[i].text.trim().capitalCase(false)),
    'nim' : List.generate(itemN.value, (i) => nimC[i].text.trim()),
    'matkul' : matkul.value == 'Lainnya...' ? '${kodeMatkul.text.trim().toUpperCase()} ${namaMatkul.text.trim().capitalCase()}' : matkul.value,
    'praktikum' : praktikum.value == 'Lainnya...' ? '${kodePraktikum.text.trim().toUpperCase()} ${namaPraktikum.text.trim().capitalCase()}' : praktikum.value,
    'modul' : modul.value!,
    'date' : dateC.text,
    'timeStart' : timeStartC.value!.toFormatedString(),
    'timeEnd' :  timeEndC.value!.toFormatedString(),
  };

  void selectImage() async {
    service.imagePicker.selectImage(bukti, key: 'bukti');
  }

  void previewImage() {
    service.imagePicker.previewImage(bukti.value!);
  }

  void resetImage() {
    service.imagePicker.resetImage(bukti, key: 'bukti');
  }

   bool checkEmptyFields([bool reqImage = true]) {
    for (int i = 0; i < itemN.value; i++) {
      namaE[i] = namaC[i].text.isBlank() ? '*required' : null;
      nimE[i] = nimC[i].text.isBlank() ? '*required' : null;
    }

    matkulE.value = !matkul.hasValue ? '*required' : null;
    namaMatkulE.value = matkul.value == 'Lainnya...' && namaMatkul.text .isBlank() ? '': null;
    kodeMatkulE.value = matkul.value == 'Lainnya...' && kodeMatkul.text .isBlank() ? '': null;
    praktikumE.value = !praktikum.hasValue ? '*required' : null;
    namaPraktikumE.value = praktikum.value == 'Lainnya...' && namaPraktikum.text .isBlank() ? '': null;
    kodePraktikumE.value = praktikum.value == 'Lainnya...' && kodePraktikum.text .isBlank() ? '': null;
    modulE.value = !modul.hasValue ? '' : null ;
    dateE.value = dateC.text.isBlank() ? '*required' : dateC.text.toDateTime() == null ? '*invalid' : null;
    final isInvalid = timeStartC.value != null && timeEndC.value != null && timeStartC.value!.isAfter(timeEndC.value!);
    timeStartE.value = timeStartC.value == null ? '*required' : isInvalid ? '*waktu mulai melebihi waktu selesai' : null;
    timeEndE.value = timeEndC.value == null ? '*required' : isInvalid ? '*waktu mulai melebihi waktu selesai' : null;
    if (reqImage) buktiE.value = bukti.value == null ? '*required' : null;

    if (namaE.any((v) => v != null) || nimE.any((v) => v != null) || 
      matkulE.value != null || namaMatkulE.value != null || kodeMatkulE.value != null || 
      praktikumE.value != null || namaPraktikumE.value != null || kodePraktikumE.value != null || 
      modulE.value != null || dateE.value != null || timeStartE.value != null || 
      timeEndE.value != null || (reqImage && buktiE.value != null)) return false;

    namaE.fillRange(0, namaE.length, null);
    nimE.fillRange(0, nimE.length, null);
    matkulE.value = namaMatkulE.value = kodeMatkulE.value = praktikumE.value = namaPraktikumE.value = kodePraktikumE.value = modulE.value = dateE.value = timeStartE.value = timeEndE.value = buktiE.value = null;
    return true;
  }

  void submit() async {
    if (!checkEmptyFields()) return;
    final uriMessage = "Saya telah mengirimkan formulir surat keterangan praktikum atas nama ${(form['nama'] as List<String>).join(', ')}: https://eform-ldte.vercel.app/admin/surat-keterangan";
    final uri = await storage.getLineOALDTEUrl(uriMessage);
    print(uri);
    if (uri != null) {
      isLoading.value = true;
      message.value = 'Uploading Image...';
      final url = await service.uploadImage(bukti.value!);
      if (url != null) {
        message.value = 'Inserting Data...';
        final isSuccess = await service.submitForm({ 'bukti': url, ...form }); 
        if (isSuccess) {
          Clipboard.setData(ClipboardData(text: uriMessage));
          Get.showSnackbar(GetSnackBar(message: 'Message copied to clipboard!', duration: Duration(seconds: 2)));
          message.value = 'Success!';
          alertDialog(
            'Form Submited!', null,
            width: 360,
            message: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Data telah berhasil direkam. Silahkan melapor ke admin melalui link berikut: ',
                      style: TextStyle(color: Colors.white)
                    ),
                    WidgetSpan(
                      child: Transform.translate(
                        offset: Offset(0, 2),
                        child: InkWell(
                          onTap: () async {
                            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                              alertDialog('Error!', 'Link tidak dapat dibuka, silahkan kirim pesan yang telah tersalin ke Line OA LDTE secara manual.');
                              Clipboard.setData(ClipboardData(text: uriMessage));
                            }
                          }, 
                          child: Text('OA Line LDTE', style: TextStyle(color: Colors.blue))
                        ),
                      ),
                    ),
                    TextSpan(
                      text: '.\n\nNote: Jika link tidak dapat dibuka, silahkan kirim pesan yang telah tersalin ke Line OA LDTE secara manual.',
                      style: TextStyle(color: Colors.white, fontSize: 12)
                    ),
                  ],
                ),
              ),
            ),
            dismissible: false,
            cancelText: 'Close Page',
            cancelAction: () => currentContext?.go(NamedRoute.homepage),
          );
          service.imagePicker.resetImage(bukti);
        } else {
          message.value = 'Failed (Retry)';
        }
      } else {
        message.value = 'Failed (Retry)';
      }
      isLoading.value = false;
      Future.delayed(Duration(seconds: 3), message.value = null); 
    } else {
      alertDialog('Error', 'Device is not synced.');
    }
  }

  void showReminderDialog() {
    var remindMe = storage.cached.userPreference.remindSuratKeteranganPraktikum.obs;
    if (remindMe.value) {
      alertDialog(
        'Cara Pengisian Formulir Surat Keterangan Praktikum:',
        null,
        message: Obx(() => Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(maxHeight: 152),
              decoration: BoxDecoration(
                color: appTheme.colorScheme.background,
                borderRadius: BorderRadius.circular(8)
              ),
              padding: const EdgeInsets.all(8),
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(4),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(NC.isSyncing.value ? 'Syncingin progress, please wait...' : cara, style: TextStyle(fontSize: 12.8)),
                  )
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Switch(value: remindMe.value, onChanged: NC.isSyncing.value ? null : (v) {
                  remindMe.value = v;
                  storage.cached.userPreference.remindSuratKeteranganPraktikum = v;
                  storage.save();
                })
              ],
            ),
          ],
        )),
        titleFontSize: 20,
      );
    }
  }
} 

class PertukaranJadwalPraktikumController extends GetxController {
  var isLoading = false.obs;

  String get cara => storage.cached.globalConfig.caraPertukaran ?? "Didn't exist, please refresh browser or contact our Line OA";
  List<String> get praktikumList => storage.cached.formatedPraktikum();

  @override
  void onInit() {
    super.onInit();
    showReminderDialog();
    namaF.addListener(() {
      if (!namaF.hasFocus) namaC.text = namaC.text.trim().capitalCase(false);
    });
    nimF.addListener(() {
      if (!nimF.hasFocus) nimC.text = nimC.text.trim();
    });
    namaPF.addListener(() {
      if (!namaPF.hasFocus) namaPC.text = namaPC.text.trim().capitalCase(false);
    });
    nimPF.addListener(() {
      if (!nimPF.hasFocus) nimPC.text = nimPC.text.trim();
    });
    namaPraktikumF.addListener(() {
      if (!namaPraktikumF.hasFocus) namaPraktikum.text = namaPraktikum.text.trim().capitalCase();
    });
    kodePraktikumF.addListener(() {
      if (!kodePraktikumF.hasFocus) kodePraktikum.text = kodePraktikum.text.trim().toUpperCase();
    });
  }

  @override 
  void onClose() {
    namaF.dispose();
    nimF.dispose();
    namaPF.dispose();
    nimPF.dispose();
    namaPraktikumF.dispose();
    kodePraktikumF.dispose();
    super.onClose();
  }

  Future<void> selectDate() async {
    final picked = await DateTimePickerService.selectDate(initial: dateC.text.toDateTime() ?? today, helpText: "Jadwal Sebelum Pertukaran");
    if (picked != null) dateC.text = picked.toDateString();
  }

  Future<void> selectDateP() async {
    final picked = await DateTimePickerService.selectDate(initial: datePC.text.toDateTime() ?? today, helpText: "Jadwal Pengganti");
    if (picked != null) datePC.text = picked.toDateString();
  }

  final namaC = TextEditingController();
  final nimC = TextEditingController();
  final praktikum = SingleSelectController<String>(null);
  var isPraktikumLainnya = false.obs;
  final kodePraktikum = TextEditingController();
  final namaPraktikum = TextEditingController();
  final modul = SingleSelectController<int>(null);
  final dateC = TextEditingController();

  final namaPC = TextEditingController();
  final nimPC = TextEditingController();
  final datePC = TextEditingController();

  var namaE = Rxn<String>(null); 
  var nimE = Rxn<String>(null); 
  var praktikumE = Rxn<String>(null); 
  var namaPraktikumE = Rxn<String>(null); 
  var kodePraktikumE = Rxn<String>(null); 
  var modulE = Rxn<String>(null); 
  var dateE = Rxn<String>(null); 

  var namaPE = Rxn<String>(null); 
  var nimPE = Rxn<String>(null); 
  var datePE = Rxn<String>(null); 

  var prodiList = <String>[].obs;

  final namaF = FocusNode();
  final namaPF = FocusNode();
  final nimF = FocusNode();
  final nimPF = FocusNode();
  final namaPraktikumF = FocusNode();
  final kodePraktikumF = FocusNode();

  String compileMessage() => (storage.cached.globalConfig.templatePertukaran ?? '')
    .replaceAll('{NAMA_PRAKTIKAN}', namaC.text.trim().capitalCase(false))
    .replaceAll('{NIM_PRAKTIKAN}', nimC.text.trim())
    .replaceAll('{PRAKTIKUM}', praktikum.value == 'Lainnya...' ? '${kodePraktikum.text.trim().toUpperCase()} ${namaPraktikum.text.trim().capitalCase()}' : praktikum.value ?? '')
    .replaceAll('{MODUL}', modul.value?.toString() ?? '')
    .replaceAll('{TANGGAL}', datePC.text.toDateTime()?.toDateFormatString() ?? '')
    .replaceAll('{NAMA_PENGGANTI}', namaPC.text.trim().capitalCase(false))
    .replaceAll('{NIM_PENGGANTI}', nimPC.text.trim());

   bool checkEmptyFields() {
    if (
      namaC.text.isBlank() || 
      nimC.text.isBlank() || 
      !praktikum.hasValue || 
        (praktikum.value == 'Lainnya...' && (namaPraktikum.text.isBlank() || kodePraktikum.text.isBlank())) || 
      !modul.hasValue || 
      (dateC.text.isBlank() || dateC.text.toDateTime() == null)
      ||
      namaPC.text.isBlank() || 
      nimPC.text.isBlank() || 
      (datePC.text.isBlank() || datePC.text.toDateTime() == null)
    ) {
      namaE.value = namaC.text.isBlank() ? '*required' : null;
      nimE.value = nimC.text.isBlank() ? '*required' : null;
      praktikumE.value = !praktikum.hasValue ? '*required' : null;
      namaPraktikumE.value = praktikum.value == 'Lainnya...' && namaPraktikum.text .isBlank() ? '': null;
      kodePraktikumE.value = praktikum.value == 'Lainnya...' && kodePraktikum.text .isBlank() ? '': null;
      modulE.value = !modul.hasValue ? '' : null ;
      dateE.value = dateC.text.isBlank() ? '*required' : dateC.text.toDateTime() == null ? '*invalid' : null;

      namaPE.value = namaPC.text.isBlank() ? '*required' : null;
      nimPE.value = nimC.text.isBlank() ? '*required' : null;
      datePE.value = datePC.text.isBlank() ? '*required' : datePC.text.toDateTime() == null ? '*invalid' : null;
      return false;
    }
    namaE.value = nimE.value = praktikumE.value = namaPraktikumE.value = kodePraktikumE.value = modulE.value = dateE.value 
      = namaPE.value = nimPE.value = datePE.value = null;
    return true;
  }

  void submit() async {
    if (!checkEmptyFields()) return;
    isLoading.value = true;
    final message = compileMessage();
    final url = await storage.getLineOALDTEUrl(message);
    print(url);
    Clipboard.setData(ClipboardData(text: message));
    Get.showSnackbar(GetSnackBar(message: 'Message copied to clipboard!', duration: Duration(seconds: 2)));
    if (url != null) {
      alertDialog(
        'Form Formated!', null,
        width: 360,
        message: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Data telah berhasil diformat dan tersalin ke dalam clipboard. Silahkan kirim pesan yang telah tersalin ke admin melalui link berikut: ',
                  style: TextStyle(color: Colors.white)
                ),
                WidgetSpan(
                  child: Transform.translate(
                    offset: Offset(0, 2),
                    child: InkWell(
                      onTap: () async {
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          alertDialog('Error!', 'Link tidak dapat dibuka, silahkan kirim pesan yang telah tersalin ke Line OA LDTE secara manual.');
                          Clipboard.setData(ClipboardData(text: message));
                        }
                      }, 
                      child: Text('OA Line LDTE', style: TextStyle(color: Colors.blue))
                    ),
                  ),
                ),
                TextSpan(
                  text: '.\n\nNote: Jika link tidak dapat dibuka, silahkan kirim pesan yang telah tersalin ke Line OA LDTE secara manual.',
                  style: TextStyle(color: Colors.white, fontSize: 12)
                ),
              ],
            ),
          ),
        ),
        confirmText: 'Close',
      );
    } else {
      alertDialog('Error', 'Device is not synced.');
    }
    isLoading.value = false;
  }

  void showReminderDialog() {
    var remindMe = storage.cached.userPreference.remindPertukaranJadwal.obs;
    if (remindMe.value) {
      alertDialog(
        'Cara Pengisian Formulir Pergantian Jadwal Praktikum:',
        null,
        message: Obx(() => Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(maxHeight: 152),
              decoration: BoxDecoration(
                color: appTheme.colorScheme.background,
                borderRadius: BorderRadius.circular(8)
              ),
              padding: const EdgeInsets.all(8),
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(4),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(NC.isSyncing.value ? 'Syncingin progress, please wait...' : cara, style: TextStyle(fontSize: 12.8)),
                  )
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Switch(value: remindMe.value, onChanged: NC.isSyncing.value ? null : (v) {
                  remindMe.value = v;
                  storage.cached.userPreference.remindPertukaranJadwal = v;
                  storage.save();
                })
              ],
            ),
          ],
        )),
        titleFontSize: 20,
      );
    }
  }
} 

class IzinTidakPraktikumController extends GetxController {
  var isLoading = false.obs;
  var loadingMessage = RxnString(null);

  final service = IzinTidakPraktikumService();

  String get cara => storage.cached.globalConfig.caraIzin ?? "Didn't exist, please refresh browser or contact our Line OA";
  List<String> get praktikumList => storage.cached.formatedPraktikum();

  @override
  void onInit() {
    super.onInit();
    service.imagePicker.retrieveLostData(image, key: 'izin');
    showReminderDialog();
    namaF.addListener(() {
      if (!namaF.hasFocus) namaC.text = namaC.text.trim().capitalCase(false);
    });
    nimF.addListener(() {
      if (!nimF.hasFocus) nimC.text = nimC.text.trim();
    });
    namaPraktikumF.addListener(() {
      if (!namaPraktikumF.hasFocus) namaPraktikum.text = namaPraktikum.text.trim().capitalCase();
    });
    kodePraktikumF.addListener(() {
      if (!kodePraktikumF.hasFocus) kodePraktikum.text = kodePraktikum.text.trim().toUpperCase();
    });
    alasanF.addListener(() {
      if (!alasanF.hasFocus) alasanC.text = alasanC.text.trim();
    });
  }

  @override 
  void onClose() {
    super.onClose();
    namaF.dispose();
    nimF.dispose();
    namaPraktikumF.dispose();
    kodePraktikumF.dispose();
    alasanF.dispose();
  }

  Future<void> selectDate() async {
    final picked = await DateTimePickerService.selectDate(initial: dateC.text.toDateTime() ?? today, helpText: "Jadwal Sebelum Pertukaran");
    if (picked != null) dateC.text = picked.toDateString();
  }

  final namaC = TextEditingController();
  final nimC = TextEditingController();
  final praktikum = SingleSelectController<String>(null);
  var isPraktikumLainnya = false.obs;
  final kodePraktikum = TextEditingController();
  final namaPraktikum = TextEditingController();
  final modul = SingleSelectController<int>(null);
  final dateC = TextEditingController();
  final alasanC = TextEditingController();
  var image = Rxn<XFile>(null); 
  int lastImageByteLength = -1;
  String lastImageUrl = '';

  var namaE = Rxn<String>(null); 
  var nimE = Rxn<String>(null); 
  var praktikumE = Rxn<String>(null); 
  var namaPraktikumE = Rxn<String>(null); 
  var kodePraktikumE = Rxn<String>(null); 
  var modulE = Rxn<String>(null); 
  var dateE = Rxn<String>(null); 
  var alasanE = Rxn<String>(null); 
  var imageE = Rxn<String>(null); 

  var prodiList = <String>[].obs;

  final namaF = FocusNode();
  final nimF = FocusNode();
  final namaPraktikumF = FocusNode();
  final kodePraktikumF = FocusNode();
  final alasanF = FocusNode();
  
  void selectImage() async {
    service.imagePicker.selectImage(image, key: 'izin');
  }

  void previewImage() {
    service.imagePicker.previewImage(image.value!);
  }

  void resetImage() {
    service.imagePicker.resetImage(image, key: 'izin');
  }

  String compileMessage(String image) => (storage.cached.globalConfig.templateIzin ?? '')
    .replaceAll('{NAMA}', namaC.text.trim().capitalCase(false))
    .replaceAll('{NIM}', nimC.text.trim())
    .replaceAll('{PRAKTIKUM}', praktikum.value == 'Lainnya...' ? '${kodePraktikum.text.trim().toUpperCase()} ${namaPraktikum.text.trim().capitalCase()}' : praktikum.value ?? '')
    .replaceAll('{MODUL}', modul.value?.toString() ?? '')
    .replaceAll('{TANGGAL}', dateC.text.toDateTime()?.toDateFormatString() ?? '')
    .replaceAll('{ALASAN}', alasanC.text.trim())
    .replaceAll('{IMAGE}', image.trim());

   bool checkEmptyFields() {
    namaE.value = namaC.text.isBlank() ? '*required' : null;
    nimE.value = nimC.text.isBlank() ? '*required' : null;
    praktikumE.value = !praktikum.hasValue ? '*required' : null;
    namaPraktikumE.value = praktikum.value == 'Lainnya...' && namaPraktikum.text .isBlank() ? '': null;
    kodePraktikumE.value = praktikum.value == 'Lainnya...' && kodePraktikum.text .isBlank() ? '': null;
    modulE.value = !modul.hasValue ? '' : null ;
    dateE.value = dateC.text.isBlank() ? '*required' : dateC.text.toDateTime() == null ? '*invalid' : null;
    alasanE.value = alasanC.text.isBlank() ? '*required' : null;
    imageE.value = image.value == null ? '*required' : null;
    
    return namaE.value == null && nimE.value == null && praktikumE.value == null && namaPraktikumE.value == null && kodePraktikumE.value == null && modulE.value == null && dateE.value == null && alasanE.value == null;
  }
  
  void submit() async {
    if (!checkEmptyFields()) return;
    isLoading.value = true;
    final imageByteLength = (await image.value!.readAsBytes()).length;
    if (lastImageByteLength != imageByteLength) {
      loadingMessage.value = 'Uploading Image...';
      final imageUrl = await service.uploadImage(image.value!);
      if (imageUrl == null) {
        isLoading.value = false;
        return;
      }
      lastImageUrl = imageUrl;
      lastImageByteLength = imageByteLength;
    } 
    loadingMessage.value = 'Formating message...';
    final message = compileMessage(lastImageUrl);
    final url = await storage.getLineOALDTEUrl(message);
    print(url);
    Clipboard.setData(ClipboardData(text: message));
    Get.showSnackbar(GetSnackBar(message: 'Message copied to clipboard!', duration: Duration(seconds: 2)));
    if (url != null) {
      alertDialog(
        'Form Formated!', null,
        width: 360,
        message: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Data telah berhasil diformat dan tersalin ke dalam clipboard. Silahkan kirim pesan yang telah tersalin ke admin melalui link berikut: ',
                  style: TextStyle(color: Colors.white)
                ),
                WidgetSpan(
                  child: Transform.translate(
                    offset: Offset(0, 2),
                    child: InkWell(
                      onTap: () async {
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          alertDialog('Error!', 'Link tidak dapat dibuka, silahkan kirim pesan yang telah tersalin ke Line OA LDTE secara manual.');
                          Clipboard.setData(ClipboardData(text: message));
                        }
                      }, 
                      child: Text('OA Line LDTE', style: TextStyle(color: Colors.blue))
                    ),
                  ),
                ),
                TextSpan(
                  text: '.\n\nNote: Jika link tidak dapat dibuka, silahkan kirim pesan yang telah tersalin ke Line OA LDTE secara manual.',
                  style: TextStyle(color: Colors.white, fontSize: 12)
                ),
              ],
            ),
          ),
        ),
        confirmText: 'Close',
      );
    } else {
      alertDialog('Error', 'Device is not synced.');
    }
    isLoading.value = false;
  }

  void showReminderDialog() {
    var remindMe = storage.cached.userPreference.remindIzinTidakPraktikum.obs;
    if (remindMe.value) {
      alertDialog(
        'Cara Pengisian Formulir Izin Tidak Mengikuti Praktikum:',
        null,
        message: Obx(() => Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(maxHeight: 152),
              decoration: BoxDecoration(
                color: appTheme.colorScheme.background,
                borderRadius: BorderRadius.circular(8)
              ),
              padding: const EdgeInsets.all(8),
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(4),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(NC.isSyncing.value ? 'Syncingin progress, please wait...' : cara, style: TextStyle(fontSize: 12.8)),
                  )
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Switch(value: remindMe.value, onChanged: NC.isSyncing.value ? null : (v) {
                  remindMe.value = v;
                  storage.cached.userPreference.remindIzinTidakPraktikum = v;
                  storage.save();
                })
              ],
            ),
          ],
        )),
        titleFontSize: 20,
      );
    }
  }
} 

class AdminController extends GetxController {
  var isLoading = false.obs;

  void SignOutDialog() {
    alertDialog(
      'Logout',
      'Are you sure you want to logout?',
      confirmAction: signOut, 
      confirmText: 'Logout',
    );
  }
  
  void signOut() async {
    isLoading.value = true;
    currentContext?.pop();
    await auth.supabase.auth.signOut();
    isLoading.value = false;
  }
}

class AdminPeminjamanPeralatanController extends GetxController {
  final admin = AdminPeminjamanPeralatanService();

  var isLoading = false.obs;
  var isMassLoading = false.obs;
  var submissions = <PeminjamanPeralatanModel>[];
  var loadingIndicator = <int>[];
  var isSelected = <int>[];
  var qfsped = RxList<PeminjamanPeralatanModel>([]);

  @override
  void onInit() {
    super.onInit();
    getAllSubmissions();
  }

  var pageNum = 1.obs;
  var pageC = NumberPaginatorController();

  final startDateC = TextEditingController(text: today.subtract(Duration(days: 30)).toDateString());
  final endDateC = TextEditingController(text: todayEnd.toDateString());
  List<DateTime> get dateTimeList => [startDateC.text.toDateTime() ?? today, endDateC.text.toDateTime()?.add(Duration(days: 1)).subtract(Duration(seconds: 1)) ?? today];

  Future<void> selectDateFilterStart() async {
    final picked = await DateTimePickerService.selectDate(initial: startDateC.text.toDateTime(), helpText: "Select start date");
    if (picked != null) {
      startDateC.text = picked.toDateString();
      qfsp.onChanged();
    }
  }

  Future<void> selectDateFilterEnd() async {
    final picked = await DateTimePickerService.selectDate(initial: endDateC.text.toDateTime(), helpText: "Select end date");
    if (picked != null) {
      endDateC.text = picked.toDateString();
      qfsp.onChanged();
    }
  }

  late QFSPController<PeminjamanPeralatanModel> qfsp = QFSPController(
    filter: [
      FilterController(
        filterKey: "status",
        filterList: ['unchecked', 'borrowed', 'returned', 'overdue', 'damaged', 'lost', 'spam'],
        initialSelected: ['unchecked', 'borrowed', 'returned', 'overdue', 'damaged', 'lost'],
        reference: (m) => m.status
      ),
    ],
    onChanged: ([String? itemKey, String? filterKey]) {
      var queried = admin.QFSP.query(submissions, qfsp, (v) => [v.nama, v.nim]);
      var filtered = admin.QFSP.filter(queried, qfsp, itemKey, filterKey, dateTimeList, (v) => v.createdAt);
      var sorted = admin.QFSP.sort(filtered, qfsp);
      var paged = admin.QFSP.page(sorted, qfsp, pageNum);
      qfsped.value = paged;
    },
    pageC: pageC,
  );

  Future<void> getAllSubmissions() async {
    isLoading.value = true;
    final res = await admin.getAllSubmissions();
    if (res != null) {
      submissions = res;
      qfsp.onChanged();
    }
    isLoading.value = false;
  }

  void selectItem(int id, bool state) {
    state ? isSelected.add(id) : isSelected.remove(id);
    qfsped.refresh();
  }

  void selectPageItem(bool? state) {
    qfsped.forEach((v) => state == true ? isSelected.add(v.id) : isSelected.remove(v.id));
    Future(() => qfsped.refresh());
  }

  void setStatus(int id, String status) async {
    loadingIndicator.add(id);
    qfsped.refresh();
    final res = await admin.updateStatus([id], status);
    loadingIndicator.remove(id);
    if (res != null) updateSubmission(res);
  }

  void setSelectedStatus(String status) {
    alertDialog(
      'Confirmation', 
      'You are going to update ${isSelected.length} row of status data to $status. This action cannot be undone.\n'
      'Are you completely sure?',
      confirmAction: () async {
        isMassLoading.value = true;
        closeAllDialog();
        isSelected.forEach(loadingIndicator.add);
        qfsped.refresh();
        final res = await admin.updateStatus(isSelected, status);
        isSelected.forEach(loadingIndicator.remove);
        if (res != null) {
          isSelected.clear();
          updateSubmission(res);
        }
        isMassLoading.value = false;
      },
    );
  }

  void updateSubmission(List<PeminjamanPeralatanModel> newData) {
    for (final item in newData.toList()) {
      final index = submissions.indexWhere((v) => v.id == item.id);
      if (index != -1) submissions[index] = item;
    }
    qfsp.onChanged();
  }

  void detail(int id) {
    currentContext?.push('${NamedRoute.pinjamAdmin}/$id');
  }
}

class DetailPeminjamanPeralatanController extends PeminjamanPeralatanController {
  final int id = int.tryParse(router.state.pathParameters['id'] ?? '') ?? -1;
  final ac = Get.find<AdminPeminjamanPeralatanController>();

  @override 
  void init() {}

  @override
  void onClose() {
    Future.microtask(() => getFindCall<AdminPeminjamanPeralatanController>()?.qfsp.onChanged());
    super.onClose();
  }

  void setInitialValue() {
    if (namaC.text.isNotEmpty) return; 
    final submission = ac.submissions.firstWhereOrNull((v) => v.id == id);
    if (submission == null) return;
    namaC.text = submission.nama;
    nimC.text = submission.nim;
    for (int i = 0; i < submission.barang.length; i++) {
      barangC[i].text = submission.barang[i];
      banyakC[i].value = submission.banyak[i];
    }
    mulaiC.text = submission.mulai.toDateString();
    akhirC.text = submission.akhir.toDateString();
    itemN.value = submission.barang.length;
  }

  @override
  void submit() async {
    if (!checkEmptyFields(false)) return;
    ac.isLoading.value = true;
    final res = await ac.admin.updateFormData(id, dbform);
    if (res != null) {
      final i = ac.submissions.indexWhere((v) => v.id == id);
      if (i == -1) {
        ac.getAllSubmissions();
        return;
      }
      snackbar('Success!', 'Form data updated Successfuly');
      ac.submissions[i] = res;
    }
    ac.isLoading.value = false;
  }
}

class AdminSuratKeteranganPraktikumController extends GetxController {
  final admin = AdminSuratKeteranganPraktikumService();

  var isLoading = false.obs;
  var isMassLoading = false.obs;
  var isExporting = false.obs;
  var submissions = <SuratKeteranganPraktikumModel>[];
  var loadingIndicator = <int>[];
  var isSelected = <int>[];
  var qfsped = RxList<SuratKeteranganPraktikumModel>([]);

  @override
  void onInit() {
    super.onInit();
    admin.initWorker();
    getAllSubmissions();
  }

  @override
  void onClose() {
    admin.closeWorker();
    super.onClose();
  }

  var pageNum = 1.obs;
  var pageC = NumberPaginatorController();

  final startDateC = TextEditingController(text: today.subtract(Duration(days: 30)).toDateString());
  final endDateC = TextEditingController(text: todayEnd.toDateString());
  List<DateTime> get dateTimeList => [startDateC.text.toDateTime() ?? today, endDateC.text.toDateTime()?.add(Duration(days: 1)).subtract(Duration(seconds: 1)) ?? today];

  Future<void> selectDateFilterStart() async {
    final picked = await DateTimePickerService.selectDate(initial: startDateC.text.toDateTime(), helpText: "Select start date");
    if (picked != null) {
      startDateC.text = picked.toDateString();
      qfsp.onChanged();
    }
  }

  Future<void> selectDateFilterEnd() async {
    final picked = await DateTimePickerService.selectDate(initial: endDateC.text.toDateTime(), helpText: "Select end date");
    if (picked != null) {
      endDateC.text = picked.toDateString();
      qfsp.onChanged();
    }
  }

  late QFSPController<SuratKeteranganPraktikumModel> qfsp = QFSPController(
    filter: [
      FilterController(
        filterKey: "status",
        filterList: ['unchecked', 'pending', 'exported', 'spam'],
        initialSelected: ['unchecked', 'pending', 'exported'],
        reference: (m) => m.status
      ),
    ],
    onChanged: ([String? itemKey, String? filterKey]) {
      var queried = admin.QFSP.query(submissions, qfsp, (v) => [v.nama.join(', '), v.nim.join(', ')]);
      var filtered = admin.QFSP.filter(queried, qfsp, itemKey, filterKey, dateTimeList, (v) => v.createdAt);
      var sorted = admin.QFSP.sort(filtered, qfsp);
      var paged = admin.QFSP.page(sorted, qfsp, pageNum);
      qfsped.value = paged;
    },
    pageC: pageC,
  );

  Future<void> getAllSubmissions() async {
    isLoading.value = true;
    final res = await admin.getAllSubmissions();
    if (res != null) {
      submissions = res;
      qfsp.onChanged();
    }
    getFindCall<DetailSuratKeteranganPraktikumController>()?.setInitialValue();
    isLoading.value = false;
  }

  void preview(SuratKeteranganPraktikumModel data) async {
    isExporting.value = true;
    qfsped.refresh();
    final savedFile = await admin.compilePDF(data);
    if (savedFile != null) {
      final fileName = "Surat_Keterangan_praktikum-${DateTime.now().millisecondsSinceEpoch}.pdf";
      admin.preview(savedFile, fileName);
    }
    isExporting.value = false;
    qfsped.refresh();
  }

  void selectItem(int id, bool state) {
    state ? isSelected.add(id) : isSelected.remove(id);
    qfsped.refresh();
  }

  void selectPageItem(bool? state) {
    qfsped.forEach((v) => state == true ? isSelected.add(v.id) : isSelected.remove(v.id));
    Future(() => qfsped.refresh());
  }

  void setStatus(int id, String status) async {
    loadingIndicator.add(id);
    qfsped.refresh();
    final res = await admin.updateStatus([id], status);
    loadingIndicator.remove(id);
    if (res != null) updateSubmission(res);
  }

  void setSelectedStatus(String status) {
    alertDialog(
      'Confirmation', 
      'You are going to update ${isSelected.length} row of status data to $status. This action cannot be undone.\n'
      'Are you completely sure?',
      confirmAction: () async {
        isMassLoading.value = true;
        closeAllDialog();
        isSelected.forEach(loadingIndicator.add);
        qfsped.refresh();
        final res = await admin.updateStatus(isSelected, status);
        isSelected.forEach(loadingIndicator.remove);
        if (res != null) {
          isSelected.clear();
          updateSubmission(res);
        }
        isMassLoading.value = false;
      },
    );
  }

  void updateSubmission(List<SuratKeteranganPraktikumModel> newData) {
    for (final item in newData.toList()) {
      final index = submissions.indexWhere((v) => v.id == item.id);
      if (index != -1) submissions[index] = item;
    }
    qfsp.onChanged();
  }

  void detail(int id) {
    currentContext?.push('${NamedRoute.keteranganAdmin}/$id');
  }
}

class DetailSuratKeteranganPraktikumController extends SuratKeteranganPraktikumController {
  final int id = int.tryParse(router.state.pathParameters['id'] ?? '') ?? -1;
  final ac = Get.find<AdminSuratKeteranganPraktikumController>();

  @override 
  void init() {}

  @override
  void onClose() {
    Future.microtask(() => getFindCall<AdminSuratKeteranganPraktikumController>()?.qfsp.onChanged());
    super.onClose();
  }

  void setInitialValue() {
    if (namaC[0].text.isNotEmpty) return;
    final submission = ac.submissions.firstWhereOrNull((v) => v.id == id);
    if (submission == null) return;

    for (int i = 0; i < submission.nama.length; i++) {
      namaC[i].text = submission.nama[i];
      nimC[i].text = submission.nim[i];
    }
    
    isMatkulLainnya.value = !matkulList.contains(submission.matkul);
    matkul.value = isMatkulLainnya.value ? "Lainnya..." : submission.matkul;
    if (isMatkulLainnya.value) {
      kodeMatkul.text = submission.matkul.split(' ').first;
      namaMatkul.text = submission.matkul.substring(kodeMatkul.text.length + 1);
    }

    isPraktikumLainnya.value = !praktikumList.contains(submission.praktikum);
    praktikum.value = isPraktikumLainnya.value ?  "Lainnya..." : submission.praktikum;
    if (isPraktikumLainnya.value) {
      kodePraktikum.text = submission.praktikum.split(' ').first;
      namaPraktikum.text = submission.praktikum.substring(kodePraktikum.text.length + 1);
    }

    modul.value = submission.modul;
    dateC.text = submission.date.toDateString();
    timeStartC.value = submission.timeStart;
    timeEndC.value = submission.timeEnd;

    itemN.value = submission.nama.length;
  }

  @override
  void submit() async {
    if (!checkEmptyFields(false)) return;
    ac.isLoading.value = true;
    final res = await ac.admin.updateFormData(id, form);
    if (res != null) {
      final lId = ac.submissions.indexWhere((v) => v.id == id);
      if (lId == -1) {
        ac.getAllSubmissions();
        return;
      }
      snackbar('Success!', 'Form data updated Successfuly');
      ac.submissions[lId] = res;
    }
    ac.isLoading.value = false;
  }
}

class GlobalConfigController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    init();
    lineOAFocus.addListener(() {
      if (!lineOAFocus.hasFocus) {
        lineOA.text = lineOA.text.trim().toLowerCase();
        if (lineOA.text[0] == '@') lineOA.text.substring(1);
        isSavedCheck();
      }
    });
    nomorSuratFocus.addListener(() {
      if (!nomorSuratFocus.hasFocus) {
        nomorSurat.text = nomorSurat.text.trim().toUpperCase();
        isSavedCheck();
      }
    });
    namaKepalaLDTEFocus.addListener(() {
      if (!namaKepalaLDTEFocus.hasFocus) {
        namaKepalaLDTE.text = namaKepalaLDTE.text.trim().capitalCase();
        isSavedCheck();
      }
    });
    nipKepalaLDTEFocus.addListener(() {
      if (!nipKepalaLDTEFocus.hasFocus) {
        nipKepalaLDTE.text = nipKepalaLDTE.text.trim();
        isSavedCheck();
      }
    });
    caraPinjamFocus.addListener(() {
      if (!caraPinjamFocus.hasFocus) {
        caraPinjam.text = caraPinjam.text.trim();
        isSavedCheck();
      }
    });
    caraKeteranganFocus.addListener(() {
      if (!caraKeteranganFocus.hasFocus) {
        caraKeterangan.text = caraKeterangan.text.trim();
        isSavedCheck();
      }
    });
    caraPertukaranFocus.addListener(() {
      if (!caraPertukaranFocus.hasFocus) {
        caraPertukaran.text = caraPertukaran.text.trim();
        isSavedCheck();
      }
    });
    caraIzinFocus.addListener(() {
      if (!caraIzinFocus.hasFocus) {
        caraIzin.text = caraIzin.text.trim();
        isSavedCheck();
      }
    });
    caraSusulanFocus.addListener(() {
      if (!caraSusulanFocus.hasFocus) {
        caraSusulan.text = caraSusulan.text.trim();
        isSavedCheck();
      }
    });
    templatePertukaranFocus.addListener(() {
      if (!templatePertukaranFocus.hasFocus) {
        templatePertukaran.text = templatePertukaran.text.trim();
        isSavedCheck();
        isTemplateValid('pertukaran');
      }
    });
    templateIzinFocus.addListener(() {
      if (!templateIzinFocus.hasFocus) {
        templateIzin.text = templateIzin.text.trim();
        isSavedCheck();
        isTemplateValid('izin');
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    lineOAFocus.dispose();
    nomorSuratFocus.dispose();
    namaKepalaLDTEFocus.dispose();
    nipKepalaLDTEFocus.dispose();
    caraPinjamFocus.dispose();
    caraKeteranganFocus.dispose();
    caraPertukaranFocus.dispose();
    caraIzinFocus.dispose();
    caraSusulanFocus.dispose();
    templatePertukaranFocus.dispose();
    templateIzinFocus.dispose();
  }

  final service = GlobalConfigService();

  var isSaved = true.obs;
  var isLoading = false.obs;
  var loadingMessage = RxnString();

  bool isSavedCheck() {
    lineOASaved.value = lineOA.text.trim().toLowerCase() == storage.cached.globalConfig.lineOALDTE;
    nomorSuratSaved.value = nomorSurat.text.trim().toUpperCase() == storage.cached.globalConfig.nomorSurat;
    namaKepalaLDTESaved.value = namaKepalaLDTE.text.trim().capitalCase() == storage.cached.globalConfig.namaKepalaLDTE;
    nipKepalaLDTESaved.value = nipKepalaLDTE.text.trim() == storage.cached.globalConfig.nipKepalaLDTE;
    caraPinjamSaved.value = caraPinjam.text.trim() == storage.cached.globalConfig.caraPinjam;
    caraKeteranganSaved.value = caraKeterangan.text.trim() == storage.cached.globalConfig.caraKeterangan;
    caraPertukaranSaved.value = caraPertukaran.text.trim() == storage.cached.globalConfig.caraPertukaran;
    caraIzinSaved.value = caraIzin.text.trim() == storage.cached.globalConfig.caraIzin;
    caraSusulanSaved.value = caraSusulan.text.trim() == storage.cached.globalConfig.caraSusulan;
    templatePertukaranSaved.value = templatePertukaran.text.trim() == storage.cached.globalConfig.templatePertukaran;
    templateIzinSaved.value = templateIzin.text.trim() == storage.cached.globalConfig.templateIzin;
    isSaved.value = lineOASaved.value && nomorSuratSaved.value && namaKepalaLDTESaved.value && nipKepalaLDTESaved.value && caraPinjamSaved.value && caraKeteranganSaved.value && caraPertukaranSaved.value && caraIzinSaved.value && templatePertukaranSaved.value && templateIzinSaved.value;
    return isSaved.value && !isAnyQueued && !itemQueue.isAnyQueued;
  }

  bool isTemplateValid([String? key]) {
    final pertukaranMatch = curlyBrackets.allMatches(templatePertukaran.text).map((match) => match.group(0)!);
    final izinMatch = curlyBrackets.allMatches(templateIzin.text).map((match) => match.group(0)!);
    final pertukaranInvalid = pertukaranMatch.where((v) => !pertukaranVar.contains(v));
    final pertukaranMissing = pertukaranVar.where((v) => !pertukaranMatch.contains(v));
    final izinInvalid = izinMatch.where((v) => !izinVar.contains(v));
    final izinMissing = izinVar.where((v) => !izinMatch.contains(v));
    if ((key ?? 'pertukaran') == 'pertukaran') {
      templatePertukaranE.value = 
        templatePertukaranSaved.value
          ? null
          : pertukaranInvalid.isNotEmpty
            ? "*invalid var: ${pertukaranInvalid.join(', ')}"
            : pertukaranMissing.isNotEmpty
              ? "*missing var: ${pertukaranMissing.join(', ')}"
              : null;
      if (key == 'pertukaran') return templatePertukaranE.value == null;
    }
    if ((key ?? 'izin') == 'izin') {
      templateIzinE.value = 
        templateIzinSaved.value 
          ? null
          : izinInvalid.isNotEmpty
            ? "*invalid var: ${izinInvalid.join(', ')}"
            : izinMissing.isNotEmpty
              ? "*missing var: ${izinMissing.join(', ')}"
              : null;
      if (key == 'izin') return templateIzinE.value == null;
    }
      
    return templatePertukaranE.value == null && templateIzinE.value == null;
  }

  void init() {
    fakultasQueue = QueueActionModel();
    prodiQueue = QueueActionModel();
    matprakQueue = QueueActionModel();
    lineOA.text = storage.cached.globalConfig.lineOALDTE ?? '';
    nomorSurat.text = storage.cached.globalConfig.nomorSurat ?? '';
    namaKepalaLDTE.text = storage.cached.globalConfig.namaKepalaLDTE ?? '';
    nipKepalaLDTE.text = storage.cached.globalConfig.nipKepalaLDTE ?? '';
    caraPinjam.text = storage.cached.globalConfig.caraPinjam ?? '';
    caraKeterangan.text = storage.cached.globalConfig.caraKeterangan ?? '';
    caraPertukaran.text = storage.cached.globalConfig.caraPertukaran ?? '';
    caraIzin.text = storage.cached.globalConfig.caraIzin ?? '';
    caraSusulan.text = storage.cached.globalConfig.caraSusulan ?? '';
    templatePertukaran.text = storage.cached.globalConfig.templatePertukaran ?? '';
    templateIzin.text = storage.cached.globalConfig.templateIzin ?? '';
  }

  final lineOA = TextEditingController();
  final lineOAFocus = FocusNode();
  var lineOACanEdit = false.obs;
  var lineOASaved = true.obs;

  final nomorSurat = TextEditingController();
  final nomorSuratFocus = FocusNode();
  var nomorSuratCanEdit = false.obs;
  var nomorSuratSaved = true.obs;

  final namaKepalaLDTE = TextEditingController();
  final namaKepalaLDTEFocus = FocusNode();
  var namaKepalaLDTECanEdit = false.obs;
  var namaKepalaLDTESaved = true.obs;

  final nipKepalaLDTE = TextEditingController();
  final nipKepalaLDTEFocus = FocusNode();
  var nipKepalaLDTECanEdit = false.obs;
  var nipKepalaLDTESaved = true.obs;

  final caraPinjam = TextEditingController();
  final caraPinjamFocus = FocusNode();
  var caraPinjamCanEdit = false.obs;
  var caraPinjamSaved = true.obs;

  final caraKeterangan = TextEditingController();
  final caraKeteranganFocus = FocusNode();
  var caraKeteranganCanEdit = false.obs;
  var caraKeteranganSaved = true.obs;

  final caraPertukaran = TextEditingController();
  final caraPertukaranFocus = FocusNode();
  var caraPertukaranCanEdit = false.obs;
  var caraPertukaranSaved = true.obs;

  final caraIzin = TextEditingController();
  final caraIzinFocus = FocusNode();
  var caraIzinCanEdit = false.obs;
  var caraIzinSaved = true.obs;

  final caraSusulan = TextEditingController();
  final caraSusulanFocus = FocusNode();
  var caraSusulanCanEdit = false.obs;
  var caraSusulanSaved = true.obs;

  final templatePertukaran = TextEditingController();
  final templatePertukaranFocus = FocusNode();
  var templatePertukaranE = RxnString(null);
  var templatePertukaranCanEdit = false.obs;
  var templatePertukaranSaved = true.obs;

  final templateIzin = TextEditingController();
  final templateIzinFocus = FocusNode();
  var templateIzinE = RxnString(null);
  var templateIzinCanEdit = false.obs;
  var templateIzinSaved = true.obs;

  Map<String, String> get form {
    lineOA.text = lineOA.text.trim().toLowerCase();
    if (lineOA.text[0] == '@') lineOA.text.substring(1);
    nomorSurat.text = nomorSurat.text.trim().toUpperCase();
    namaKepalaLDTE.text = namaKepalaLDTE.text.trim().capitalCase();
    nipKepalaLDTE.text = nipKepalaLDTE.text.trim();
    caraPinjam.text = caraPinjam.text.trim();
    caraKeterangan.text = caraKeterangan.text.trim();
    caraPertukaran.text = caraPertukaran.text.trim();
    caraIzin.text = caraIzin.text.trim();
    caraSusulan.text = caraSusulan.text.trim();
    templatePertukaran.text = templatePertukaran.text.trim();
    templateIzin.text = templateIzin.text.trim();
    return {
      if (lineOA.text != storage.cached.globalConfig.lineOALDTE) 'lineoa_ldte' : lineOA.text,
      if (nomorSurat.text != storage.cached.globalConfig.nomorSurat) 'nomor_surat' : nomorSurat.text,
      if (namaKepalaLDTE.text != storage.cached.globalConfig.namaKepalaLDTE) 'nama_kepala_ldte' : namaKepalaLDTE.text,
      if (nipKepalaLDTE.text != storage.cached.globalConfig.nipKepalaLDTE) 'nip_kepala_ldte' : nipKepalaLDTE.text,
      if (caraPinjam.text != storage.cached.globalConfig.caraPinjam) 'cara_pinjam' : caraPinjam.text,
      if (caraKeterangan.text != storage.cached.globalConfig.caraKeterangan) 'cara_keterangan' : caraKeterangan.text,
      if (caraPertukaran.text != storage.cached.globalConfig.caraPertukaran) 'cara_pertukaran' : caraPertukaran.text,
      if (caraIzin.text != storage.cached.globalConfig.caraIzin) 'cara_izin' : caraIzin.text,
      if (caraSusulan.text != storage.cached.globalConfig.caraSusulan) 'cara_susulan' : caraSusulan.text,
      if (templatePertukaran.text != storage.cached.globalConfig.templatePertukaran) 'template_pertukaran' : templatePertukaran.text,
      if (templateIzin.text != storage.cached.globalConfig.templateIzin) 'template_izin' : templateIzin.text,
    };
  }
  
  void lineOAUndo() async {
    lineOA.text = storage.cached.globalConfig.lineOALDTE ?? '';
    lineOA.selection = TextSelection.collapsed(offset: lineOA.text.length);
    isSavedCheck();
  }
  
  void nomorSuratUndo() async {
    nomorSurat.text = storage.cached.globalConfig.nomorSurat ?? '';
    nomorSurat.selection = TextSelection.collapsed(offset: nomorSurat.text.length);
    isSavedCheck();
  }
  
  void namaKepalaLDTEUndo() async {
    namaKepalaLDTE.text = storage.cached.globalConfig.namaKepalaLDTE ?? '';
    namaKepalaLDTE.selection = TextSelection.collapsed(offset: namaKepalaLDTE.text.length);
    isSavedCheck();
  }
  
  void nipKepalaLDTEUndo() async {
    nipKepalaLDTE.text = storage.cached.globalConfig.nipKepalaLDTE ?? '';
    nipKepalaLDTE.selection = TextSelection.collapsed(offset: nipKepalaLDTE.text.length);
    isSavedCheck();
  }
  
  void caraPinjamUndo() async {
    caraPinjam.text = storage.cached.globalConfig.caraPinjam ?? '';
    caraPinjam.selection = TextSelection.collapsed(offset: caraPinjam.text.length);
    isSavedCheck();
  }
  
  void caraKeteranganUndo() async {
    caraKeterangan.text = storage.cached.globalConfig.caraKeterangan ?? '';
    caraKeterangan.selection = TextSelection.collapsed(offset: caraKeterangan.text.length);
    isSavedCheck();
  }
  
  void caraPertukaranUndo() async {
    caraPertukaran.text = storage.cached.globalConfig.caraPertukaran ?? '';
    caraPertukaran.selection = TextSelection.collapsed(offset: caraPertukaran.text.length);
    isSavedCheck();
  }
  
  void caraIzinUndo() async {
    caraIzin.text = storage.cached.globalConfig.caraIzin ?? '';
    caraIzin.selection = TextSelection.collapsed(offset: caraIzin.text.length);
    isSavedCheck();
  }
  
  void caraSusulanUndo() async {
    caraSusulan.text = storage.cached.globalConfig.caraSusulan ?? '';
    caraSusulan.selection = TextSelection.collapsed(offset: caraSusulan.text.length);
    isSavedCheck();
  }
  
  void templatePertukaranUndo() async {
    templatePertukaran.text = storage.cached.globalConfig.templatePertukaran ?? '';
    templatePertukaran.selection = TextSelection.collapsed(offset: templatePertukaran.text.length);
    isSavedCheck();
    isTemplateValid('pertukaran');
  }
  
  void templateIzinUndo() async {
    templateIzin.text = storage.cached.globalConfig.templateIzin ?? '';
    templateIzin.selection = TextSelection.collapsed(offset: templateIzin.text.length);
    isSavedCheck();
    isTemplateValid('izin');
  }

  void save(String key, RxBool canEdit) async {
    final message = key == 
    'lineoa_ldte' ? 'line official account' : key == 
    'lineoa_ldte' ? 'line official account' : key == 
    'nomor_surat' ? 'nomor surat' : key == 
    'nama_kepala_ldte' ? 'nama kepala LDTE' : key == 
    'nip_kepala_ldte' ? 'nim kepala LDTE' : key == 
    'cara_pinjam' ? 'cara pengisian formulir peminjaman peralatan' : key == 
    'cara_keterangan' ? 'cara pengisian surat keterangan praktikum' : key == 
    'cara_pertukaran' ? 'cara pengisian formulir pertukaran' : key == 
    'cara_izin' ? 'cara pengisian surat keteragan izin' : key == 
    'cara_susulan' ? 'cara pengisian template permohonan susulan' : key == 
    'template_pertukaran' ? 'template pesan pertukaran jadwal' : key == 
    'template_izin' ? 'template pesan izin praktikum' : 'unknown';
    
    loadingMessage.value = 'Saving $message, please wait...';
    isLoading.value = true;
    final isSuccess = await service.updateGlobalConfig({key : form[key]});
    if (isSuccess) {
      snackbar('Success!', '$message updated');
      loadingMessage.value = 'Syncing new config, please wait...';
      await storage.sync();
      canEdit.value = false;
      isSavedCheck();
    }
    isLoading.value = false;
  }

  void saveLineOa() => save('lineoa_ldte', lineOACanEdit);

  void saveNomorSurat() => save('nomor_surat', nomorSuratCanEdit);

  void saveNamaKepalaLDTE() => save('nama_kepala_ldte', namaKepalaLDTECanEdit);

  void saveNipKepalaLDTE() => save('nip_kepala_ldte', nipKepalaLDTECanEdit);

  void saveCaraPinjam() => save('cara_pinjam', caraPinjamCanEdit);

  void saveCaraKeterangan() => save('cara_keterangan', caraKeteranganCanEdit);

  void saveCaraPertukaran() => save('cara_pertukaran', caraPertukaranCanEdit);

  void saveCaraIzin() => save('cara_izin', caraIzinCanEdit);

  void saveCaraSusulan() => save('cara_susulan', caraSusulanCanEdit);

  void savetemplatePertukaran() {
    if (!isTemplateValid('pertukaran')) return;
    save('template_pertukaran', templatePertukaranCanEdit); 
  }

  void savetemplateIzin() {
    if (!isTemplateValid('izin')) return;
    save('template_izin', templateIzinCanEdit);
  }

  Future<void> saveQueuedAction() async {
    isLoading.value = true;
    loadingMessage.value = 'Saving updated list, please wait...';
    final isSuccess = await pushQueuedAction(simulated.fakultas);
    if (isSuccess) {
      snackbar('Success!', 'list updated');
      loadingMessage.value = 'Syncing new config, please wait...';
      await storage.sync();
      isSavedCheck();
    }
    isLoading.value = false;
  }

  Future<void> saveItemAction() async {
    isLoading.value = true;
    loadingMessage.value = 'Saving updated item, please wait...';
    final isSuccess = await pushQueuedAction(simulated.item);
    if (isSuccess) {
      snackbar('Success!', 'list updated');
      loadingMessage.value = 'Syncing new config, please wait...';
      await storage.sync();
      isSavedCheck();
    }
    isLoading.value = false;
  }

  Future<void> saveAll() async {
    if (!isTemplateValid()) return;
    isLoading.value = true;
    loadingMessage.value = 'Saving updated config, please wait...';
    if (!isSaved.value) {
      final isSuccess = await service.updateGlobalConfig(form);
      if (isSuccess) {
        snackbar('Success!', 'Global config updated');
        nomorSuratCanEdit.value = lineOACanEdit.value = lineOACanEdit.value = lineOACanEdit.value = lineOACanEdit.value = lineOACanEdit.value = lineOACanEdit.value = false;
      }
    }
    if (isAnyQueued) {
      loadingMessage.value = 'Saving list, please wait...';
      final isSuccess = await pushQueuedAction(simulated.fakultas);
      if (isSuccess) {
        snackbar('Success!', 'List updated');
      }
    }
    if (itemQueue.isAnyQueued) {
      loadingMessage.value = 'Saving item, please wait...';
      final isSuccess = await pushQueuedAction(simulated.item);
      if (isSuccess) {
        snackbar('Success!', 'List updated');
      }
    }
    loadingMessage.value = 'Syncing new config, please wait...';
    await storage.sync();
    isSavedCheck();
    isLoading.value = false;
  }

  bool saveAllDialog() {
    if (isLoading.value) return false;
    if (!isSavedCheck()) {
      alertDialog(
        'Leave this page?',
        'You have some unsaved changes, are you sure you want to leave without saving?',
        cancelAction: () {
          closeAllDialog();
          init();
          currentContext?.pop();
        },
        cancelText: 'Leave',
        confirmAction: () async {
          closeAllDialog();
          await saveAll(); 
          currentContext?.pop();
        },
        confirmText: 'Save',
      );
      return false;
    } 
    return true;
  }

  var fakultasQueue = QueueActionModel();
  var prodiQueue = QueueActionModel();
  var matprakQueue = QueueActionModel();
  var itemQueue = QueueActionModel();
  final simulated = storage.cached.duplicate();
  bool get isAnyQueued => fakultasQueue.isAnyQueued || prodiQueue.isAnyQueued || matprakQueue.isAnyQueued;

  List simFrom<T>() => T == FakultasModel ? simulated.fakultas : T == ProgramStudiModel ? simulated.programStudi : T == MatprakModel ? simulated.matprak : simulated.item;
  QueueActionModel queueFrom<T>() => T == FakultasModel ? fakultasQueue : T == ProgramStudiModel ? prodiQueue : T == MatprakModel ? matprakQueue : itemQueue;

  bool inDeleteQ<T>(int id) => queueFrom<T>().delete.contains(id);  
  bool inInsertQ<T>(int id) => queueFrom<T>().insert.contains(id);  
  bool inUpdateQ<T>(int id) => queueFrom<T>().update.contains(id);
  
  Map<String, dynamic> compileForm<T>(T model) => 
    model is FakultasModel ? {
      if (model.id > 0) 'id': model.id,
      'name': model.name,
    } : model is ProgramStudiModel ? {
      if (model.id > 0) 'id': model.id,
      'name': model.name,
      'fakultas': model.fakultas,
    } : model is MatprakModel ? {
      if (model.id > 0) 'id': model.id,
      'kode': model.kode,
      'nama': model.nama,
      'is_praktikum': model.isPraktikum,
      'program_studi' : model.programStudi
    } : model is ItemModel ? {
      if (model.id > 0) 'id': model.id,
      'name': model.name,
    } : {};

  Future<bool> pushAction<T>(T qdata, [bool single = false]) async {
    bool r = true;
    final queue = queueFrom<T>();

    final data = qdata as dynamic;
    if (queue.loading.contains(data.id)) return false;

    final qfsped = T == FakultasModel ? getFindCall<FakultasController>()?.qfsped : T == ProgramStudiModel ? getFindCall<ProgramStudiController>()?.qfsped : T == MatprakModel ? getFindCall<MatprakController>()?.qfsped : getFindCall<DaftarBarangController>()?.qfsped;
    final qfsp = T == FakultasModel ? getFindCall<FakultasController>()?.qfsp : T == ProgramStudiModel ? getFindCall<ProgramStudiController>()?.qfsp : T == MatprakModel ? getFindCall<MatprakController>()?.qfsp : getFindCall<DaftarBarangController>()?.qfsp;
    final int id = data.id;

    queue.loading.add(id);
    qfsped?.refresh();

    if (queue.set.contains(data.id)) {
      final isAdding = queue.insert.contains(data.id);
      final isUpdating = queue.update.contains(data.id);
      final isDeleting = queue.delete.contains(data.id);

      if (isDeleting && (isAdding || isUpdating)) {
        await updateDeletedQueueState<T>([data.id], true);
      } else if (isDeleting) {
        final isSuccess = await service.deleteData<T>([qdata]);
        if (isSuccess) {
          await updateDeletedQueueState<T>([data.id]);
        } else {
          r = false;
        }
      } else {
        if (qdata is MatprakModel) {
          final parrent = simulated.getProgramStudi(qdata.programStudi)!;
          if (prodiQueue.insert.contains(parrent.id) || prodiQueue.update.contains(parrent.id)) {
            final isSuccess = await pushAction(parrent, true);
            if (!isSuccess) r = false;
          }
        } else if (qdata is ProgramStudiModel) {
          final parrent = simulated.getFakultas(qdata.fakultas)!;
          if (fakultasQueue.insert.contains(parrent.id) || fakultasQueue.update.contains(parrent.id)) {
            final isSuccess = await pushAction(parrent, true);
            if (!isSuccess) r = false;
          }
        }

        if (isUpdating) {
          final res = await service.upsertData<T>([compileForm<T>(data)]);
          if (res != null) {
            await updateUpdatedQueueState<T>([data.id]);
          } else {
            r = false;
          }
        } else if (isAdding) {
          if (r) {
            final res = await service.upsertData<T>([compileForm<T>(data)]);
            if (res != null) {
              await updateInsertedQueueState<T>([data.id], res);
            } else {
              r = false;
            }
          }
        }
      }
    }

    if (!single && r) {
      if (T == FakultasModel) {
        final queryData = simulated.getFakultas(data.name)?.programStudi.where((p) => prodiQueue.set.contains(p.id) || p.matprak.any((m) => matprakQueue.set.contains(m.id))).toSet() ?? {};
        if (queryData.isNotEmpty) {
          await pushQueuedAction(queryData);
        } else {
          await storage.sync();
        }
      } else if (T == ProgramStudiModel) {
        final queryData = simulated.getProgramStudi(data.name)?.matprak.where((m) => matprakQueue.set.contains(m.id)).toSet() ?? {};
        if (queryData.isNotEmpty) {
          await pushQueuedAction(queryData);
        } else {
          await storage.sync();
        }
      } else {
        await storage.sync();
      }
    }
    
    queue.loading.remove(id);
    qfsp?.onChanged();

    return r;
  }

  Future<bool> pushQueuedAction<T>(Iterable<T> dataSet, [bool single = false]) async {
    bool r = true;
    
    final q = queueFrom<T>();

    final ids = dataSet.map((dynamic v) => v.id as int).toSet().difference(q.loading);

    final qfsped = T == FakultasModel ? getFindCall<FakultasController>()?.qfsped : T == ProgramStudiModel ? getFindCall<ProgramStudiController>()?.qfsped : T == MatprakModel ? getFindCall<MatprakController>()?.qfsped : getFindCall<DaftarBarangController>()?.qfsped;
    final qfsp = T == FakultasModel ? getFindCall<FakultasController>()?.qfsp : T == ProgramStudiModel ? getFindCall<ProgramStudiController>()?.qfsp : T == MatprakModel ? getFindCall<MatprakController>()?.qfsp : getFindCall<DaftarBarangController>()?.qfsp;
    
    final queue = QueueActionModel(
      insert: ids.intersection(q.insert),
      update: ids.intersection(q.update),
      delete: ids.intersection(q.delete),
    );

    final loadingQueue = q.loading;

    await updateDeletedQueueState(queue.delete.intersection({...queue.insert, ...queue.update}), true);
    qfsp?.onChanged();

    queue.insert.removeAll(queue.delete);
    queue.update.removeAll(queue.delete);

    final deleteData = List<T>.from(simFrom<T>().where((dynamic v) => queue.delete.contains(v.id)));

    final set = {...queue.update, ...queue.delete, ...queue.insert}.toSet();

    set.forEach(loadingQueue.add);
    qfsped?.refresh();

    if (queue.delete.isNotEmpty) {
      final isSuccess = await service.deleteData<T>(deleteData);
      if (isSuccess) {
        await updateDeletedQueueState<T>(queue.delete);
      } else {
        r = false;
      }
    } 
    
    final insertData = List<T>.from(simFrom<T>()).where((dynamic v) => queue.insert.contains(v.id));
    final updateData = List<T>.from(simFrom<T>()).where((dynamic v) => queue.update.contains(v.id));
    bool r2 = true;

    if (updateData.isNotEmpty || insertData.isNotEmpty) {
      if (T == MatprakModel) {
        final parrents = updateData.followedBy(insertData).map((v) => (v as MatprakModel).programStudi).toSet().map((v) => simulated.getProgramStudi(v)!).where((v) => prodiQueue.insert.contains(v.id) || prodiQueue.update.contains(v.id));
        if (parrents.isNotEmpty) {
          final isSuccess = await pushQueuedAction(parrents, true);
          if (!isSuccess) r2 = false;
        }
      } else if (T == ProgramStudiModel) {
        final parrents = updateData.followedBy(insertData).map((v) => (v as ProgramStudiModel).fakultas).toSet().map((v) => simulated.getFakultas(v)!).where((v) => fakultasQueue.insert.contains(v.id) || fakultasQueue.update.contains(v.id));
        if (parrents.isNotEmpty) {
          final isSuccess = await pushQueuedAction(parrents, true);
          if (!isSuccess) r2 = false;
        }
      }
      if (!r2) r = false;
    }

    if (updateData.isNotEmpty) {
      if (r2) {
        final data = updateData.map(compileForm).toList();
        final res = await service.upsertData<T>(data);
        if (res != null) {
          await updateUpdatedQueueState<T>(queue.update);
        } else {
          r = false;
        }
      }
    }
    
    
    if (insertData.isNotEmpty) {
      if (r2) {
        final data = insertData.map(compileForm).toList();
        final res = await service.upsertData<T>(data);
        if (res != null) {
          await updateInsertedQueueState<T>(queue.insert, res);
        } else {
          r = false;
        }
      }
    }
    
    if (!single) { 
      if (T == FakultasModel) {
        final queryData = simulated.programStudi.where((p) => prodiQueue.set.difference(prodiQueue.loading).contains(p.id) || p.matprak.any((m) => matprakQueue.set.difference(matprakQueue.loading).contains(m.id))).toSet();
        if (queryData.isNotEmpty) {
          await pushQueuedAction(queryData);
        } else {
          await storage.sync();
        }
      } else if (T == ProgramStudiModel) {
        final queryData = simulated.matprak.where((m) => matprakQueue.set.difference(matprakQueue.loading).contains(m.id)).toSet();
        if (queryData.isNotEmpty) {
          await pushQueuedAction(queryData);
        } else {
          await storage.sync();
        }
      } else {
        await storage.sync();
      }
    }

    set.forEach(loadingQueue.remove);
    qfsp?.onChanged();
    
    return r;
  }

  Future<void> updateDeletedQueueState<T>(Iterable<int> ids, [bool isUpsert = false]) async {
    final queue = queueFrom<T>();
    for (final id in ids.toSet()) {
      if (isUpsert) {
        queue.update.remove(id);
        queue.insert.remove(id);
      }
      queue.loading.remove(id);
      queue.select.remove(id);
      queue.delete.remove(id);
      if (T == FakultasModel) {
        final cids = simulated.fakultas.firstWhereOrNull((v) => v.id == id)?.programStudi.map((v) => v.id);
        if (cids != null) updateDeletedQueueState<ProgramStudiModel>(cids, true);
      } else if (T == ProgramStudiModel) {
        final cids = simulated.programStudi.firstWhereOrNull((v) => v.id == id)?.matprak.map((v) => v.id);
        if (cids != null) updateDeletedQueueState<MatprakModel>(cids, true);
      }
      simulated.removeWhere<T>((v) => v?.id == id);
    }
  }

  Future<void> updateUpdatedQueueState<T>(Iterable<int> ids) async {
    final queue = queueFrom<T>();
    for (final id in ids.toSet()) {
      queue.loading.remove(id);
      queue.update.remove(id);
    }
  }

  Future<void> updateInsertedQueueState<T>(Iterable<int> ids, List<T> newData) async {
    final queue = queueFrom<T>();
    for (final id in ids.toSet()) {
      queue.loading.remove(id);
      queue.insert.remove(id);
      final match = simFrom<T>().firstWhere((v) => v.id == id);
      match.id = T == FakultasModel 
      ? (newData as List<FakultasModel>).firstWhere((v) => v.name == match.name).id 
      : T == ProgramStudiModel 
        ? (newData as List<ProgramStudiModel>).firstWhere((v) => v.name == match.name).id 
        : T == MatprakModel 
          ? (newData as List<MatprakModel>).firstWhere((v) => v.kode == match.kode).id
          : (newData as List<ItemModel>).firstWhere((v) => v.name == match.name).id;
    }
  }
}

class DaftarBarangController extends GetxController {
  GlobalConfigController get config => Get.find<GlobalConfigController>();
  final admin = GlobalConfigService();
  List<ItemModel> get stored => storage.cached.item;
  List<ItemModel> get sim => config.simulated.item;
  final qfsped = RxList<ItemModel>([]);
  
  Iterable<ItemModel> get selectedData => sim.where(inSelected);
  Iterable<ItemModel> get pagedSelectedData => sim.where(inPageSelected);
  
  Set<int> get insertQueue => config.itemQueue.insert;
  Set<int> get updateQueue => config.itemQueue.update;
  Set<int> get deleteQueue => config.itemQueue.delete;
  Set<int> get loadingQueue => config.itemQueue.loading;
  Set<int> get isSelected => config.prodiQueue.select;
  
  Set<int> get simIds => sim.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get pagedIds => qfsped.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get selectedIds => isSelected.difference(loadingQueue);
  Set<int> get pagedSelectedIds => pagedIds.intersection(isSelected);
  Set<int> get simQueued => config.itemQueue.set.intersection(simIds);

  bool inSelected(ItemModel v) => selectedIds.contains(v.id);  
  bool inPageSelected(ItemModel v) => pagedSelectedIds.contains(v.id);  
  bool idInSelected(int id) => selectedIds.contains(id);  
  bool inQueue(int id) => config.itemQueue.set.contains(id);  
  bool inDeleteQ(int id) => config.inDeleteQ<ItemModel>(id);  
  bool inInsertQ(int id) => config.inInsertQ<ItemModel>(id);  
  bool inUpdateQ(int id) => config.inUpdateQ<ItemModel>(id);
  
  bool get isPagedLoading => pagedIds.isEmpty;
  bool get isPagedAnySelected => pagedSelectedIds.isNotEmpty;
  bool get isSimAnyQueued => simQueued.isNotEmpty;
  bool get isSimLoading => simQueued.difference(loadingQueue).isEmpty;
  bool get isPageAnyQueued => pagedIds.any(inQueue);
  bool get isPageSelectedAnyQueued => pagedSelectedIds.any(inQueue);
  bool get areDeleting => deleteQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inDeleteQ) : pagedIds.every(inDeleteQ);
  bool get areInserting => insertQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inInsertQ) : pagedIds.every(inInsertQ);
  bool get areUpdating => updateQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inUpdateQ) : pagedIds.every(inUpdateQ);
  bool get canPagedUndoDelete => !isPagedAnySelected && pagedIds.isNotEmpty && pagedIds.every(inDeleteQ);
  bool get canPagedSelectedUndoDelete => isPagedAnySelected && pagedSelectedIds.every(inDeleteQ);
  bool get canPagedUndoChange => !isPagedAnySelected && pagedIds.isNotEmpty && pagedIds.any(inUpdateQ);
  bool get canPagedSelectedUndoChange => isPagedAnySelected && pagedSelectedIds.any(inUpdateQ);
  bool? get isPageSelected => 
    pagedIds.any(idInSelected)
      ? pagedIds.every(idInSelected)
        ? true : null 
      : false;

  var isLoading = false.obs;
  var isMassLoading = false.obs;
  var canEdit = <int>{};

  @override
  void onInit() {
    super.onInit();
    qfsp.onChanged();
  }

  var pageNum = 1.obs;
  var pageC = NumberPaginatorController();

  late QFSPController<ItemModel> qfsp = QFSPController(
    filter: [
      FilterController(
        filterKey: "action",
        filterList: ['insert', 'update', 'delete'],
        reference: (m) => inInsertQ(m.id) ? 'insert' : inUpdateQ(m.id) ? 'update' : inDeleteQ(m.id) ? 'delete' : '',
        multiSelect: false
      ),
    ],
    onChanged: ([String? itemKey, String? filterKey]) {
      var queried = admin.qfsp.query(sim, qfsp, (v) => [v.name]);
      var filtered = admin.qfsp.filter(queried, qfsp, itemKey, filterKey);
      var sorted = admin.qfsp.sort(filtered, qfsp);
      var paged = admin.qfsp.page(sorted, qfsp, pageNum);
      qfsped.value = paged;
    },
    pageC: pageC,
    dataPerPage: 25
  );
  
  void selectItem(int id, bool state) {
    if (loadingQueue.contains(id)) return;
    state ? isSelected.add(id) : isSelected.remove(id);
    qfsped.refresh();
  }

  void selectPageItem(bool? state) {
    for (var id in pagedIds) {
      if (loadingQueue.contains(id)) continue;
      state == true ? isSelected.add(id) : isSelected.remove(id);
    }
    Future(() => qfsped.refresh());
  }

  void delete(int id) {
    if (loadingQueue.contains(id)) return;
    deleteQueue.add(id);
    qfsped.refresh();
  }

  void undoDelete(int id) {
    if (loadingQueue.contains(id)) return;
    deleteQueue.remove(id);
    qfsped.refresh();
  }

  void deletePageSelectedData() {
    for (final id in pagedSelectedIds) {
      if (loadingQueue.contains(id)) continue;
      if (deleteQueue.contains(id)) continue;
      deleteQueue.add(id);
    }
    qfsped.refresh();
  }

  void undoDeletePageData() {
    for (final id in pagedIds) {
      if (loadingQueue.contains(id)) continue;
      deleteQueue.remove(id);
    }
    qfsped.refresh();
  }

  void undoDeletePageSelectedData() {
    for (final id in pagedSelectedIds) {
      if (loadingQueue.contains(id)) continue;
      deleteQueue.remove(id);
    }
    qfsped.refresh();
  }

  void undoChange(Set<int> ids) {
    for (final id in ids) {
      final source = stored.firstWhereOrNull((v) => v.id == id)?.duplicate();
      if (source != null) {
        updateQueue.remove(id);
        final ref = sim.firstWhere((v) => v.id == id);
        final old = ref.duplicate();

        ref.name = source.name;
        // sim.where((v) => v.id == id).toList().first = source;
      }
    }
    qfsped.refresh();
  }

  void undoChangePageData() => undoChange(pagedIds);

  void undoChangePageSelectedData() => undoChange(pagedSelectedIds);
  
  void pushAction(ItemModel data) async => config.pushAction(data);

  void pushSimAction() => config.pushQueuedAction(sim);

  void pushPageAction() => config.pushQueuedAction(qfsped.value);

  void pushPageSelectedAction() => config.pushQueuedAction(pagedSelectedData);

  void inputDialog([ItemModel? s]) {
    final nameC = TextEditingController(text: s?.name);
    var nameE = Rxn<String>(null);
    final nameF = FocusNode();
    
    final id = s?.id ?? ((insertQueue.lastOrNull ?? 0) - 1);
    ItemModel createModel() => ItemModel(
      id: id, 
      name: nameC.text.trim().capitalCase(),
    );

    bool checkEmptyFields() {
      final model = createModel();
      final list = config.simulated.formatedItem(true);
      nameE.value = nameC.text.isBlank() ? '*required' : model.name.toLowerCase() != s?.name.toLowerCase() && list.contains(model.name.toLowerCase()) ? '*already exist' : null;

      if (nameE.value != null) return false;
      
      nameE.value = null;
      return true;
    }

    nameF.addListener(() {
      if (!nameF.hasFocus) nameC.text = nameC.text.trim().capitalCase();
    });
    
    alertDialog(
      s == null ? 'Add new item' : 'Edit item', 
      null,
      width: 420,
      message: Obx(() => Column(
        children: [
          CustomTextField(
            controller: nameC,
            focusNode: nameF,
            labelText: 'Nama',
            errorText: nameE.value,
            decoration: InputDecoration(hintText: 'e.g. Kabel Jumper'),
          ),
          SizedBox(height: 16)
        ]
      )),
      onPopInvokedWithResult: (didPop, result) => 
        Future.delayed(Duration(milliseconds: 500), () {
          nameF.dispose();
        }),
      confirmText: s == null ? 'add' : 'save',
      confirmAction: () {
        if (!checkEmptyFields()) return;
        closeAllDialog();
        final model = createModel();
        if (s == null) {
          insertQueue.add(id);
          sim.insert(0, model);
        } else {
          s.name = model.name;
          if (s.id > 0) { 
            final isExist = stored.any((v) => v.isEqualTo(s));
            if (isExist) {
              updateQueue.remove(s.id);
            } else {
              updateQueue.add(s.id);
            }
          }
        }
        qfsp.onChanged();
      },
    );
  }
}

class FakultasController extends GetxController {
  GlobalConfigController get config => Get.find<GlobalConfigController>();
  final admin = GlobalConfigService();

  List<FakultasModel> get stored => storage.cached.fakultas;
  List<FakultasModel> get sim => config.simulated.fakultas;
  final qfsped = RxList<FakultasModel>([]);
  
  Iterable<FakultasModel> get selectedData => sim.where(inSelected);
  Iterable<FakultasModel> get pagedSelectedData => sim.where(inPageSelected);
  
  Set<int> get insertQueue => config.fakultasQueue.insert;
  Set<int> get updateQueue => config.fakultasQueue.update;
  Set<int> get deleteQueue => config.fakultasQueue.delete;
  Set<int> get loadingQueue => config.fakultasQueue.loading;
  Set<int> get isSelected => config.prodiQueue.select;
  
  Set<int> get simIds => sim.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get pagedIds => qfsped.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get selectedIds => isSelected.difference(loadingQueue);
  Set<int> get pagedSelectedIds => pagedIds.intersection(isSelected);
  Set<int> get simQueued => config.fakultasQueue.set.intersection(simIds);

  bool inSelected(FakultasModel v) => selectedIds.contains(v.id);  
  bool inPageSelected(FakultasModel v) => pagedSelectedIds.contains(v.id);  
  bool idInSelected(int id) => selectedIds.contains(id);  
  bool inQueue(int id) => config.fakultasQueue.set.contains(id);  
  bool inDeleteQ(int id) => config.inDeleteQ<FakultasModel>(id);  
  bool inInsertQ(int id) => config.inInsertQ<FakultasModel>(id);  
  bool inUpdateQ(int id) => config.inUpdateQ<FakultasModel>(id);
  bool inProdiQueue(FakultasModel f) => f.programStudi.any((pd) => config.prodiQueue.contains(pd.id) || pd.matprak.any((mp) => config.matprakQueue.contains(mp.id)));
  
  bool get isPagedLoading => pagedIds.isEmpty;
  bool get isPagedAnySelected => pagedSelectedIds.isNotEmpty;
  bool get isAnyQueued => config.isAnyQueued;
  bool get isFakultasAnyQueued => config.fakultasQueue.set.difference(loadingQueue).isNotEmpty;
  bool get isSimAnyQueued => simQueued.isNotEmpty || sim.any((f) => f.programStudi.any((pd) => config.prodiQueue.contains(pd.id, true) || pd.matprak.any((mp) => config.matprakQueue.contains(mp.id))));
  bool get isSimLoading => simQueued.difference(loadingQueue).isEmpty;
  bool get isPageAnyQueued => pagedIds.any(inQueue) || qfsped.any((f) => f.programStudi.any((pd) => config.prodiQueue.contains(pd.id, true) || pd.matprak.any((mp) => config.matprakQueue.contains(mp.id))));
  bool get isPageSelectedAnyQueued => pagedSelectedIds.any(inQueue) || pagedSelectedData.any((f) => f.programStudi.any((pd) => config.prodiQueue.contains(pd.id, true) || pd.matprak.any((mp) => config.matprakQueue.contains(mp.id))));
  bool get areDeleting => deleteQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inDeleteQ) : pagedIds.every(inDeleteQ);
  bool get areInserting => insertQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inInsertQ) : pagedIds.every(inInsertQ);
  bool get areUpdating => updateQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inUpdateQ) : pagedIds.every(inUpdateQ);
  bool get areModifying => !isSimAnyQueued && config.matprakQueue.set.isEmpty ? false : isPagedAnySelected ? pagedSelectedData.every(inProdiQueue) && !selectedIds.any(inQueue) : qfsped.every(inProdiQueue) && !pagedIds.any(inQueue);
  bool get canPagedUndoDelete => !isPagedAnySelected && pagedIds.isNotEmpty && pagedIds.every(inDeleteQ);
  bool get canPagedSelectedUndoDelete => isPagedAnySelected && pagedSelectedIds.every(inDeleteQ);
  bool get canPagedUndoChange => !isPagedAnySelected && pagedIds.isNotEmpty && pagedIds.any(inUpdateQ);
  bool get canPagedSelectedUndoChange => isPagedAnySelected && pagedSelectedIds.any(inUpdateQ);
  bool? get isPageSelected => 
    pagedIds.any(idInSelected)
      ? pagedIds.every(idInSelected)
        ? true : null 
      : false;

  var isLoading = false.obs;
  var isMassLoading = false.obs;
  var canEdit = <int>{};

  @override
  void onInit() {
    super.onInit();
    qfsp.onChanged();
  }

  var pageNum = 1.obs;
  var pageC = NumberPaginatorController();

  late QFSPController<FakultasModel> qfsp = QFSPController(
    filter: [
      FilterController(
        filterKey: "action",
        filterList: ['insert', 'update', 'delete', 'modified'],
        reference: (m) => inInsertQ(m.id) ? 'insert' : inUpdateQ(m.id) ? 'update' : inDeleteQ(m.id) ? 'delete' : inProdiQueue(m) ? 'modified' : '',
        multiSelect: false
      ),
    ],
    onChanged: ([String? itemKey, String? filterKey]) {
      var queried = admin.qfsp.query(sim, qfsp, (v) => [v.name]);
      var filtered = admin.qfsp.filter(queried, qfsp, itemKey, filterKey);
      var sorted = admin.qfsp.sort(filtered, qfsp);
      var paged = admin.qfsp.page(sorted, qfsp, pageNum);
      qfsped.value = paged;
    },
    pageC: pageC,
    dataPerPage: 25
  );
  
  void selectItem(int id, bool state) {
    if (loadingQueue.contains(id)) return;
    state ? isSelected.add(id) : isSelected.remove(id);
    qfsped.refresh();
  }

  void selectPageItem(bool? state) {
    for (var id in pagedIds) {
      if (loadingQueue.contains(id)) continue;
      state == true ? isSelected.add(id) : isSelected.remove(id);
    }
    Future(() => qfsped.refresh());
  }

  void delete(int id) {
    if (loadingQueue.contains(id)) return;
    deleteQueue.add(id);
    qfsped.refresh();
  }

  void undoDelete(int id) {
    if (loadingQueue.contains(id)) return;
    deleteQueue.remove(id);
    qfsped.refresh();
  }

  void deletePageSelectedData() {
    for (final id in pagedSelectedIds) {
      if (loadingQueue.contains(id)) continue;
      if (deleteQueue.contains(id)) continue;
      deleteQueue.add(id);
    }
    qfsped.refresh();
  }

  void undoDeletePageData() {
    for (final id in pagedIds) {
      if (loadingQueue.contains(id)) continue;
      deleteQueue.remove(id);
    }
    qfsped.refresh();
  }

  void undoDeletePageSelectedData() {
    for (final id in pagedSelectedIds) {
      if (loadingQueue.contains(id)) continue;
      deleteQueue.remove(id);
    }
    qfsped.refresh();
  }

  void undoChange(Set<int> ids) {
    for (final id in ids) {
      final source = stored.firstWhereOrNull((v) => v.id == id)?.duplicate();
      if (source != null) {
        updateQueue.remove(id);
        final ref = sim.firstWhere((v) => v.id == id);
        final old = ref.duplicate();

        ref.name = source.name;

        if (old.name != source.name) {
          for (final v in ref.programStudi) {
            v.fakultas = source.name;
          }
        }
        // sim.where((v) => v.id == id).toList().first = source;
      }
    }
    qfsp.onChanged();
  }

  void undoChangePageData() => undoChange(pagedIds);

  void undoChangePageSelectedData() => undoChange(pagedSelectedIds);
  
  void pushAction(FakultasModel data) async => config.pushAction(data);

  void pushSimAction() => config.pushQueuedAction(sim);

  void pushPageAction() => config.pushQueuedAction(qfsped.value);

  void pushPageSelectedAction() => config.pushQueuedAction(pagedSelectedData);

  void inputDialog([FakultasModel? s]) {
    final nameC = TextEditingController(text: s?.name);
    
    var nameE = Rxn<String>(null);

    final nameF = FocusNode();
    
    final id = s?.id ?? ((insertQueue.lastOrNull ?? 0) - 1);
    FakultasModel createModel() => FakultasModel(
      id: id, 
      name: nameC.text.trim().capitalCase(),
      programStudi: s?.programStudi ?? [],
    );

    bool checkEmptyFields() {
      final model = createModel();
      final list = config.simulated.formatedFakultas(true);
      nameE.value = nameC.text.isBlank() ? '*required' : !nameC.text.contains(parentheses) ? '*invalid format' : model.name.toLowerCase() != s?.name.toLowerCase() && list.contains(model.name.toLowerCase()) ? '*already exist' : null;

      if (nameE.value != null) return false;
      
      nameE.value = null;
      return true;
    }

    nameF.addListener(() {
      if (!nameF.hasFocus) {
        final temp = nameC.text.trim().capitalCase();
        final abv = parentheses.firstMatch(temp)?.group(1);
        if (abv != null) nameC.text = temp.replaceAll(parentheses, '(${abv.toUpperCase()})');
      }
    });
    
    alertDialog(
      s == null ? 'Add new fakultas' : 'Edit fakultas', 
      null,
      width: 420,
      message: Obx(() => Column(
        children: [
          CustomTextField(
            controller: nameC,
            focusNode: nameF,
            labelText: 'Nama',
            errorText: nameE.value,
            decoration: InputDecoration(hintText: 'e.g. Sekolah Teknik Elektro dan Informatika (STEI)'),
          ),
          SizedBox(height: 16)
        ]
      )),
      onPopInvokedWithResult: (didPop, result) => 
        Future.delayed(Duration(milliseconds: 500), () {
          nameF.dispose();
        }),
      confirmText: s == null ? 'add' : 'save',
      confirmAction: () {
        if (!checkEmptyFields()) return;
        closeAllDialog();
        final model = createModel();
        if (s == null) {
          insertQueue.add(id);
          sim.insert(0, model);
        } else {
          if (s.name != model.name) {
            for (final v in s.programStudi) {
              v.fakultas = model.name;
            }
          }
          s.name = model.name;
          if (s.id > 0) { 
            final isExist = stored.any((v) => v.isEqualTo(s));
            if (isExist) {
              updateQueue.remove(s.id);
            } else {
              updateQueue.add(s.id);
            }
          }
        }
        qfsp.onChanged();
      },
    );
  }
}

class ProgramStudiController extends GetxController {
  final String name = router.state.pathParameters['fakultas']!;
  
  GlobalConfigController get config => Get.find<GlobalConfigController>();
  final admin = GlobalConfigService();
  FakultasModel? get fakultas => config.simulated.getFakultas(name);

  List<ProgramStudiModel> get stored => storage.cached.programStudi;
  List<ProgramStudiModel> get sim => fakultas?.programStudi ?? [];
  final qfsped = RxList<ProgramStudiModel>([]);
  
  Iterable<ProgramStudiModel> get selectedData => sim.where(inSelected);
  Iterable<ProgramStudiModel> get pagedSelectedData => sim.where(inPageSelected);
  
  Set<int> get insertQueue => config.prodiQueue.insert;
  Set<int> get updateQueue => config.prodiQueue.update;
  Set<int> get deleteQueue => config.prodiQueue.delete;
  Set<int> get loadingQueue => config.prodiQueue.loading;
  Set<int> get isSelected => config.prodiQueue.select;
  
  Set<int> get simIds => sim.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get pagedIds => qfsped.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get selectedIds => isSelected.difference(loadingQueue);
  Set<int> get pagedSelectedIds => pagedIds.intersection(isSelected);
  Set<int> get simQueued => config.prodiQueue.set.intersection(simIds);

  bool inSelected(ProgramStudiModel v) => selectedIds.contains(v.id);  
  bool inPageSelected(ProgramStudiModel v) => pagedSelectedIds.contains(v.id);  
  bool idInSelected(int id) => selectedIds.contains(id);  
  bool inQueue(int id) => config.prodiQueue.set.contains(id);  
  bool inDeleteQ(int id) => config.inDeleteQ<ProgramStudiModel>(id);  
  bool inInsertQ(int id) => config.inInsertQ<ProgramStudiModel>(id);  
  bool inUpdateQ(int id) => config.inUpdateQ<ProgramStudiModel>(id);
  bool inMatprakQueue(ProgramStudiModel v) => v.matprak.any((v) => config.matprakQueue.contains(v.id));
  
  bool get isPagedLoading => pagedIds.isEmpty;
  bool get isPagedAnySelected => pagedSelectedIds.isNotEmpty;
  bool get isAnyQueued => config.isAnyQueued;
  bool get isProdiAnyQueued => config.prodiQueue.set.difference(loadingQueue).isNotEmpty;
  bool get isSimAnyQueued => simQueued.isNotEmpty || sim.any((p) => p.matprak.any((m) => config.matprakQueue.contains(m.id)));
  bool get isSimLoading => simQueued.difference(loadingQueue).isNotEmpty;
  bool get isPageAnyQueued => pagedIds.any(inQueue) || qfsped.any((p) => p.matprak.any((m) => config.matprakQueue.contains(m.id)));
  bool get isPageSelectedAnyQueued => pagedSelectedIds.any(inQueue) || pagedSelectedData.any((p) => p.matprak.any((m) => config.matprakQueue.contains(m.id)));
  bool get areDeleting => deleteQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inDeleteQ) : pagedIds.every(inDeleteQ);
  bool get areInserting => insertQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inInsertQ) : pagedIds.every(inInsertQ);
  bool get areUpdating => updateQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inUpdateQ) : pagedIds.every(inUpdateQ);
  bool get areModifying => !isSimAnyQueued ? false : isPagedAnySelected ? pagedSelectedData.every(inMatprakQueue)  && !pagedSelectedIds.any(inQueue) : qfsped.every(inMatprakQueue) && !pagedIds.any(inQueue);
  bool get canPagedUndoDelete => !isPagedAnySelected && pagedIds.isNotEmpty && pagedIds.every(inDeleteQ);
  bool get canPagedSelectedUndoDelete => isPagedAnySelected && pagedSelectedIds.every(inDeleteQ);
  bool get canPagedUndoChange => !isPagedAnySelected && pagedIds.isNotEmpty && pagedIds.any(inUpdateQ);
  bool get canPagedSelectedUndoChange => isPagedAnySelected && pagedSelectedIds.any(inUpdateQ);
  bool get canPagedSelectedEdit => isPagedAnySelected && !pagedSelectedIds.every(inDeleteQ);
  bool? get isPageSelected => 
    pagedIds.any(idInSelected)
      ? pagedIds.every(idInSelected)
        ? true : null 
      : false;

  var isLoading = false.obs;
  var isMassLoading = false.obs;
  var canEdit = <int>{};

  @override
  void onInit() {
    super.onInit();
    qfsp.onChanged();
  }

  @override
  void onClose() {
    Future.microtask(() => getFindCall<FakultasController>()?.qfsped.refresh());
    super.onClose();
  }

  var pageNum = 1.obs;
  var pageC = NumberPaginatorController();

  late QFSPController<ProgramStudiModel> qfsp = QFSPController(
    filter: [
      FilterController(
        filterKey: "action",
        filterList: ['insert', 'update', 'delete', 'modified'],
        reference: (m) => inInsertQ(m.id) ? 'insert' : inUpdateQ(m.id) ? 'update' : inDeleteQ(m.id) ? 'delete' : inMatprakQueue(m) ? 'modified' : '',
        multiSelect: false
      ),
    ],
    onChanged: ([String? itemKey, String? filterKey]) {
      var queried = admin.qfsp.query(sim, qfsp, (v) => [v.name]);
      var filtered = admin.qfsp.filter(queried, qfsp, itemKey, filterKey);
      var sorted = admin.qfsp.sort(filtered, qfsp);
      var paged = admin.qfsp.page(sorted, qfsp, pageNum);
      qfsped.value = paged;
    },
    pageC: pageC,
    dataPerPage: 25
  );
  
  void selectItem(int id, bool state) {
    if (loadingQueue.contains(id)) return;
    state ? isSelected.add(id) : isSelected.remove(id);
    qfsped.refresh();
  }

  void selectPageItem(bool? state) {
    for (var id in pagedIds) {
      if (loadingQueue.contains(id)) continue;
      state == true ? isSelected.add(id) : isSelected.remove(id);
    }
    Future(() => qfsped.refresh());
  }

  void delete(int id) {
    if (loadingQueue.contains(id)) return;
    deleteQueue.add(id);
    qfsped.refresh();
  }

  void undoDelete(int id) {
    if (loadingQueue.contains(id)) return;
    deleteQueue.remove(id);
    qfsped.refresh();
  }

  void deletePageSelectedData() {
    for (final id in pagedSelectedIds) {
      if (loadingQueue.contains(id)) continue;
      if (deleteQueue.contains(id)) continue;
      deleteQueue.add(id);
    }
    qfsped.refresh();
  }

  void undoDeletePageData() {
    for (final id in pagedIds) {
      if (loadingQueue.contains(id)) continue;
      deleteQueue.remove(id);
    }
    qfsped.refresh();
  }

  void undoDeletePageSelectedData() {
    for (final id in pagedSelectedIds) {
      if (loadingQueue.contains(id)) continue;
      deleteQueue.remove(id);
    }
    qfsped.refresh();
  }

  void undoChange(Set<int> ids) {
    for (final id in ids) {
      final source = stored.firstWhereOrNull((v) => v.id == id)?.duplicate();
      if (source != null) {
        updateQueue.remove(id);
        final ref = sim.firstWhere((v) => v.id == id);
        final old = ref.duplicate();

        ref.name = source.name;
        ref.fakultas = source.fakultas;

        if (old.name != source.name) {
          for (final v in ref.matprak) {
            v.programStudi = source.name;
          }
        }
        if (old.fakultas != source.fakultas) transfer(sim, config.simulated.getFakultas(source.fakultas)!.programStudi, ref);
        // sim.where((v) => v.id == id).toList().first = source;
      }
    }
    qfsp.onChanged();
  }

  void undoChangePageData() => undoChange(pagedIds);

  void undoChangePageSelectedData() => undoChange(pagedSelectedIds);

  void transfer(List<ProgramStudiModel> from, List<ProgramStudiModel> to, ProgramStudiModel item) {
    from.removeWhere((v) => v.id == item.id);
    to.insert(0, item);
    isSelected.remove(item.id);
  }
  
  void pushAction(ProgramStudiModel data) async => config.pushAction(data);

  void pushSimAction() => config.pushQueuedAction(sim);

  void pushPageAction() => config.pushQueuedAction(qfsped.value);

  void pushPageSelectedAction() => config.pushQueuedAction(pagedSelectedData);
  
  void inputDialog([ProgramStudiModel? s, bool multi = false]) {
    final data = multi ? pagedSelectedData : null;
    if (multi && data!.isEmpty) return;
    
    final nameC = multi ? null : TextEditingController(text: s?.name);
    final fakultasC = SingleSelectController<String>(s == null ? fakultas!.name : s.fakultas);
    
    var nameE = multi ? null : Rxn<String>(null);
    var fakultasE = Rxn<String>(null);

    final nameF = multi ? null : FocusNode();
    
    final id = s?.id ?? ((insertQueue.lastOrNull ?? 0) - 1);
    ProgramStudiModel createModel() => ProgramStudiModel(
      id: id, 
      name: nameC!.text.trim().capitalCase(),
      fakultas: fakultasC.value ?? fakultas!.name,
      matprak: s?.mataKuliah ?? [],
    );

    bool checkEmptyFields() {
      final model = createModel();
      final list = config.simulated.formatedProgramStudi(true);
      nameE!.value = nameC!.text.isBlank() ? '*required' : !nameC.text.contains(parentheses) ? '*invalid format' : model.name.toLowerCase() != s?.name.toLowerCase() && list.contains(model.name.toLowerCase()) ? '*already exist' : null;
      fakultasE.value = !fakultasC.hasValue ? '*required' : null;

      if (nameE.value != null || fakultasE.value != null) return false;
      
      nameE.value = fakultasE.value = null;
      return true;
    }
    nameF?.addListener(() {
      if (!nameF.hasFocus) {
        final temp = nameC!.text.trim().capitalCase();
        final abv = parentheses.firstMatch(temp)?.group(1);
        if (abv != null) nameC.text = temp.replaceAll(parentheses, '(${abv.toUpperCase()})');
      }
    });
    
    alertDialog(
      multi ? 'Edit ${data!.length} items' : s == null ? 'Add new item' : 'Edit item', 
      null,
      width: 420,
      message: Obx(() => Column(
        children: [
          if (!multi) CustomTextField(
            controller: nameC,
            focusNode: nameF,
            labelText: 'Nama',
            errorText: nameE!.value,
            decoration: InputDecoration(hintText: 'e.g. Matematika (MA)'),
          ),
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fakultas', textScaleFactor: 1.02,),
                  if (fakultasE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                ],
              ),
              DropdownFlutter<String>.search(
                controller: fakultasC,
                listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                noResultFoundText: "Fakultas tidak ditemukan, silahkan pilih opsi yang ada",
                decoration: CustomDropdownDecoration(
                  searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.scaffoldBackgroundColor),
                  closedFillColor: appTheme.inputDecorationTheme.fillColor,
                  expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                ),
                excludeSelected: false,
                items: config.simulated.formatedFakultas(),
                hintText: multi ? 'unchanged' : 'Select faklutas',
                onChanged: (v) {},
              ),
            ]
          ),
          SizedBox(height: 16,)
        ]
      )),
      onPopInvokedWithResult: (didPop, result) => 
        Future.delayed(Duration(milliseconds: 500), () {
          nameF?.dispose();
        }),
      confirmText: s == null && !multi ? 'add' : 'save',
      confirmAction: () {
        if (multi) {
          final list = fakultasC.hasValue ? config.simulated.getFakultas(fakultasC.value!)!.programStudi : null;
          for (final s in data!.toList()) {
            if (deleteQueue.contains(s.id)) continue;
            if ((fakultasC.hasValue && fakultasC.value != s.fakultas)) {
              s.fakultas = fakultasC.value!;
              transfer(sim, list!, s);
            }
            if (s.id > 0) { 
              final isExist = stored.any((v) => v.isEqualTo(s));
              if (isExist) {
                updateQueue.remove(s.id);
              } else {
                updateQueue.add(s.id);
              }
            }
          }
        } else {
          if (!checkEmptyFields()) return;
          final model = createModel();
          if (s != null && s.name == model.name && s.fakultas == model.fakultas) return;
          final list = config.simulated.getFakultas(model.fakultas)!.programStudi;
          if (s == null) {
            insertQueue.add(id);
            list.insert(0, model);
          } else {
            if (s.name != model.name) {
              for (final v in s.matprak) {
                v.programStudi = model.name;
              }
            }
            s.name = model.name;
            s.fakultas = model.fakultas;
            if (model.fakultas != fakultas!.name) transfer(sim, list, model);
            if (s.id > 0) { 
              final isExist = stored.any((v) => v.isEqualTo(s));
              if (isExist) {
                updateQueue.remove(s.id);
              } else {
                updateQueue.add(s.id);
              }
            }
          }
        }
        closeAllDialog();
        qfsp.onChanged();
      },
    );
  }

  void selectedPageInputDialog() {
    inputDialog(null, true);
  }
}

class MatprakController extends GetxController {
  final String name = router.state.pathParameters['program_studi']!;

  GlobalConfigController get config => Get.find<GlobalConfigController>();
  final admin = GlobalConfigService(); 
  ProgramStudiModel? get programStudi => config.simulated.getProgramStudi(name);

  List<MatprakModel> get stored => storage.cached.matprak;
  List<MatprakModel> get sim => programStudi?.matprak ?? [];
  final qfsped = RxList<MatprakModel>([]);
  
  Iterable<MatprakModel> get selectedData => sim.where(inSelected);
  Iterable<MatprakModel> get pagedSelectedData => sim.where(inPageSelected);
  
  Set<int> get insertQueue => config.matprakQueue.insert;
  Set<int> get updateQueue => config.matprakQueue.update;
  Set<int> get deleteQueue => config.matprakQueue.delete;
  Set<int> get loadingQueue => config.matprakQueue.loading;
  Set<int> get isSelected => config.prodiQueue.select;
  
  Set<int> get simIds => sim.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get pagedIds => qfsped.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get selectedIds => isSelected.difference(loadingQueue);
  Set<int> get pagedSelectedIds => pagedIds.intersection(isSelected);
  Set<int> get simQueued => config.matprakQueue.set.intersection(simIds);

  bool inSelected(MatprakModel v) => selectedIds.contains(v.id);  
  bool inPageSelected(MatprakModel v) => pagedSelectedIds.contains(v.id);  
  bool idInSelected(int id) => selectedIds.contains(id);  
  bool inQueue(int id) => config.matprakQueue.set.contains(id);  
  bool inDeleteQ(int id) => config.inDeleteQ<MatprakModel>(id);  
  bool inInsertQ(int id) => config.inInsertQ<MatprakModel>(id);  
  bool inUpdateQ(int id) => config.inUpdateQ<MatprakModel>(id);
  
  bool get isPagedLoading => pagedIds.isEmpty;
  bool get isPagedAnySelected => pagedSelectedIds.isNotEmpty;
  bool get isAnyQueued => config.isAnyQueued;
  bool get isMatprakAnyQueued => config.matprakQueue.set.difference(loadingQueue).isNotEmpty;
  bool get isSimAnyQueued => simQueued.isNotEmpty;
  bool get isPageAnyQueued => pagedIds.any(inQueue);
  bool get isPageSelectedAnyQueued => pagedSelectedIds.any(inQueue);
  bool get areDeleting => deleteQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inDeleteQ) : pagedIds.every(inDeleteQ);
  bool get areInserting => insertQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inInsertQ) : pagedIds.every(inInsertQ);
  bool get areUpdating => updateQueue.isEmpty ? false : isPagedAnySelected ? selectedIds.every(inUpdateQ) : pagedIds.every(inUpdateQ);
  bool get canPagedUndoDelete => !isPagedAnySelected && pagedIds.isNotEmpty && pagedIds.every(inDeleteQ);
  bool get canPagedSelectedUndoDelete => isPagedAnySelected && pagedSelectedIds.every(inDeleteQ);
  bool get canPagedUndoChange => !isPagedAnySelected && pagedIds.isNotEmpty && pagedIds.any(inUpdateQ);
  bool get canPagedSelectedUndoChange => isPagedAnySelected && pagedSelectedIds.any(inUpdateQ);
  bool get canPagedSelectedEdit => isPagedAnySelected && !pagedSelectedIds.every(inDeleteQ);
  bool? get isPageSelected => 
    pagedIds.any(idInSelected)
      ? pagedIds.every(idInSelected)
        ? true : null 
      : false;

  var isLoading = false.obs;
  var isMassLoading = false.obs;
  var canEdit = <int>{};

  @override
  void onInit() {
    super.onInit();
    qfsp.onChanged();
  }

  @override void onClose() {
    Future.microtask(() => getFindCall<ProgramStudiController>()?.qfsped.refresh());
    super.onClose();
  }

  var pageNum = 1.obs;
  var pageC = NumberPaginatorController();

  late QFSPController<MatprakModel> qfsp = QFSPController(
    filter: [
      FilterController(
        filterKey: "type",
        filterList: ['mata kuliah', 'praktikum', 'keduanya'],
        reference: (m) => m.type,
        multiSelect: false
      ),
      FilterController(
        filterKey: "action",
        filterList: ['insert', 'update', 'delete'],
        reference: (m) => inInsertQ(m.id) ? 'insert' : inUpdateQ(m.id) ? 'update' : inDeleteQ(m.id) ? 'delete' : '',
        multiSelect: false
      ),
    ],
    onChanged: ([String? itemKey, String? filterKey]) {
      var queried = admin.qfsp.query(sim, qfsp, (v) => [v.nama, v.kode]);
      var filtered = admin.qfsp.filter(queried, qfsp, itemKey, filterKey);
      var sorted = admin.qfsp.sort(filtered, qfsp);
      var paged = admin.qfsp.page(sorted, qfsp, pageNum);
      qfsped.value = paged;
    },
    pageC: pageC,
    dataPerPage: 25
  );

  void selectItem(int id, bool state) {
    if (loadingQueue.contains(id)) return;
    state ? isSelected.add(id) : isSelected.remove(id);
    qfsped.refresh();
  }

  void selectPageItem(bool? state) {
    for (var id in pagedIds) {
      if (loadingQueue.contains(id)) continue;
      state == true ? isSelected.add(id) : isSelected.remove(id);
    }
    Future(() => qfsped.refresh());
  }

  void delete(int id) {
    if (loadingQueue.contains(id)) return;
    deleteQueue.add(id);
    qfsped.refresh();
  }

  void undoDelete(int id) {
    if (loadingQueue.contains(id)) return;
    deleteQueue.remove(id);
    qfsped.refresh();
  }

  void deletePageSelectedData() {
    for (final id in pagedSelectedIds) {
      if (loadingQueue.contains(id)) continue;
      if (deleteQueue.contains(id)) continue;
      deleteQueue.add(id);
    }
    qfsped.refresh();
  }

  void undoDeletePageData() {
    for (final id in pagedIds) {
      if (loadingQueue.contains(id)) continue;
      deleteQueue.remove(id);
    }
    qfsped.refresh();
  }

  void undoDeletePageSelectedData() {
    for (final id in pagedSelectedIds) {
      if (loadingQueue.contains(id)) continue;
      deleteQueue.remove(id);
    }
    qfsped.refresh();
  }

  void reset() {
    sim.clear();
    sim.addAll(stored.map((v) => v.duplicate()));
  }

  void undoChange(Set<int> ids) {
    for (final id in ids) {
      final source = stored.firstWhereOrNull((v) => v.id == id)?.duplicate();
      if (source != null) {
        updateQueue.remove(id);
        final ref = sim.firstWhere((v) => v.id == id);
        final old = ref.duplicate();

        if (old.programStudi != source.programStudi) {
          transfer(sim, config.simulated.getProgramStudi(source.programStudi)!.matprak, source);
        } else {
          ref.kode = source.kode;
          ref.nama = source.nama;
          ref.isPraktikum = source.isPraktikum;
        }
      }
    }
    qfsp.onChanged();
  }

  void undoChangePageData() => undoChange(pagedIds);

  void undoChangePageSelectedData() => undoChange(pagedSelectedIds);

  void setType(MatprakModel s, bool? isPraktikum) {
    s.isPraktikum = isPraktikum;
    if (!insertQueue.contains(s.id)) {
      if (stored.any(s.isEqualTo)) {
        updateQueue.remove(s.id);
      } else {
        updateQueue.add(s.id);
      }
    }
    qfsp.onChanged();
  }

  void setPagedSelectedType(bool? isPraktikum) {
    for (final s in pagedSelectedData) {
      if (deleteQueue.contains(s.id)) continue;
      s.isPraktikum = isPraktikum;
      if (insertQueue.contains(s.id)) continue;
      if (stored.any(s.isEqualTo)) {
        updateQueue.remove(s.id);
      } else {
        updateQueue.add(s.id);
      }
    }
    qfsp.onChanged();
  }
  
  void pushAction(MatprakModel data) async => config.pushAction(data);

  void pushSimAction() => config.pushQueuedAction(sim);

  void pushPageAction() => config.pushQueuedAction(qfsped.value);

  void pushPageSelectedAction() => config.pushQueuedAction(pagedSelectedData);

  void inputDialog([MatprakModel? s, bool multi = false]) {
    final data = multi ? pagedSelectedData : null;
    if (multi && data!.isEmpty) return;

    String? ip = data?.first.type;
    bool? alltypeSame = data?.every((v) => v.isPraktikum == data.first.isPraktikum);

    final type = SingleSelectController<String>(multi ? !alltypeSame! ? null : ip : s?.type);
    final programStudiC = SingleSelectController<String>(s == null ? programStudi!.name : s.programStudi);

    var kodeE = multi ? null : Rxn<String>(null);
    var namaE = multi ? null : Rxn<String>(null);
    var programStudiE = Rxn<String>(null);
    var typeE = Rxn<String>(null);

    final kode = multi ? null : TextEditingController(text: s?.kode ?? (parentheses.firstMatch(programStudi!.name)?.group(1)));
    final nama = multi ? null : TextEditingController(text: s?.nama);
    
    final kodeF = multi ? null : FocusNode();
    final namaF = multi ? null : FocusNode();
  
    final id = s?.id ?? ((insertQueue.lastOrNull ?? 0) - 1);
    MatprakModel createModel() => MatprakModel(
      id: id, 
      kode: kode!.text.trim().toUpperCase(),
      nama: nama!.text.trim().capitalCase(),
      programStudi: programStudiC.value!,
      isPraktikum: type.value == 'keduanya' ? null : type.value == 'praktikum'
    );

    bool checkEmptyFields() {
      final model = createModel();
      final kodes = config.simulated.matprak.map((v) => v.kode.toLowerCase());
      final namas = config.simulated.matprak.map((v) => v.nama.toLowerCase());
      kodeE!.value = kode!.text.isBlank() ? '*required' : model.kode.toLowerCase() != s?.kode.toLowerCase() && kodes.contains(model.kode.toLowerCase()) ? '*already exist' : null;
      namaE!.value = nama!.text.isBlank() ? '*required' : model.nama.toLowerCase() != s?.nama.toLowerCase() && namas.contains(model.nama.toLowerCase()) ? '*already exist' : null;
      programStudiE.value = !programStudiC.hasValue ? '*required' : null;
      typeE.value = !type.hasValue ? '*required' : null;

      if (kodeE.value != null || namaE.value != null || programStudiE.value != null || typeE.value != null) return false;
      
      kodeE.value = namaE.value = programStudiE.value = typeE.value = null;
      return true;
    }
    
    kodeF?.addListener(() {
      if (!kodeF.hasFocus) kode?.text = kode.text.trim().toUpperCase();
    });

    namaF?.addListener(() {
      if (!namaF.hasFocus) nama?.text = nama.text.trim().capitalCase();
    });
    
    alertDialog(
      multi ? 'Edit ${data!.length} items' : s == null ? 'Add new item' : 'Edit item', 
      null,
      width: 420,
      message: Obx(() => Column(
        children: [
          if (!multi) CustomTextField(
            controller: kode,
            focusNode: kodeF,
            labelText: 'Kode',
            errorText: kodeE!.value,
          ),
          if (!multi) CustomTextField(
            controller: nama,
            focusNode: namaF,
            labelText: 'Nama',
            errorText: namaE!.value,
          ),
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Program Studi', textScaleFactor: 1.02,),
                  if (programStudiE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                ],
              ),
              DropdownFlutter<String>.search(
                controller: programStudiC,
                listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                noResultFoundText: "Program Studi tidak ditemukan, silahkan pilih opsi yang ada",
                decoration: CustomDropdownDecoration(
                  searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.scaffoldBackgroundColor),
                  closedFillColor: appTheme.inputDecorationTheme.fillColor,
                  expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                ),
                excludeSelected: false,
                items: config.simulated.getFakultas(programStudi!.fakultas)?.formatedProgramStudi(),
                hintText: multi ? 'unchanged' : 'select program studi',
                onChanged: (v) {},
              ),
            ]
          ),
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Type', textScaleFactor: 1.02,),
                  if (typeE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                ],
              ),
              DropdownFlutter<String>(
                controller: type,
                listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                decoration: CustomDropdownDecoration(
                  closedFillColor: appTheme.inputDecorationTheme.fillColor,
                  expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                  closedBorder: typeE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                ),
                excludeSelected: false,
                items: ['mata kuliah', 'praktikum', "keduanya"],
                hintText: multi ? 'unchanged' : 'select type',
                onChanged: (v) {},
              ),
            ],
          ),
          SizedBox(height: 16,)
        ]
      )),
      onPopInvokedWithResult: (didPop, result) => 
        Future.delayed(Duration(milliseconds: 500), () {
          kodeF?.dispose();
          namaF?.dispose();
        }),
      confirmText: s == null && !multi ? 'add' : 'save',
      confirmAction: () {
        if (multi) {
          final list = programStudiC.hasValue ? config.simulated.getProgramStudi(programStudiC.value!)!.matprak : null;
          for (final s in data!.toList()) {
            if (deleteQueue.contains(s.id)) continue;
            if (type.hasValue && type.value != ip) {
              s.isPraktikum = type.value == 'keduanya' ? null : type.value == 'praktikum';
            }
            if ((programStudiC.hasValue && programStudiC.value != s.programStudi)) {
              s.programStudi = programStudiC.value!;
              transfer(sim, list!, s);
            }
            if (s.id > 0) { 
              final isExist = stored.any((v) => v.isEqualTo(s));
              if (isExist) {
                updateQueue.remove(s.id);
              } else {
                updateQueue.add(s.id);
              }
            }
          }
        } else {
          if (!checkEmptyFields()) return;
          final model = createModel();
          final list = config.simulated.getProgramStudi(model.programStudi)!.matprak;
          if (s == null) {
            insertQueue.add(id);
            list.insert(0, model);
          } else {
            s.kode = model.kode;
            s.nama = model.nama;
            s.programStudi = model.programStudi;
            s.isPraktikum = type.value == 'keduanya' ? null : type.value == 'praktikum';
            if (model.programStudi != programStudi) transfer(sim, list, model);
            if (s.id > 0) { 
              final isExist = stored.any((v) => v.isEqualTo(s));
              if (isExist) {
                updateQueue.remove(s.id);
              } else {
                updateQueue.add(s.id);
              }
            }
          }
        }
        closeAllDialog();
        qfsp.onChanged();
      },
    );
  }

  void selectedPageInputDialog() {
    inputDialog(null, true);
  }

  void transfer(List<MatprakModel> from, List<MatprakModel> to, MatprakModel item) {
    from.removeWhere((v) => v.id == item.id);
    to.insert(0, item);
    isSelected.remove(item.id);
  }
}