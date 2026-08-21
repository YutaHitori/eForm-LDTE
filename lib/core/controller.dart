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
  var isSyncing = false.obs;
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
  var isObscured = RxBool(true);

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

  final cara = storage.cached.globalConfig.caraPinjam ?? "Didn't exist, please refresh browser or contact our Line OA";
  List<String> get fakultasList => storage.cached.formatedFakultas();

  Rxn<XFile> idCard = Rxn<XFile>(ImagePickerService.lastImages['idCard']); 

  final namaC = TextEditingController();
  final nimC = TextEditingController();
  final fakultasC = SingleSelectController<String>(null);
  final prodiC = SingleSelectController<String>(null);
  final dosenC = TextEditingController();
  final nipDosenC = TextEditingController();
  final ketuaC = TextEditingController();
  final nipKetuaC = TextEditingController();
  final barangC = <TextEditingController>[TextEditingController()].obs;
  final barangDC = <SingleSelectController<String>>[SingleSelectController<String>('custom')].obs;
  final banyakC = <SingleSelectController<int>>[SingleSelectController<int>(null)].obs;
  final mulaiC = TextEditingController();
  final akhirC = TextEditingController();

  final namaF = FocusNode();
  final nimF = FocusNode();
  final dosenF = FocusNode();
  final nipDosenF = FocusNode();
  final ketuaF = FocusNode();
  final nipKetuaF = FocusNode();

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
    if (!namaC.text.isBlank()) 'nama' : namaC.text.trim().capitalCase(false),
    if (!nimC.text.isBlank()) 'nim' : nimC.text.trim(),
    if (mulaiC.text.toDateTime() != null) 'mulai' : mulaiC.text.trim(),
    if (akhirC.text.toDateTime() != null) 'akhir' : akhirC.text.trim(),
    'barang' : barangC.value.map((e) => e.text.trim().capitalCase()).toList(),
    'banyak' : banyakC.value.map((e) => e.value).toList(),
  };

  Map<String, dynamic> get form => {
    ...dbform,
    if (fakultasC.hasValue) 'fakultas' : regexp.firstMatch(fakultasC.value ?? '')?.group(1),
    if (prodiC.hasValue) 'prodi' : prodiC.value?.replaceAll(RegExp(r'\((.*?)\)'), '').trim(),
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

  void showReminderDialog() {
    var remindMe = storage.cached.userPreference.remindPeminjamanPeralatan.obs;
    if (remindMe.value) {
      alertDialog(
        'Cara Pengisisan Formulir Peminjaman Peralatan:',
        null,
        message: Column(
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
                    child: Text(cara, style: TextStyle(fontSize: 12.8)),
                  )
                )
              ),
            ),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Switch(value: remindMe.value, onChanged: (v) {
                  remindMe.value = v;
                  storage.cached.userPreference.remindPeminjamanPeralatan = v;
                  storage.save();
                })
              ],
            )),
          ],
        ),
        titleFontSize: 20,
      );
    }
  }
  
  void setProdi() {
    if (!fakultasC.hasValue) return;
    prodiC.value = null;
    prodiList.value = storage.cached.getFakultas(fakultasC.value!)?.formatedProgramStudi() ?? [];
  }

  var namaE = Rxn<String>(null); 
  var nimE = Rxn<String>(null); 
  var mulaiE = Rxn<String>(null); 
  var akhirE = Rxn<String>(null); 
  var barangE = RxList<String?>([null]); 
  var banyakE = RxList<String?>([null]); 
  var idCardE = Rxn<String>(null); 

  bool checkEmptyFields([bool reqId = true]) {
    barangE.value = barangC.map((e) => e.text.isBlank() ? '*required' : null).toList();
    banyakE.value = banyakC.map((e) => !e.hasValue ? '*required' : null).toList();
    namaE.value = namaC.text.isBlank () ? '*required' : null;
    nimE.value = nimC.text.isBlank () ? '*required' : null;
    final mulai = mulaiC.text.toDateTime();
    final akhir = akhirC.text.toDateTime();
    mulaiE.value = mulaiC.text.isBlank() ? '*required' : mulai == null ? '*invalid' : akhir != null && mulai.isAfter(akhir) ? '*melebihi tgl pengembalian' : null;
    akhirE.value = akhirC.text.isBlank() ? '*required' : akhir == null ? '*invalid' : mulai != null && akhir.isBefore(mulai) ? '*kurang dari tgl pinjam' : null;
    if (reqId) idCardE.value = idCard.value == null ? '*required' : null;
    
    if (barangE.any((v) => v != null) || banyakE.any((v) => v != null) || namaE.value != null || nimE.value != null || mulaiE.value != null || akhirE.value != null || (idCardE.value != null && reqId)) return false;
   
    barangE.value.fillRange(0, barangE.value.length, null);
    banyakE.value.fillRange(0, banyakE.value.length, null);
    namaE.value = nimE.value = mulaiE.value = akhirE.value = idCardE.value = null;
    return true;
  }
  
  var lastForm = <String, dynamic>{};
  void submit() async {
  if (!checkEmptyFields()) return;
    isLoading.value = true;
    final savedFile = await service.compilePDF(form, await idCard.value?.readAsBytes());
    if (savedFile != null) {
      final fileName = "Form_Peminjaman-${DateTime.now().millisecondsSinceEpoch}.pdf";
      service.preview(savedFile, fileName, (f) async {
        if (lastForm.entries.every((e) => dbform[e.key].toString() == e.value.toString())) {
          f();
          return;
        }
        isLoading.value = true;
        final isSuccess = await service.submitForm(dbform);
        if (isSuccess) {
          lastForm = dbform;
          f();
        }
        isLoading.value = false;
      }, isLoading);
    }
    isLoading.value = false;
  }
} 

class SuratKeteranganPraktikumController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
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
    namaMatkulF.dispose();
    kodeMatkulF.dispose();
    namaPraktikumF.dispose();
    kodePraktikumF.dispose();
  }

  var isLoading = false.obs;
  var message = RxnString(null);

  final cara = storage.cached.globalConfig.caraKeterangan ?? "Didn't exist, please refresh browser or contact our Line OA";
  final service = SuratKeteranganPraktikumService();
  List<String> get matkulList => storage.cached.formatedMataKuliah();
  List<String> get praktikumList => storage.cached.formatedPraktikum();

  void showReminderDialog() {
    var remindMe = storage.cached.userPreference.remindSuratKeteranganPraktikum.obs;
    if (remindMe.value) {
      alertDialog(
        'Cara Pengisisan Formulir Surat Keterangan Praktikum:',
        null,
        message: Column(
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
                    child: Text(cara, style: TextStyle(fontSize: 12.8)),
                  )
                )
              ),
            ),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Switch(value: remindMe.value, onChanged: (v) {
                  remindMe.value = v;
                  storage.cached.userPreference.remindSuratKeteranganPraktikum = v;
                  storage.save();
                })
              ],
            )),
          ],
        ),
        titleFontSize: 20,
      );
    }
  }

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

  final namaC = <TextEditingController>[TextEditingController()].obs;
  final nimC = <TextEditingController>[TextEditingController()].obs;
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

  var namaE = RxList<String?>([null]); 
  var nimE = RxList<String?>([null]); 
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

  final namaF = FocusNode();
  final namaMatkulF = FocusNode();
  final kodeMatkulF = FocusNode();
  final namaPraktikumF = FocusNode();
  final kodePraktikumF = FocusNode();

  var prodiList = <String>[].obs;

  Rxn<XFile> bukti = Rxn<XFile>(ImagePickerService.lastImages['bukti']); 

  Map<String, dynamic> get form => {
    'nama' : namaC.value.map((e) => e.text.trim().capitalCase()).toList(),
    'nim' : nimC.value.map((e) => e.text.trim()).toList(),
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
    namaE.value = namaC.map((e) => e.text.isBlank() ? '*required' : null).toList();
    nimE.value = nimC.map((e) => e.text.isBlank() ? '*required' : null).toList();
    matkulE.value = !matkul.hasValue ? '*required' : null;
    namaMatkulE.value = matkul.value == 'Lainnya...' && namaMatkul.text.isBlank () ? '': null;
    kodeMatkulE.value = matkul.value == 'Lainnya...' && kodeMatkul.text.isBlank () ? '': null;
    praktikumE.value = !praktikum.hasValue ? '*required' : null;
    namaPraktikumE.value = praktikum.value == 'Lainnya...' && namaPraktikum.text.isBlank () ? '': null;
    kodePraktikumE.value = praktikum.value == 'Lainnya...' && kodePraktikum.text.isBlank () ? '': null;
    modulE.value = !modul.hasValue ? '' : null ;
    dateE.value = dateC.text.isBlank() ? '*required' : dateC.text.toDateTime() == null ? '*invalid' : null;
    final isInvalid = timeStartC.value != null && timeEndC.value != null && timeStartC.value!.isAfter(timeEndC.value!);
    timeStartE.value = timeStartC.value == null ? '*required' : isInvalid ? '*waktu mulai melebihi waktu selesai' : null;
    timeEndE.value = timeEndC.value == null ? '*required' : isInvalid ? '*waktu mulai melebihi waktu selesai' : null;
    if (reqImage) buktiE.value = bukti.value == null ? '*required' : null;

    if (namaE.value.any((v) => v != null) || nimE.value.any((v) => v != null) || 
      matkulE.value != null || namaMatkulE.value != null || kodeMatkulE.value != null || 
      praktikumE.value != null || namaPraktikumE.value != null || kodePraktikumE.value != null || 
      modulE.value != null || dateE.value != null || timeStartE.value != null || 
      timeEndE.value != null || (reqImage && buktiE.value != null)) return false;

    namaE.value.fillRange(0, namaE.value.length, null);
    nimE.value.fillRange(0, nimE.value.length, null);
    matkulE.value = namaMatkulE.value = kodeMatkulE.value = praktikumE.value = namaPraktikumE.value = kodePraktikumE.value = modulE.value = dateE.value = timeStartE.value = timeEndE.value = buktiE.value = null;
    return true;
  }

  void submit() async {
    if (!checkEmptyFields()) return;
    final uriMessage = "Saya telah mengirimkan formulir surat keterangan praktikum atas nama ${(form['nama'] as List<String>).join(', ')}: https://ldte-stei-itb.vercel.app/admin/surat-keterangan";
    print(uriMessage);
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
} 

class PertukaranJadwalPraktikumController extends GetxController {
  var isLoading = false.obs;

  final service = SuratKeteranganPraktikumService();
  
  final cara = storage.cached.globalConfig.caraPertukaran ?? "Didn't exist, please refresh browser or contact our Line OA";
  List<String> get praktikumList => storage.cached.formatedPraktikum();

  void showReminderDialog() {
    var remindMe = storage.cached.userPreference.remindPertukaranJadwal.obs;
    if (remindMe.value) {
      alertDialog(
        'Cara Pengisisan Formulir Pergantian Jadwal Praktikum:',
        null,
        message: Column(
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
                    child: Text(cara, style: TextStyle(fontSize: 12.8)),
                  )
                )
              ),
            ),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Switch(value: remindMe.value, onChanged: (v) {
                  remindMe.value = v;
                  storage.cached.userPreference.remindPertukaranJadwal = v;
                  storage.save();
                })
              ],
            )),
          ],
        ),
        titleFontSize: 20,
      );
    }
  }

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

  String get message => '''Silahkan chat sesuai template dibawah ini.
----------------------------------------
Pertukaran Jadwal Praktikum
PRAKTIKAN
Nama : ${namaC.text.trim().capitalCase(false)}
NIM : ${nimC.text.trim()}

JADWAL SEBELUM PERTUKARAN
Praktikum : ${praktikum.value == 'Lainnya...' ? '${kodePraktikum.text.trim().toUpperCase()} ${namaPraktikum.text.trim().capitalCase()}' : praktikum.value}
Modul : ${modul.value}
Hari/Tanggal : ${dateC.text.toDateTime()?.toDateFormatString()}

MENGGANTIKAN PRAKΤΙΚΑΝ
Nama: ${namaPC.text.trim().capitalCase(false)}
NIM : ${nimPC.text.trim()}

MENGIKUTI PRAKTIKUM
Praktikum : ${praktikum.value == 'Lainnya...' ? '${kodePraktikum.text.trim().toUpperCase()} ${namaPraktikum.text.trim().capitalCase()}' : praktikum.value}
Modul : ${modul.value}
Hari/Tanggal : ${datePC.text.toDateTime()?.toDateFormatString()}
----------------------------------------
Pertukaran diperbolehkan setelah ada chat konfirmasi dari LDTE.''';

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
      namaPraktikumE.value = praktikum.value == 'Lainnya...' && namaPraktikum.text.isBlank () ? '': null;
      kodePraktikumE.value = praktikum.value == 'Lainnya...' && kodePraktikum.text.isBlank () ? '': null;
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
    print(message);
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
        dismissible: false,
        confirmText: 'Close Page',
        confirmAction: () {
          currentContext?.go(NamedRoute.homepage);
        },
      );
    } else {
      alertDialog('Error', 'Device is not synced.');
    }
    isLoading.value = false;
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
    qfsped.value.forEach((v) => state == true ? isSelected.add(v.id) : isSelected.remove(v.id));
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
    barangDC.value = List.generate(submission.barang.length, (i) => SingleSelectController<String>('custom'));
    barangC.value = List.generate(submission.barang.length, (i) => TextEditingController(text: submission.barang[i]));
    barangE.value = List.generate(submission.barang.length, (i) => null);
    banyakC.value = List.generate(submission.banyak.length, (i) => SingleSelectController<int>(submission.banyak[i]));
    banyakE.value = List.generate(submission.banyak.length, (i) => null);
    mulaiC.text = submission.mulai.toDateString();
    akhirC.text = submission.akhir.toDateString();
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
    qfsped.value.forEach((v) => state == true ? isSelected.add(v.id) : isSelected.remove(v.id));
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

    namaC.value = List.generate(submission.nama.length, (i) => TextEditingController(text: submission.nama[i]));
    namaE.value = List.generate(submission.nama.length, (i) => null);
    nimC.value = List.generate(submission.nim.length, (i) => TextEditingController(text: submission.nim[i]));
    nimE.value = List.generate(submission.nim.length, (i) => null);
    
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
    caraPinjamSaved.value = caraPinjam.text == storage.cached.globalConfig.caraPinjam;
    caraKeteranganSaved.value = caraKeterangan.text == storage.cached.globalConfig.caraKeterangan;
    caraPertukaranSaved.value = caraPertukaran.text == storage.cached.globalConfig.caraPertukaran;
    isSaved.value = lineOASaved.value && nomorSuratSaved.value && namaKepalaLDTESaved.value && nipKepalaLDTESaved.value && caraPinjamSaved.value;
    return isSaved.value && !isAnyQueued && !itemQueue.isAnyQueued;
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

  Map<String, dynamic> get form {
    lineOA.text = lineOA.text.trim().toLowerCase();
    if (lineOA.text[0] == '@') lineOA.text.substring(1);
    nomorSurat.text = nomorSurat.text.trim().toUpperCase();
    namaKepalaLDTE.text = namaKepalaLDTE.text.trim().capitalCase();
    nipKepalaLDTE.text = nipKepalaLDTE.text.trim();
    return {
      if (lineOA.text != storage.cached.globalConfig.lineOALDTE) 'lineoa_ldte' : lineOA.text,
      if (nomorSurat.text != storage.cached.globalConfig.nomorSurat) 'nomor_surat' : nomorSurat.text,
      if (namaKepalaLDTE.text != storage.cached.globalConfig.namaKepalaLDTE) 'nama_kepala_ldte' : namaKepalaLDTE.text,
      if (nipKepalaLDTE.text != storage.cached.globalConfig.nipKepalaLDTE) 'nip_kepala_ldte' : nipKepalaLDTE.text,
      if (caraPinjam.text != storage.cached.globalConfig.caraPinjam) 'cara_pinjam' : caraPinjam.text,
      if (caraKeterangan.text != storage.cached.globalConfig.caraKeterangan) 'cara_keterangan' : caraKeterangan.text,
      if (caraPertukaran.text != storage.cached.globalConfig.caraPertukaran) 'cara_pertukaran' : caraPertukaran.text,
    };
  }

  void save(String? key, RxBool canEdit) async {
    final message = key == 
    'lineoa_ldte' ? 'line official account' : key == 
    'lineoa_ldte' ? 'line official account' : key == 
    'nomor_surat' ? 'nomor surat' : key == 
    'nama_kepala_ldte' ? 'nama kepala LDTE' : key == 
    'nip_kepala_ldte' ? 'nim kepala LDTE' : key == 
    'cara_pinjam' ? 'cara pengisian formulir peminjaman peralatan' : key == 
    'cara_keterangan' ? 'cara pengisian surat keterangan' : key == 
    'cara_pertukaran' ? 'cara pengisian formulir pertukaran' : 'unknown';
    
    loadingMessage.value = 'Saving $message, please wait...';
    isLoading.value = true;
    final isSuccess = await service.updateGlobalConfig(key == null ? form : {key : form[key]});
    if (isSuccess) {
      snackbar('Success!', '$message updated');
      loadingMessage.value = 'Syncing new config, please wait...';
      await storage.sync();
      canEdit.value = false;
      isSavedCheck();
    }
    isLoading.value = false;
  }

  void saveLineOa() {
    save('lineoa_ldte', lineOACanEdit);
  }

  void saveNomorSurat() => save('nomor_surat', nomorSuratCanEdit);

  void saveNamaKepalaLDTE() => save('nama_kepala_ldte', namaKepalaLDTECanEdit);

  void saveNipKepalaLDTE() => save('nip_kepala_ldte', nipKepalaLDTECanEdit);

  void saveCaraPinjam() => save('cara_pinjam', caraPinjamCanEdit);

  void saveCaraKeterangan() => save('cara_keterangan', caraKeteranganCanEdit);

  void saveCaraPertukaran() => save('cara_pertukaran', caraPertukaranCanEdit);

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
        updateDeletedQueueState<T>([data.id], true);
      } else if (isDeleting) {
        final isSuccess = await service.deleteData<T>([qdata]);
        if (isSuccess) {
          updateDeletedQueueState<T>([data.id]);
        } else {
          r = false;
        }
      } else if (isUpdating) {
        final res = await service.upsertData<T>([compileForm<T>(data)]);
        if (res != null) {
          updateUpdatedQueueState<T>([data.id]);
        } else {
          r = false;
        }
      } else if (isAdding) {
        if (qdata is MatprakModel) {
          final parrent = simulated.getProgramStudi(qdata.programStudi)!;
          if (parrent.id.isNegative) {
            final isSuccess = await pushAction(parrent, true);
            if (!isSuccess) r = false;
          }
        } else if (qdata is ProgramStudiModel) {
          final parrent = simulated.getFakultas(qdata.fakultas)!;
          if (parrent.id.isNegative) {
            final isSuccess = await pushAction(parrent, true);
            if (!isSuccess) r = false;
          }
        }

        if (r) {
          final res = await service.upsertData<T>([compileForm<T>(data)]);
          if (res != null) {
            updateInsertedQueueState<T>([data.id], res);
          } else {
            r = false;
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

    updateDeletedQueueState(queue.delete.intersection({...queue.insert, ...queue.update}), true);
    qfsp?.onChanged();

    queue.insert.removeAll(queue.delete);
    queue.update.removeAll(queue.delete);

    final insertData = dataSet.where((dynamic v) => queue.insert.contains(v.id));
    final updateData = dataSet.where((dynamic v) => queue.update.contains(v.id));
    final deleteData = dataSet.where((dynamic v) => queue.delete.contains(v.id));

    final set = {...queue.update, ...queue.delete, ...queue.insert}.toSet();

    set.forEach(loadingQueue.add);
    qfsped?.refresh();

    if (queue.delete.isNotEmpty) {
      final isSuccess = await service.deleteData<T>(deleteData.toList());
      if (isSuccess) {
        updateDeletedQueueState<T>(queue.delete);
      } else {
        r = false;
      }
    } 

    if (updateData.isNotEmpty) {
      final data = updateData.map(compileForm).toList();
      final res = await service.upsertData<T>(data);
      if (res != null) {
        updateUpdatedQueueState<T>(queue.update);
      } else {
        r = false;
      }
    }
    
    if (insertData.isNotEmpty) {
      bool r2 = true;
      if (T == MatprakModel) {
        final parrents = dataSet.map((v) => simulated.getProgramStudi((v as MatprakModel).programStudi)!).where((v) => v.id.isNegative);
        if (parrents.isNotEmpty) {
          final isSuccess = await pushQueuedAction(parrents, true);
          if (!isSuccess) r2 = false;
        }
      } else if (T == ProgramStudiModel) {
        final parrents = dataSet.map((v) => simulated.getFakultas((v as ProgramStudiModel).fakultas)!).where((v) => v.id.isNegative);
        if (parrents.isNotEmpty) {
          final isSuccess = await pushQueuedAction(parrents, true);
          if (!isSuccess) r2 = false;
        }
      }

      if (r2) {
        final data = insertData.map(compileForm).toList();
        final res = await service.upsertData<T>(data);
        if (res != null) {
          updateInsertedQueueState<T>(queue.insert, res);
        } else {
          r = false;
        }
      } else {
        r = false;
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

  void updateDeletedQueueState<T>(Iterable<int> ids, [bool isUpsert = false]) {
    final queue = queueFrom<T>();
    for (final id in ids.toSet()) {
      if (isUpsert) {
        queue.update.remove(id);
        queue.insert.remove(id);
      }
      queue.loading.remove(id);
      queue.select.remove(id);
      queue.delete.remove(id);
      simulated.removeWhere<T>((v) => v.id == id);
    }
  }

  void updateUpdatedQueueState<T>(Iterable<int> ids) {
    final queue = queueFrom<T>();
    for (final id in ids.toSet()) {
      queue.loading.remove(id);
      queue.update.remove(id);
    }
  }

  void updateInsertedQueueState<T>(Iterable<int> ids, List<T> newData) {
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
  final config = Get.find<GlobalConfigController>();
  late final admin = config.service;
  List<ItemModel> get stored => storage.cached.item;
  List<ItemModel> get sim => config.simulated.item;
  final qfsped = RxList<ItemModel>([]);
  
  late Iterable<ItemModel> selectedData = sim.where(inSelected);
  late Iterable<ItemModel> pagedSelectedData = sim.where(inPageSelected);
  
  late Set<int> insertQueue = config.itemQueue.insert;
  late Set<int> updateQueue = config.itemQueue.update;
  late Set<int> deleteQueue = config.itemQueue.delete;
  late Set<int> loadingQueue = config.itemQueue.loading;
  late Set<int> isSelected = config.prodiQueue.select;
  
  Set<int> get simIds => sim.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get pagedIds => qfsped.value.map((v) => v.id).toSet().difference(loadingQueue);
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
      final list = config.simulated.formatedItem();
      nameE.value = nameC.text.isBlank() ? '*required' : model.name != s?.name && list.contains(model.name) ? '*already exist' : null;

      if (nameE.value != null) return false;
      
      nameE.value = null;
      return true;
    }

    nameF.addListener(() {
      if (!nameF.hasFocus) nameC.text = nameC.text.trim().capitalCase(false);
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
  late final admin = config.service;
  final config = Get.find<GlobalConfigController>();

  List<FakultasModel> get stored => storage.cached.fakultas;
  List<FakultasModel> get sim => config.simulated.fakultas;
  final qfsped = RxList<FakultasModel>([]);
  
  late Iterable<FakultasModel> selectedData = sim.where(inSelected);
  late Iterable<FakultasModel> pagedSelectedData = sim.where(inPageSelected);
  
  late Set<int> insertQueue = config.fakultasQueue.insert;
  late Set<int> updateQueue = config.fakultasQueue.update;
  late Set<int> deleteQueue = config.fakultasQueue.delete;
  late Set<int> loadingQueue = config.fakultasQueue.loading;
  late Set<int> isSelected = config.prodiQueue.select;
  
  Set<int> get simIds => sim.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get pagedIds => qfsped.value.map((v) => v.id).toSet().difference(loadingQueue);
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
  bool get isPageAnyQueued => pagedIds.any(inQueue) || qfsped.value.any((f) => f.programStudi.any((pd) => config.prodiQueue.contains(pd.id, true) || pd.matprak.any((mp) => config.matprakQueue.contains(mp.id))));
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
      final list = config.simulated.formatedFakultas();
      nameE.value = nameC.text.isBlank() ? '*required' : !nameC.text.contains(RegExp(r'\((.*?)\)')) ? '*invalid format' : model.name != s?.name && list.contains(model.name) ? '*already exist' : null;

      if (nameE.value != null) return false;
      
      nameE.value = null;
      return true;
    }

    nameF.addListener(() {
      if (!nameF.hasFocus) {
        final temp = nameC.text.trim().capitalCase(false);
        final abv = RegExp(r'\((.*?)\)').firstMatch(temp)?.group(1);
        if (abv != null) nameC.text = temp.replaceAll(RegExp(r'\((.*?)\)'), '(${abv.toUpperCase()})');
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
  
  final config = Get.find<GlobalConfigController>();
  late final admin = config.service;
  late final fakultas = config.simulated.getFakultas(name);

  List<ProgramStudiModel> get stored => storage.cached.programStudi;
  List<ProgramStudiModel> get sim => fakultas?.programStudi ?? [];
  final qfsped = RxList<ProgramStudiModel>([]);
  
  late Iterable<ProgramStudiModel> selectedData = sim.where(inSelected);
  late Iterable<ProgramStudiModel> pagedSelectedData = sim.where(inPageSelected);
  
  late Set<int> insertQueue = config.prodiQueue.insert;
  late Set<int> updateQueue = config.prodiQueue.update;
  late Set<int> deleteQueue = config.prodiQueue.delete;
  late Set<int> loadingQueue = config.prodiQueue.loading;
  late Set<int> isSelected = config.prodiQueue.select;
  
  Set<int> get simIds => sim.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get pagedIds => qfsped.value.map((v) => v.id).toSet().difference(loadingQueue);
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
  bool get isPageAnyQueued => pagedIds.any(inQueue) || qfsped.value.any((p) => p.matprak.any((m) => config.matprakQueue.contains(m.id)));
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
      final list = config.simulated.formatedProgramStudi();
      nameE!.value = nameC!.text.isBlank() ? '*required' : !nameC.text.contains(RegExp(r'\((.*?)\)')) ? '*invalid format' : model.name != s?.name && list.contains(model.name) ? '*already exist' : null;
      fakultasE.value = !fakultasC.hasValue ? '*required' : null;

      if (nameE.value != null || fakultasE.value != null) return false;
      
      nameE.value = fakultasE.value = null;
      return true;
    }
    nameF?.addListener(() {
      if (!nameF.hasFocus) {
        final temp = nameC!.text.trim().capitalCase(false);
        final abv = RegExp(r'\((.*?)\)').firstMatch(temp)?.group(1);
        if (abv != null) nameC.text = temp.replaceAll(RegExp(r'\((.*?)\)'), '(${abv.toUpperCase()})');
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

  final config = Get.find<GlobalConfigController>();
  late final admin = config.service;
  late final programStudi = config.simulated.getProgramStudi(name);

  List<MatprakModel> get stored => storage.cached.matprak;
  List<MatprakModel> get sim => programStudi?.matprak ?? [];
  final qfsped = RxList<MatprakModel>([]);
  
  late Iterable<MatprakModel> selectedData = sim.where(inSelected);
  late Iterable<MatprakModel> pagedSelectedData = sim.where(inPageSelected);
  
  late Set<int> insertQueue = config.matprakQueue.insert;
  late Set<int> updateQueue = config.matprakQueue.update;
  late Set<int> deleteQueue = config.matprakQueue.delete;
  late Set<int> loadingQueue = config.matprakQueue.loading;
  late Set<int> isSelected = config.prodiQueue.select;
  
  Set<int> get simIds => sim.map((v) => v.id).toSet().difference(loadingQueue);
  Set<int> get pagedIds => qfsped.value.map((v) => v.id).toSet().difference(loadingQueue);
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

    final kode = multi ? null : TextEditingController(text: s?.kode ?? (regexp.firstMatch(programStudi!.name)?.group(1)));
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
      final kodes = config.simulated.matprak.map((v) => v.kode);
      final namas = config.simulated.matprak.map((v) => v.nama);
      kodeE!.value = kode!.text.isBlank() ? '*required' : model.kode != s?.kode && kodes.contains(model.kode) ? '*already exist' : null;
      namaE!.value = nama!.text.isBlank() ? '*required' : model.nama != s?.nama && namas.contains(model.nama) ? '*already exist' :null;
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
      if (!namaF.hasFocus) nama?.text = nama.text.trim().capitalCase(false);
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