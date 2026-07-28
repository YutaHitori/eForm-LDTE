import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ldte_stei_itb/core/model.dart';
import 'package:ldte_stei_itb/core/service.dart';
import 'package:ldte_stei_itb/homepage/admin.dart';
import 'package:ldte_stei_itb/homepage/homepage.dart';
import 'package:ldte_stei_itb/homepage/login.dart';
import 'package:ldte_stei_itb/misc/extension.dart';
import 'package:ldte_stei_itb/misc/function.dart';
import 'package:ldte_stei_itb/misc/global.dart';
import 'package:intl/intl.dart';
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

class PinjamController extends GetxController {
  final service = PinjamService();
  var isLoading = false.obs;

  Rxn<XFile> ktp = Rxn<XFile>(ImagePickerService.lastImages['ktp']); 
  Rxn<XFile> ktm = Rxn<XFile>(ImagePickerService.lastImages['ktm']); 

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
  final banyakC = <TextEditingController>[TextEditingController(text: '1')].obs;
  final startDateC = TextEditingController();
  final endDateC = TextEditingController();

  Future<void> selectDateStart() async {
    final picked = await DateTimePickerService().selectDate(initial: startDateC.text.toDateTime(), helpText: "Tanggal Peminjaman");
    if (picked != null) startDateC.text = picked.toDateString();
  }

  Future<void> selectDateEnd() async {
    final picked = await DateTimePickerService().selectDate(initial: endDateC.text.toDateTime(), helpText: "Tanggal Pengembalian");
    if (picked != null) endDateC.text = picked.toDateString();
  }

  var prodiList = <String>[].obs;

  Future<Map<String, dynamic>> get form async => {
    'nama' : namaC.text.isBlank() ? null : namaC.text.trim(),
    'nim' : nimC.text.isBlank() ? null : nimC.text.trim(),
    'fakultas' : regexp.firstMatch(fakultasC.value ?? '')?.group(1),
    'prodi' : prodiC.value?.replaceAll(RegExp(r'\((.*?)\)'), '').trim(),
    'dosen' : dosenC.text.isBlank() ? null : dosenC.text.trim(),
    'nipDosen' : nipDosenC.text.isBlank() ? null : nipDosenC.text.trim(),
    'ketua' : ketuaC.text.isBlank() ? null : ketuaC.text.trim(),
    'nipKetua' : nipKetuaC.text.isBlank() ? null : nipKetuaC.text.trim(),
    'mulai' : startDateC.text.isBlank() ? null : DateFormat('d MMMM yyyy', 'id_ID').format(startDateC.text.toDateTime()!),
    'akhir' : endDateC.text.isBlank() ? null : DateFormat('d MMMM yyyy', 'id_ID').format(endDateC.text.toDateTime()!),
    'barang' : barangC.value.map(
      (e) {
        var contain = items.where((v) => v.toLowerCase() == e.text.toLowerCase());
        return e.text.isBlank() 
          ? "_____________________________________________________________________" 
          : contain.isEmpty ? e.text.trim() : contain.first;
      }).toList(),
    'banyak' : banyakC.value.map((e) => e.text.isBlank() ? "" : ' x' + e.text.trim()).toList(),
    'ktm' :  await ktm.value?.readAsBytes(),
    'ktp' :  await ktp.value?.readAsBytes(),
  };

  void selectKtp() async {
    service.imagePicker.selectImage(ktp, key: 'ktp');
  }

  void previewKtp() {
    service.imagePicker.previewImage(ktp.value!);
  }

  void resetKtp() {
    service.imagePicker.resetImage(ktp, key: 'ktp');
  }

  void selectKtm() async {
    service.imagePicker.selectImage(ktm, key: 'ktm');
  }

  void previewKtm() {
    service.imagePicker.previewImage(ktm.value!);
  }

  void resetKtm() {
    service.imagePicker.resetImage(ktm, key: 'ktm');
  }

  @override
  void onInit() async {
    super.onInit();
    service.initWorker();
    await service.imagePicker.retrieveLostData(ktm, key: 'ktm');
    await service.imagePicker.retrieveLostData(ktp, key: 'ktp');
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

  void pinjam() async {
    isLoading.value = true;
    final savedFile = await service.compilePDF(await form);
    final fileName = "Form_Peminjaman-${DateTime.now().millisecondsSinceEpoch}.pdf";
    service.preview(savedFile, fileName);
    isLoading.value = false;
  }
} 

class SuratKeteranganPraktikumController extends GetxController {
  var isLoading = false.obs;
  var message = RxnString(null);

  final service = SuratKeteranganPraktikumService();
  List<String> get matkulList => storage.cached.formatedMataKuliah();
  List<String> get praktikumList => storage.cached.formatedPraktikum();

  @override
  void onInit() async {
    super.onInit();
    await service.imagePicker.retrieveLostData(bukti);
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

  Future<Map<String, dynamic>> get form async => {
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

   bool checkEmptyFields() {
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
      bukti.value == null
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
      buktiE.value = bukti.value == null ? '*required' : null;
      return false;
    }
    namaE.value.fillRange(0, namaE.value.length, null);
    nimE.value.fillRange(0, nimE.value.length, null);
    matkulE.value = namaMatkulE.value = kodeMatkulE.value = praktikumE.value = namaPraktikumE.value = kodePraktikumE.value = modulE.value = dateE.value = timeStartE.value = timeEndE.value = buktiE.value = null;
    return true;
  }

  void submit() async {
    if (!checkEmptyFields()) return;
    isLoading.value = true;
    message.value = 'Uploading Image...';
    final url = await service.uploadImage(bukti.value!);
    if (url != null) {
      message.value = 'Inserting Data...';
      final isSuccess = await service.submitForm({ 'bukti': url, ...await form }); 
      if (isSuccess) {
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
                          final Uri uri = Uri.parse('https://line.me/R/oaMessage/%40kiy3574q/?hello%20world%21');
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            snackbar('Error!', 'Could not launch $uri');
                          }
                        }, 
                        child: Text('OA Line LDTE', style: TextStyle(color: Colors.blue))
                      ),
                    ),
                  ),
                  TextSpan(
                    text: '.',
                    style: TextStyle(color: Colors.white)
                  ),
                ],
              ),
            ),
          ),
          dismissible: false,
          cancelAction: () {
            currentContext?.go('/');
            currentContext?.push('/surat-keterangan');
          },
          cancelText: 'Submit another form',
          confirmAction: () {
            currentContext?.go('/');
          },
          confirmText: 'Close'
        );
        service.imagePicker.resetImage(bukti);
      } else message.value = 'Failed (Retry)';
    } else message.value = 'Failed (Retry)';
    isLoading.value = false;
    Future.delayed(Duration(seconds: 3), message.value = null);
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

class GlobalSettingController extends GetxController {
  Future<void> syncMatkul() async {
    
  }
}

class AdminSuratKeteranganPraktikumController extends SuratKeteranganPraktikumController {
  final admin = AdminSuratKeteranganPraktikumService();

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

  Future<void> selectDateStart(BuildContext context) async {
    final picked = await DateTimePickerService().selectDate(initial: startDateC.text.toDateTime(), helpText: "Tanggal Peminjaman");
    if (picked != null) {
      startDateC.text = picked.toDateString();
      qfsp.onChanged();
    }
  }

  Future<void> selectDateEnd(BuildContext context) async {
    final picked = await DateTimePickerService().selectDate(initial: endDateC.text.toDateTime(), helpText: "Tanggal Pengembalian");
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
      var queried = service.QFSP.query(submissions, qfsp, (v) => [v.nama.toFormatedString(), v.nim.toFormatedString()]);
      var filtered = service.QFSP.filter(queried, qfsp, itemKey, filterKey, dateTimeList, (v) => v.createdAt);
      var sorted = service.QFSP.sort(filtered, qfsp);
      var paged = service.QFSP.page(sorted, qfsp, pageNum);
      QFSPedSubmissions.value = paged.cast<SuratKeteranganPraktikumModel>();
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
}