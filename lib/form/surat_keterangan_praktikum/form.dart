import 'package:eform_ldte/misc/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/misc/extension.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/misc/widget.dart';

class SuratKeteranganPraktikum extends StatelessWidget {
  const SuratKeteranganPraktikum({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SuratKeteranganPraktikumController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Surat Keterangan Praktikum')
      ),
      body: Obx(() => c.isLoading.value
        ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              CircularProgressIndicator(),
              Text(c.message.value ?? 'Loading...')
            ],
          ),
        ) 
        : LayoutBuilder(
        builder: (context, constrains) {
          return RefreshIndicator(
            onRefresh: hardRefresh,
            child: SingleChildScrollView(
              child: Obx(() => Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    ExpansionTile(
                      minTileHeight: 0,
                      title: Text(
                        "Cara Pengisisan Formulir Surat Keterangan Praktikum:",
                        style: TextStyle(fontSize: 14.8),
                      ),
                      expandedAlignment: Alignment.centerLeft,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.only(bottom: 8),
                      children: [
                        Text(c.cara, style: TextStyle(fontSize: 12.4)),
                      ],
                    ),
                    for (var i = 0; i < c.itemN.value; i++) ...[
                      CustomTextField(
                        controller: c.namaC[i],
                        focusNode: c.namaF[i],
                        labelText: 'Nama Pemohon ${c.itemN.value == 1 ? '' : i+1}',
                        errorText: c.namaE[i],
                        decoration: InputDecoration(hintText: 'e.g. Safaraz Akma Fadhil'),
                      ),
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: c.nimC[i],
                              labelText: 'Nim Pemohon ${c.itemN.value == 1 ? '' : i+1}',
                              errorText: c.nimE[i],
                              keyboardType: TextInputType.number,
                              inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                              decoration: InputDecoration(hintText: 'e.g. 12345678'),
                            ),
                          ),
                          GestureDetector(
                            onTap: c.itemN.value <= 1 ? null : () => c.removeItem(i),
                            child: Icon(Icons.delete, color: c.itemN.value <= 1 ? null : Colors.redAccent,)
                          ),
                        ],
                      ),
                      if (i + 1 < c.itemN.value) Divider()
                    ],
                    ElevatedButton.icon(onPressed: c.itemN.value >= 4 ? null : c.addItem, icon: Icon(Icons.person_add_alt_1_rounded), label: Text('Tambah Pemohon'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mata Kuliah Yang Berhalangan Hadir', textScaleFactor: 1.02,),
                        if (c.matkulE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                      ],
                    ),
                    DropdownFlutter<String>.search(
                      noResultFoundBuilder: (context, text) => Padding(
                        padding: EdgeInsetsGeometry.all(16),
                        child: Text(text, textAlign: TextAlign.center,),
                      ),
                      noResultFoundText: "Mata kuliah tidak ditemukan, silahkan hapus kolom pencarian pilih opsi 'Lainnya...'",
                      controller: c.matkul,
                      listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                      decoration: CustomDropdownDecoration(
                        searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.scaffoldBackgroundColor),
                        closedFillColor: appTheme.inputDecorationTheme.fillColor,
                        expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                        closedBorder: c.matkulE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                      ),
                      excludeSelected: false,
                      items: ['Lainnya...'] + (NC.isSyncing.value ? [] : c.matkulList),
                      hintText: NC.isSyncing.value ? 'Syncing in progress, please wait...' : 'pilih mata kuliah',
                      onChanged: (v) => c.isMatkulLainnya.value = v == 'Lainnya...',
                    ),
                    if (c.isMatkulLainnya.value) Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: c.kodeMatkul,
                            labelText: 'Kode MatKul',
                            errorText: c.kodeMatkulE.value,
                            decoration: InputDecoration(
                              hintText: 'e.g. EL4034',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            labelText: 'Nama MatKul',
                            controller: c.namaMatkul,
                            errorText: c.namaMatkulE.value,
                            decoration: InputDecoration(
                              hintText: 'e.g. Proyek Robotika',
                            ),
                          ),
                        ),
                      ],
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
                                  Text('Praktikum Yang Dihadiri', textScaleFactor: 1.02,),
                                  if (c.praktikumE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                                ],
                              ),
                              DropdownFlutter<String>.search(
                                noResultFoundBuilder: (context, text) => Padding(
                                  padding: EdgeInsetsGeometry.all(16),
                                  child: Text(text, textAlign: TextAlign.center,),
                                ),
                                controller: c.praktikum,
                                noResultFoundText: "Praktikum tidak ditemukan, silahkan hapus kolom pencarian dan pilih opsi 'Lainnya...'",
                                listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                                decoration: CustomDropdownDecoration(
                                  searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.scaffoldBackgroundColor),
                                  closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  closedBorder: c.praktikumE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                                ),
                                excludeSelected: false,
                                items: ['Lainnya...'] + (NC.isSyncing.value ? [] : c.praktikumList),
                                hintText: NC.isSyncing.value ? 'Syncing in progress, please wait...' : 'pilih praktikum',
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Modul', textScaleFactor: 1.02,),
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
                            labelText: 'Kode Praktikum',
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
                            labelText: 'Nama Praktikum',
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
                      labelText: 'Tanggal Praktikum',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Waktu Praktikum', textScaleFactor: 1.02,),
                        if (c.timeStartE.value != null || c.timeEndE.value != null) Text(c.timeStartE.value ?? c.timeEndE.value!, style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                      ],
                    ),
                    SizedBox(
                      height: 80,
                      child: Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: Card(
                              color: c.timeStartE.value != null ? ColorScheme.dark().error : null,
                              child: InkWell(
                                onTap: c.selectTimeStart,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Mulai'),
                                    Text(c.timeStartC.value?.toFormatedString() ?? 'XX:XX', textScaleFactor: 1.64,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              color: c.timeEndE.value != null ? ColorScheme.dark().error : null,
                              child: InkWell(
                                onTap: c.selectTimeEnd,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Selesai'),
                                    Text(c.timeEndC.value?.toFormatedString() ?? 'XX:XX', textScaleFactor: 1.64,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Screenshot bukti jadwal praktikum', textScaleFactor: 1.02,),
                        if (c.buktiE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: c.selectImage,
                              label: Text('Choose an image'),
                              icon: Icon(Icons.image_search_rounded),
                              style: ElevatedButton.styleFrom(backgroundColor: c.buktiE.value != null ? appTheme.colorScheme.error : appTheme.colorScheme.secondary),
                            ),
                          ),
                        ElevatedButton(onPressed: c.bukti.value == null ? null : c.previewImage, child: Text('Preview'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.tertiary)),
                      ],  
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text("Selected: ${c.bukti.value?.name ?? '- none -'}"),
                          ),
                        ),
                        IconButton(
                          onPressed: c.bukti.value == null ? null : c.resetImage,
                          icon: Icon(Icons.delete_rounded, color: c.bukti.value == null ? null : Colors.redAccent),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(onPressed: c.submit, child: Text('Submit')),
                  ],
                ),
              )),
            ),
          );
        }
      ),
    )); 
  }
}