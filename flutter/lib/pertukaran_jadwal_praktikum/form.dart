import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/misc/global.dart';
import 'package:ldte_stei_itb/misc/widget.dart';

class PertukaranJadwalPraktikum extends StatelessWidget {
  const PertukaranJadwalPraktikum({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PertukaranJadwalPraktikumController());
    return Scaffold(
      appBar: AppBar(
        leading: canPop
          ? null : IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Get.offNamed('/'),
          ),
        title: Text('Pertukaran Jadwal Praktikum')
      ),
      body: LayoutBuilder(
        builder: (context, constrains) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Text(
          '''Cara Pengisisan Formulir Pergantian Jadwal Praktikum LDTE STEI ITB :
- Isi semua kolom yang ada secara online.
- Jika semua kolom telah terisi, klik tombol "Format".
- Setelah formulir diformat, silahkan melapor kepada admin melalui link yang diberikan.
- Tunggu konfirmasi dan arahan selanjutnya (jika ada) dari admin.'''
                  ),
                  Divider(),
                  CustomTextField(
                    controller: c.namaC,
                    labelText: 'Nama Praktikan',
                    errorText: c.namaE.value,
                    decoration: InputDecoration(hintText: 'e.g. Safaraz Akma Fadhil'),
                  ),
                  CustomTextField(
                    controller: c.nimC,
                    labelText: 'Nim Praktikian',
                    errorText: c.nimE.value,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                    decoration: InputDecoration(hintText: 'e.g. 12345678'),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Praktikum Sebelum Pertukaran', textScaleFactor: 1.02,),
                                if (c.praktikumE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                              ],
                            ),
                            DropdownFlutter<String>.search(
                              controller: c.praktikum,
                              noResultFoundBuilder: (context, text) => Padding(
                                padding: EdgeInsetsGeometry.all(16),
                                child: Text(text, textAlign: TextAlign.center,),
                              ),
                              noResultFoundText: "Praktikum tidak ditemukan, silahkan hapus kolom pencarian dan pilih opsi 'Lainnya...'",
                              listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                              decoration: CustomDropdownDecoration(
                                searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.inputDecorationTheme.fillColor),
                                closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                closedBorder: c.praktikumE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                              ),
                              excludeSelected: false,
                              items: ['Lainnya...'] + (NC.isSyncing.value ? [] : c.praktikumList),
                              hintText: NC.isSyncing.value ? 'Syncing in progress, please wait...' : 'select',
                              onChanged: (v) => c.isPraktikumLainnya.value = v == 'Lainnya...',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: constrains.maxWidth * 0.15,
                        constraints: BoxConstraints(maxWidth: 160),
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Modul', textScaleFactor: 1.02, overflow: TextOverflow.ellipsis),
                                if (c.modulE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                              ],
                            ),
                            DropdownFlutter<int>(
                              controller: c.modul,
                              listItemBuilder: (context, item, isSelected, onItemSelect) => Text('$item', style: TextStyle(color: isSelected ? Colors.black : null),),
                              decoration: CustomDropdownDecoration(
                                closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                closedSuffixIcon: SizedBox(),
                                expandedSuffixIcon: SizedBox(),
                                closedBorder: c.modulE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                              ),
                              excludeSelected: false,
                              items: List.generate(20, (i) => i + 1),
                              hintText: 'X',
                              onChanged: (v) {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (c.isPraktikumLainnya.value) Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: c.kodePraktikum,
                          labelText: 'Kode',
                          errorText: c.kodePraktikumE.value,
                          decoration: InputDecoration(
                            hintText: 'e.g. EL3017',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: c.namaPraktikum,
                          labelText: 'Nama',
                          errorText: c.namaPraktikumE.value,
                          decoration: InputDecoration(
                            hintText: 'e.g. Sistem Tenaga Elektrik',
                          ),
                        ),
                      ),
                    ],
                  ),
                  CustomTextField(
                    controller: c.dateC,
                    labelText: 'Tanggal Praktikum Sebelum Pertukaran ',
                    errorText: c.dateE.value,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      hintText: 'yyyy/mm/dd',
                      suffixIcon: IconButton(onPressed: c.selectDate, icon: Icon(Icons.date_range))
                    ),
                    onChanged: (v) {
                      if (v.length > 10) c.dateC.text = v.substring(0, 10);
                    },
                  ),
          
                  Divider(),
          
                  CustomTextField(
                    controller: c.namaPC,
                    labelText: 'Nama Praktikan Pengganti',
                    errorText: c.namaPE.value,
                    decoration: InputDecoration(hintText: 'e.g. Safaraz Akma Fadhil'),
                  ),
                  CustomTextField(
                    controller: c.nimPC,
                    labelText: 'Nim Praktikan Pengganti',
                    errorText: c.nimPE.value,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                    decoration: InputDecoration(hintText: 'e.g. 12345678'),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Praktikum Pengganti', textScaleFactor: 1.02,),
                                if (c.praktikumPE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                              ],
                            ),
                            DropdownFlutter<String>.search(
                              controller: c.praktikumP,
                              noResultFoundBuilder: (context, text) => Padding(
                                padding: EdgeInsetsGeometry.all(16),
                                child: Text(text, textAlign: TextAlign.center,),
                              ),
                              noResultFoundText: "Praktikum tidak ditemukan, silahkan hapus kolom pencarian dan pilih opsi 'Lainnya...'",
                              listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                              decoration: CustomDropdownDecoration(
                                searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.inputDecorationTheme.fillColor),
                                closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                closedBorder: c.praktikumPE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                              ),
                              excludeSelected: false,
                              items: ['Lainnya...'] + (NC.isSyncing.value ? [] : c.praktikumList),
                              hintText: NC.isSyncing.value ? 'Syncing in progress, please wait...' : 'select',
                              onChanged: (v) => c.isPraktikumPLainnya.value = v == 'Lainnya...',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: constrains.maxWidth * 0.15,
                        constraints: BoxConstraints(maxWidth: 160),
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Modul', textScaleFactor: 1.02, overflow: TextOverflow.ellipsis),
                                if (c.modulPE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                              ],
                            ),
                            DropdownFlutter<int>(
                              controller: c.modulP,
                              listItemBuilder: (context, item, isSelected, onItemSelect) => Text('$item', style: TextStyle(color: isSelected ? Colors.black : null),),
                              decoration: CustomDropdownDecoration(
                                closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                closedSuffixIcon: SizedBox(),
                                expandedSuffixIcon: SizedBox(),
                                closedBorder: c.modulPE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                              ),
                              excludeSelected: false,
                              items: List.generate(20, (i) => i + 1),
                              hintText: 'X',
                              onChanged: (v) {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (c.isPraktikumPLainnya.value) Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: c.kodePraktikumP,
                          labelText: 'Kode Praktikum',
                          errorText: c.kodePraktikumPE.value,
                          decoration: InputDecoration(
                            hintText: 'e.g. EL3017',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: c.namaPraktikumP,
                          labelText: 'Nama Praktikum',
                          errorText: c.namaPraktikumPE.value,
                          decoration: InputDecoration(
                            hintText: 'e.g. Sistem Tenaga Elektrik',
                          ),
                        ),
                      ),
                    ],
                  ),
                  CustomTextField(
                    controller: c.datePC,
                    labelText: 'Tanggal Praktikum Pengganti',
                    errorText: c.datePE.value,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      hintText: 'yyyy/mm/dd',
                      suffixIcon: IconButton(onPressed: c.selectDateP, icon: Icon(Icons.date_range))
                    ),
                    onChanged: (v) {
                      if (v.length > 10) c.datePC.text = v.substring(0, 10);
                    },
                  ),
                  ElevatedButton(onPressed: c.isLoading.value ? null : c.submit, child: Text('Format')),
                ],
              )),
            ),
          );
        }
      ),
    ); 
  }
}