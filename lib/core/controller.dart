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
        cancelAction: () {
          currentContext?.pop();
        },
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
  void onInit() {
    super.onInit();
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
  final service = PeminjamanPeralatanService();
  var isLoading = false.obs;

  Rxn<XFile> idCard = Rxn<XFile>(ImagePickerService.lastImages['default']); 

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

  Future<void> selectDateStart() async {
    final picked = await DateTimePickerService().selectDate(initial: mulaiC.text.toDateTime(), helpText: "Tanggal Peminjaman");
    if (picked != null) mulaiC.text = picked.toDateString();
  }

  Future<void> selectDateEnd() async {
    final picked = await DateTimePickerService().selectDate(initial: akhirC.text.toDateTime(), helpText: "Tanggal Pengembalian");
    if (picked != null) akhirC.text = picked.toDateString();
  }

  var prodiList = <String>[].obs;

  Map<String, dynamic> get dbform => {
    if (!namaC.text.isBlank()) 'nama' : namaC.text.trim(),
    if (!nimC.text.isBlank()) 'nim' : nimC.text.trim(),
    if (mulaiC.text.toDateTime() != null) 'mulai' : mulaiC.text.trim(),
    if (akhirC.text.toDateTime() != null) 'akhir' : akhirC.text.trim(),
    'barang' : barangC.value.map((e) => e.text.trim()).toList(),
    'banyak' : banyakC.value.map((e) => e.value).toList(),
  };

  Map<String, dynamic> get form => {
    ...dbform,
    if (fakultasC.hasValue) 'fakultas' : regexp.firstMatch(fakultasC.value ?? '')?.group(1),
    if (prodiC.hasValue) 'prodi' : prodiC.value?.replaceAll(RegExp(r'\((.*?)\)'), '').trim(),
    if (!dosenC.text.isBlank()) 'dosen' : dosenC.text.trim(),
    if (!nipDosenC.text.isBlank()) 'nipDosen' : nipDosenC.text.trim(),
    if (!ketuaC.text.isBlank()) 'ketua' : ketuaC.text.trim(),
    if (!nipKetuaC.text.isBlank()) 'nipKetua' : nipKetuaC.text.trim(),
  };

  void selectImage() async {
    service.imagePicker.selectImage(idCard);
  }

  void previewImage() {
    service.imagePicker.previewImage(idCard.value!);
  }

  void resetImage() {
    service.imagePicker.resetImage(idCard);
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
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(4),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
'''- Isi kolom yang diperlukan secara online.
- Beberapa kolom dapat dikosongkan jika tidak ada, tidak tahu, atau akan diisi setelah formulir diprint.
- 1 formulir dapat digunakan untuk meminjam beberapa barang sekaligus (hingga 4 barang).
- Setelah mengisi, klik tombol "Pinjam" untuk preview dokumen dan periksa apakah semua data sudah benar.
- Dokumen kemudian dapat didownload dan diprint untuk ditandatangani, kemudian diserahkan pada saat menerima barang.''',
                      style: TextStyle(fontSize: 12.8),
                    ),
                  )
                )
              ),
            ),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Checkbox(value: remindMe.value, onChanged: (v) {
                  remindMe.value = v!;
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

  @override
  void onInit() async {
    super.onInit();
    init();
  }

  void init() async {
    service.initWorker();
    await service.imagePicker.retrieveLostData(idCard);
    showReminderDialog();
  }

  @override
  void onClose() {
    service.closeWorker();
    super.onClose();
  }
  
  void setProdi() {
    prodiC.value = null;
    prodiList.value = getAvailableProdi(fakultasC.value);
  }

  var namaE = Rxn<String>(null); 
  var nimE = Rxn<String>(null); 
  var mulaiE = Rxn<String>(null); 
  var akhirE = Rxn<String>(null); 
  var barangE = RxList<String?>([null]); 
  var banyakE = RxList<String?>([null]); 
  var idCardE = Rxn<String>(null); 

  bool checkEmptyFields([bool reqId = true]) {
    if (
      barangC.any((e) => e.text.isBlank()) || 
      banyakC.any((e) => !e.hasValue) || 
      namaC.text.isBlank() ||
      nimC.text.isBlank() ||
      mulaiC.text.isBlank() ||
      akhirC.text.isBlank()||
      (idCard.value == null && reqId)
    ) {
      barangE.value = barangC.map((e) => e.text.isBlank() ? '*required' : null).toList();
      banyakE.value = banyakC.map((e) => !e.hasValue ? '*required' : null).toList();
      namaE.value = namaC.text.isBlank () ? '*required' : null;
      nimE.value = nimC.text.isBlank () ? '*required' : null;
      mulaiE.value = mulaiC.text.isBlank() ? '*required' : mulaiC.text.toDateTime() == null ? '*invalid' : null;
      akhirE.value = akhirC.text.isBlank() ? '*required' : akhirC.text.toDateTime() == null ? '*invalid' : null;
      if (reqId) idCardE.value = idCard.value == null ? '*required' : null;
      return false;
    }
    barangE.value.fillRange(0, barangE.value.length, null);
    banyakE.value.fillRange(0, banyakE.value.length, null);
    namaE.value = nimE.value = mulaiE.value = akhirE.value = idCardE.value = null;
    return true;
  }

  void pinjam() async {
  if (!checkEmptyFields()) return;
    isLoading.value = true;
    final savedFile = await service.compilePDF(form, await idCard.value?.readAsBytes());
    if (savedFile != null) {
      final fileName = "Form_Peminjaman-${DateTime.now().millisecondsSinceEpoch}.pdf";
      service.preview(savedFile, fileName, (f) async {
        isLoading.value = true;
        final isSuccess = await service.submitForm(dbform);
        if (isSuccess) f();
        isLoading.value = false;
      }, isLoading);
    }
    isLoading.value = false;
  }
} 

class SuratKeteranganPraktikumController extends GetxController {
  var isLoading = false.obs;
  var message = RxnString(null);

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
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(4),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
''''- Isi semua kolom yang ada secara online.
- 1 formulir dapat digunakan untuk beberapa orang sekaligus (hingga 4 orang).
- Jika semua kolom telah terisi, klik tombol "Submit".
- Setelah formulir terkirim, silahkan melapor kepada admin melalui link yang diberikan.
- Tunggu konfirmasi dan arahan selanjutnya (jika ada) dari admin.''',
                      style: TextStyle(fontSize: 12.8),
                    ),
                  )
                )
              ),
            ),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Checkbox(value: remindMe.value, onChanged: (v) {
                  remindMe.value = v!;
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

  @override
  void onInit() async {
    super.onInit();
    init();
  }

  void init() async {
    await service.imagePicker.retrieveLostData(bukti);
    showReminderDialog();
  }

  Future<void> selectDate() async {
    final picked = await DateTimePickerService().selectDate(initial: dateC.text.toDateTime(), helpText: "Tanggal Praktikum");
    if (picked != null) dateC.text = picked.toDateString();
  }

  Future<void> selectTimeStart() async {
    final picked = await DateTimePickerService().selectTime(initial: timeStartC.value, helpText: "Waktu Mulai Praktikum");
    if (picked != null) {
      if (timeEndC.value != null && picked.isAfter(timeEndC.value!)) return snackbar('Error', 'Waktu Mulai Tidak Bisa Lebih Dari Waktu Selesai');
      timeStartC.value = picked;
    }
  }

  Future<void> selectTimeEnd() async {
    final picked = await DateTimePickerService().selectTime(initial: timeEndC.value, helpText: "Waktu Selesai Praktikum");
    if (picked != null) {
      if (timeStartC.value != null && picked.isBefore(timeStartC.value!)) return snackbar('Error', 'Waktu Selesai Tidak Bisa Kurang Dari Waktu Mulai');
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

  var prodiList = <String>[].obs;

  Rxn<XFile> bukti = Rxn<XFile>(ImagePickerService.lastImages['default']); 

  Map<String, dynamic> get form => {
    'nama' : namaC.value.map((e) => e.text.trim()).toList(),
    'nim' : nimC.value.map((e) => e.text.trim()).toList(),
    'matkul' : matkul.value == 'Lainnya...' ? '${kodeMatkul.text.trim()} ${namaMatkul.text.trim()}' : matkul.value,
    'praktikum' : praktikum.value == 'Lainnya...' ? '${kodePraktikum.text.trim()} ${namaPraktikum.text.trim()}' : praktikum.value,
    'modul' : modul.value!,
    'date' : dateC.text,
    'timeStart' : timeStartC.value!.toFormatedString(),
    'timeEnd' :  timeEndC.value!.toFormatedString(),
  };

  void selectImage() async {
    service.imagePicker.selectImage(bukti);
  }

  void previewImage() {
    service.imagePicker.previewImage(bukti.value!);
  }

  void resetImage() {
    service.imagePicker.resetImage(bukti);
  }

   bool checkEmptyFields([bool reqImage = true]) {
    if (
      namaC.any((e) => e.text.isBlank()) || 
      nimC.any((e) => e.text.isBlank()) || 
      !matkul.hasValue || 
      (matkul.value == 'Lainnya...' && (namaMatkul.text.isBlank() || kodeMatkul.text.isBlank())) || 
      !praktikum.hasValue || 
      (praktikum.value == 'Lainnya...' && (namaPraktikum.text.isBlank() || kodePraktikum.text.isBlank())) || 
      !modul.hasValue || 
      (dateC.text.isBlank() || dateC.text.toDateTime() == null)||
      timeStartC.value == null ||
      timeEndC.value == null ||
      (bukti.value == null && reqImage)
    ) {
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
      timeStartE.value = timeStartC.value == null ? '*required' : null;
      timeEndE.value = timeEndC.value == null ? '*required' : null;
      if (reqImage) buktiE.value = bukti.value == null ? '*required' : null;
      return false;
    }
    namaE.value.fillRange(0, namaE.value.length, null);
    nimE.value.fillRange(0, nimE.value.length, null);
    matkulE.value = namaMatkulE.value = kodeMatkulE.value = praktikumE.value = namaPraktikumE.value = kodePraktikumE.value = modulE.value = dateE.value = timeStartE.value = timeEndE.value = buktiE.value = null;
    return true;
  }

  void submit() async {
    if (!checkEmptyFields()) return;
    final uriMessage = "Saya telah mengirimkan formulir surat keterangan praktikum atas nama ${(form['nama'] as List<String>).toFormatedString()}: https://ldte-stei-itb.vercel.app/admin/surat-keterangan";
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
            confirmText: 'Close Page',
            confirmAction: () {
              currentContext?.go(NamedRoute.homepage);
            },
          );
          service.imagePicker.resetImage(bukti);
        } else message.value = 'Failed (Retry)';
      } else message.value = 'Failed (Retry)';
      isLoading.value = false;
      Future.delayed(Duration(seconds: 3), message.value = null); 
    } else alertDialog('Error', 'Device is not synced.');
  }
} 

class PertukaranJadwalPraktikumController extends GetxController {
  var isLoading = false.obs;

  final service = SuratKeteranganPraktikumService();
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
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(4),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
'''- Isi semua kolom yang ada secara online.
- Jika semua kolom telah terisi, klik tombol "Format".
- Setelah formulir diformat, silahkan melapor kepada admin melalui link yang diberikan.
- Tunggu konfirmasi dan arahan selanjutnya (jika ada) dari admin.''',
                      style: TextStyle(fontSize: 12.8),
                    ),
                  )
                )
              ),
            ),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remind me again'),
                Checkbox(value: remindMe.value, onChanged: (v) {
                  remindMe.value = v!;
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
  }

  Future<void> selectDate() async {
    final picked = await DateTimePickerService().selectDate(initial: dateC.text.toDateTime(), helpText: "Jadwal Sebelum Pertukaran");
    if (picked != null) dateC.text = picked.toDateString();
  }

  Future<void> selectDateP() async {
    final picked = await DateTimePickerService().selectDate(initial: datePC.text.toDateTime(), helpText: "Jadwal Pengganti");
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

  String get message => '''Silahkan chat sesuai template dibawah ini.
------------------------------------------
Pertukaran Jadwal Praktikum
PRAKTIKAN
Nama : ${namaC.text.trim()}
NIM : ${nimC.text.trim()}

JADWAL SEBELUM PERTUKARAN
Praktikum : ${praktikum.value == 'Lainnya...' ? '${kodePraktikum.text.trim()} ${namaPraktikum.text.trim()}' : praktikum.value}
Modul : ${modul.value}
Hari/Tanggal : ${dateC.text.toDateTime()?.toDateFormatString()}

MENGGANTIKAN PRAKΤΙΚΑΝ
Nama: ${namaPC.text.trim()}
NIM : ${nimPC.text.trim()}

MENGIKUTI PRAKTIKUM
Praktikum : ${praktikum.value == 'Lainnya...' ? '${kodePraktikum.text.trim()} ${namaPraktikum.text.trim()}' : praktikum.value}
Modul : ${modul.value}
Hari/Tanggal : ${datePC.text.toDateTime()?.toDateFormatString()}
------------------------------------------
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
    } else alertDialog('Error', 'Device is not synced.');
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
  var submissions = <PeminjamanPeralatanModel>[];
  var loadingIndicator = <int, bool>{};
  var isSelected = <int, bool>{};
  var QFSPedSubmissions = RxList<PeminjamanPeralatanModel>([]);

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
    final picked = await DateTimePickerService().selectDate(initial: startDateC.text.toDateTime(), helpText: "Select start date");
    if (picked != null) {
      startDateC.text = picked.toDateString();
      qfsp.onChanged();
    }
  }

  Future<void> selectDateFilterEnd() async {
    final picked = await DateTimePickerService().selectDate(initial: endDateC.text.toDateTime(), helpText: "Select end date");
    if (picked != null) {
      endDateC.text = picked.toDateString();
      qfsp.onChanged();
    }
  }

  late QFSPController qfsp = QFSPController(
    filter: [
      FilterController(
        filterKey: "status",
        filterList: ['unchecked', 'borrowed', 'returned', 'overdue', 'damaged', 'lost', 'spam'],
        function: (m) => [(m as PeminjamanPeralatanModel).status]
      ),
    ],
    onChanged: ([String? itemKey, String? filterKey]) {
      var queried = admin.QFSP.query(submissions, qfsp, (v) => [v.nama, v.nim]);
      var filtered = admin.QFSP.filter(queried, qfsp, itemKey, filterKey, dateTimeList, (v) => v.createdAt);
      var sorted = admin.QFSP.sort(filtered, qfsp);
      var paged = admin.QFSP.page(sorted, qfsp, pageNum);
      QFSPedSubmissions.value = paged;
    },
    pageC: pageC,
  );

  Future<void> getAllSubmissions() async {
    isLoading.value = true;
    final res = await admin.getAllSubmissions();
    print (res);
    if (res != null) {
      loadingIndicator = Map<int, bool>.fromEntries(res.map((v) => MapEntry(v.id, false)));
      isSelected = Map<int, bool>.fromEntries(res.map((v) => MapEntry(v.id, false)));
      submissions = res;
      qfsp.onChanged();
    }
    getFindCall<DetailPeminjamanPeralatanController>()?.setInitialValue();
    isLoading.value = false;
  }

  void selectItem(int id, bool state) {
    isSelected[id] = state;
    QFSPedSubmissions.refresh();
  }

  void selectPageItem(bool? state) {
    QFSPedSubmissions.value.forEach((v) => isSelected[v.id] = state ?? false);
    Future(() => QFSPedSubmissions.refresh());
  }

  void setStatus(int id, String status) async {
    loadingIndicator[id] = true;
    QFSPedSubmissions.refresh();
    final res = await admin.updateStatus([id], status);
    loadingIndicator[id] = false;
    if (res != null) updateSubmission(res);
  }

  void setSelectedStatus(String status) {
    final ids = isSelected.entries.where((e) => e.value).map((e) => e.key).toList();
    alertDialog(
      'Confirmation', 
      'You are going to update ${ids.length} row of status data to $status.\n'
      'Are you completely sure? this action cannot be undone.',
      confirmAction: () async {
        closeAllDialog();
        ids.forEach((v) => loadingIndicator[v] = true);
        QFSPedSubmissions.refresh();
        await Future.delayed(Duration(seconds: 2));
        final res = await admin.updateStatus(ids, status);
        ids.forEach((v) {
          loadingIndicator[v] = false;
          isSelected[v] = false;
        });
        if (res != null) updateSubmission(res);
      },
    );
  }

  void updateSubmission(List<PeminjamanPeralatanModel> newData) {
    for (final item in newData) {
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
  final int id;
  final ac = Get.find<AdminPeminjamanPeralatanController>();
  DetailPeminjamanPeralatanController(this.id);

  @override 
  void init() async {
    if (ac.submissions.isNotEmpty) setInitialValue();
  }

  @override
  void onClose() {
    ac.qfsp.onChanged();
    super.onClose();
  }

  void setInitialValue() {
    final submission = ac.submissions.where((v) => v.id == id).firstOrNull;
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

  void updateForm() async {
    if (!checkEmptyFields(false)) return;
    ac.isLoading.value = true;
    final res = await ac.admin.updateFormData(id, dbform);
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

class AdminSuratKeteranganPraktikumController extends GetxController {
  final admin = AdminSuratKeteranganPraktikumService();

  var isLoading = false.obs;
  var isExporting = false.obs;
  var submissions = <SuratKeteranganPraktikumModel>[];
  var loadingIndicator = <int, bool>{};
  var isSelected = <int, bool>{};
  var QFSPedSubmissions = RxList<SuratKeteranganPraktikumModel>([]);

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
    final picked = await DateTimePickerService().selectDate(initial: startDateC.text.toDateTime(), helpText: "Select start date");
    if (picked != null) {
      startDateC.text = picked.toDateString();
      qfsp.onChanged();
    }
  }

  Future<void> selectDateFilterEnd() async {
    final picked = await DateTimePickerService().selectDate(initial: endDateC.text.toDateTime(), helpText: "Select end date");
    if (picked != null) {
      endDateC.text = picked.toDateString();
      qfsp.onChanged();
    }
  }

  late QFSPController qfsp = QFSPController(
    filter: [
      FilterController(
        filterKey: "status",
        filterList: ['unchecked', 'pending', 'exported', 'spam'],
        function: (m) => [(m as SuratKeteranganPraktikumModel).status]
      ),
    ],
    onChanged: ([String? itemKey, String? filterKey]) {
      var queried = admin.QFSP.query(submissions, qfsp, (v) => [v.nama.toFormatedString(), v.nim.toFormatedString()]);
      var filtered = admin.QFSP.filter(queried, qfsp, itemKey, filterKey, dateTimeList, (v) => v.createdAt);
      var sorted = admin.QFSP.sort(filtered, qfsp);
      var paged = admin.QFSP.page(sorted, qfsp, pageNum);
      QFSPedSubmissions.value = paged;
    },
    pageC: pageC,
  );

  Future<void> getAllSubmissions() async {
    isLoading.value = true;
    final res = await admin.getAllSubmissions();
    if (res != null) {
      loadingIndicator = Map<int, bool>.fromEntries(res.map((v) => MapEntry(v.id, false)));
      isSelected = Map<int, bool>.fromEntries(res.map((v) => MapEntry(v.id, false)));
      submissions = res;
      qfsp.onChanged();
    }
    getFindCall<DetailSuratKeteranganPraktikumController>()?.setInitialValue();
    isLoading.value = false;
  }

  void preview(SuratKeteranganPraktikumModel data) async {
    isExporting.value = true;
    QFSPedSubmissions.refresh();
    final savedFile = await admin.compilePDF(data);
    if (savedFile != null) {
      final fileName = "Surat_Keterangan_praktikum-${DateTime.now().millisecondsSinceEpoch}.pdf";
      admin.preview(savedFile, fileName);
    }
    isExporting.value = false;
    QFSPedSubmissions.refresh();
  }

  void selectItem(int id, bool state) {
    isSelected[id] = state;
    QFSPedSubmissions.refresh();
  }

  void selectPageItem(bool? state) {
    QFSPedSubmissions.value.forEach((v) => isSelected[v.id] = state ?? false);
    Future(() => QFSPedSubmissions.refresh());
  }

  void setStatus(int id, String status) async {
    loadingIndicator[id] = true;
    QFSPedSubmissions.refresh();
    final res = await admin.updateStatus([id], status);
    loadingIndicator[id] = false;
    if (res != null) updateSubmission(res);
  }

  void setSelectedStatus(String status) {
    final ids = isSelected.entries.where((e) => e.value).map((e) => e.key).toList();
    alertDialog(
      'Confirmation', 
      'You are going to update ${ids.length} row of status data to $status.\n'
      'Are you completely sure? this action cannot be undone.',
      confirmAction: () async {
        closeAllDialog();
        ids.forEach((v) => loadingIndicator[v] = true);
        QFSPedSubmissions.refresh();
        await Future.delayed(Duration(seconds: 2));
        final res = await admin.updateStatus(ids, status);
        ids.forEach((v) {
          loadingIndicator[v] = false;
          isSelected[v] = false;
        });
        if (res != null) updateSubmission(res);
      },
    );
  }

  void updateSubmission(List<SuratKeteranganPraktikumModel> newData) {
    for (final item in newData) {
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
  final int id;
  final ac = Get.find<AdminSuratKeteranganPraktikumController>();
  DetailSuratKeteranganPraktikumController(this.id);

  @override 
  void init() async {
    if (ac.submissions.isNotEmpty) setInitialValue();
  }

  @override
  void onClose() {
    ac.qfsp.onChanged();
    super.onClose();
  }

  void setInitialValue() {
    final submission = ac.submissions.where((v) => v.id == id).firstOrNull;
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

  void updateForm() async {
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