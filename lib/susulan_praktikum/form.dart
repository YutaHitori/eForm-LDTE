import 'package:eform_ldte/misc/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/widget.dart';

class SusulanPraktikum extends StatelessWidget {
  const SusulanPraktikum({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SusulanPraktikumController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Template Permohonan Susulan')
      ),
      body: Obx(() => c.isLoading.value
        ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              CircularProgressIndicator(),
              Text('Generating PDF, please wait')
            ],
          ),
        )  
        : storage.cached.globalConfig.disabledForm?.contains(router.state.fullPath) ?? false
        ? Center(
          child: Padding(
            padding: const EdgeInsets.all(42),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 32,
              children: [
                Icon(Icons.do_disturb_on, size: 92),
                Text('Form disabled []~(￣▽￣)~*', textScaleFactor: 1.5),
                Text('the current form has been disbled temporarily due to ongoing maintenance or other reason(s), plese try again later.', textAlign: TextAlign.center,textScaleFactor: 1.1,),
              ],
            ),
          ),
        ) 
        : LayoutBuilder(
        builder: (context, constrains) {
          return RefreshIndicator(
            onRefresh: hardRefresh,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    ExpansionTile(
                      minTileHeight: 0,
                      title: Text(
                        "Cara Pengisian Template Permohonan Susulan:",
                        style: TextStyle(fontSize: 14.8),
                      ),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.only(bottom: 8),
                      expandedAlignment: Alignment.centerLeft,
                      children: [
                        Text(c.cara, style: TextStyle(fontSize: 12.4)),
                      ],
                    ),
                    CustomTextField(
                      controller: c.namaC,
                      focusNode: c.namaF,
                      labelText: 'Nama Praktikan',
                      errorText: c.namaE.value,
                      decoration: InputDecoration(hintText: 'e.g. Safaraz Akma Fadhil'),
                    ),
                    CustomTextField(
                      controller: c.nimC,
                      focusNode: c.nimF,
                      labelText: 'NIM Praktikan',
                      errorText: c.nimE.value,
                      decoration: InputDecoration(hintText: 'e.g. 123456789'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\/\s]')) ],
                    ),
                    CustomTextField(
                      controller: c.dosenC,
                      focusNode: c.dosenF,
                      errorText: c.dosenE.value,
                      labelText: 'Nama Dosen Pengampu',
                      decoration: InputDecoration(hintText: 'e.g. Safaraz Akma Fadhil'),
                    ),
                    CustomTextField(
                      controller: c.nipC,
                      focusNode: c.nipF,
                      errorText: c.nipE.value,
                      labelText: 'NIP Dosen Pengampu',
                      decoration: InputDecoration(hintText: 'e.g. 123456789'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\/\s]')) ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Program Studi ', textScaleFactor: 1.02,),
                            if (c.prodiE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                          ],
                        ),
                        DropdownFlutter<String>(
                          hintText: NC.isSyncing.value ? 'Syncing in progress, please wait...' : 'pilih program studi',
                          listItemBuilder: (context, item, isSelected, onItemSelect) => 
                            Text(item, style: TextStyle(color: item == 'reset' ? Colors.red : isSelected ? Colors.black : null)),
                          decoration: CustomDropdownDecoration(
                            expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                            closedFillColor: appTheme.inputDecorationTheme.fillColor,
                            listItemStyle: TextStyle(color: Colors.black),
                            closedBorder: c.prodiE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                          ),
                          excludeSelected: false,
                          items: ['reset', if (!NC.isSyncing.value) ...c.prodiList],
                          controller: c.prodiC,
                          onChanged: (value) {
                            if (value == 'reset') c.prodiC.value = null;
                            c.setPraktikumList();
                          },
                          disabledDecoration: CustomDropdownDisabledDecoration(
                            fillColor: appTheme.hoverColor.withAlpha(6),
                            border: c.prodiE.value != null ? Border.all(color: appTheme.colorScheme.error) : null,
                            suffixIcon: Icon(Icons.lock, size: 0),
                          ),
                          enabled: !NC.isSyncing.value,
                        ),
                      ],
                    ),
                    Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Praktikum', textScaleFactor: 1.02,),
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
                          items: ['Lainnya...', ...c.praktikumList],
                          hintText: c.prodiC.hasValue ? 'pilih praktikum' : 'pilih program studi terlebih dahulu',
                          onChanged: (v) => c.isPraktikumLainnya.value = v == 'Lainnya...',
                          disabledDecoration: CustomDropdownDisabledDecoration(
                            fillColor: appTheme.hoverColor.withAlpha(6),
                            border: c.praktikumE.value != null ? Border.all(color: appTheme.colorScheme.error) : null,
                            suffixIcon: Icon(Icons.lock, size: 0),
                          ),
                          enabled: c.prodiC.hasValue,
                        ),
                      ],
                    ),
                    if (c.isPraktikumLainnya.value) Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: c.kodePraktikum,
                            errorText: c.kodePraktikumE.value,
                            focusNode: c.kodePraktikumF,
                            labelText: 'Kode Praktikum',
                            decoration: InputDecoration(
                              hintText: 'e.g. EL3017',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: c.namaPraktikum,
                            errorText: c.namaPraktikumE.value,
                            focusNode: c.namaPraktikumF,
                            labelText: 'Nama Praktikum',
                            decoration: InputDecoration(
                              hintText: 'e.g. Sistem Tenaga Elektrik',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Modul (nomor - judul)', textScaleFactor: 1.02),
                        if (c.modulE.any((v) => v != null) || c.judulModulE.any((v) => v != null)) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                      ],
                    ),
                    Column(
                      spacing: 4,
                      children: [
                        for (var i = 0; i < c.itemN.value; i++) Row(
                          spacing: 8,
                          children: [
                            Container(
                              width: constrains.maxWidth * 0.15,
                              constraints: BoxConstraints(maxWidth: 160),
                              child: DropdownFlutter<int>(
                                controller: c.modulC[i],
                                listItemBuilder: (context, item, isSelected, onItemSelect) => Text('$item', style: TextStyle(color: isSelected ? Colors.black : null),),
                                decoration: CustomDropdownDecoration(
                                  closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  closedSuffixIcon: SizedBox(),
                                  expandedSuffixIcon: SizedBox(),
                                  closedBorder: c.modulE[i] != null ? Border.all(color: appTheme.colorScheme.error) : null
                                ),
                                excludeSelected: false,
                                items: [...c.modulList, ?c.modulC[i].value]..sort(),
                                hintText: 'N',
                                onChanged: (v) => c.setModulList(),
                              ),
                            ),
                            Text('-', textScaleFactor: 1.6,),
                            Expanded(
                              child: CustomTextField(
                                controller: c.judulModulC[i],
                                errorText: c.judulModulE[i],
                                focusNode: c.judulModulF[i],
                                decoration: InputDecoration(hintText: 'Judul Modul'),
                              ),
                            ),
                            GestureDetector(
                              onTap: c.itemN.value <= 1 ? null : () => c.removeItem(i),
                              child: Icon(Icons.delete, color: c.itemN.value <= 1 ? null : Colors.redAccent)
                            ),
                          ],
                        )
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: c.itemN.value >= 7 ? null : c.addItem, 
                      icon: Icon(Icons.add), label: Text('Tambah Modul'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary)
                    ),
                    SizedBox(),
                    CustomTextField(
                      controller: c.alasanC,
                      focusNode: c.alasanF,
                      errorText: c.alasanE.value,
                      labelText: 'Alasan Tidak Hadir',
                      decoration: InputDecoration(hintText: 'e.g. \n\n\n'),
                      keyboardType: TextInputType.multiline,
                      maxHeight: 384,
                      maxLines: null,
                      onChanged: (v) {
                        c.alasanN.value = v.length;
                      },
                      indicator: Text('${c.alasanN.value <= 500 ? '' : 'character limit exeeded'} (${c.alasanN.value}/500)', style: TextStyle(color: c.alasanN.value <= 500 ? null : appTheme.colorScheme.error), textAlign: TextAlign.end),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(onPressed: c.submit, child: Text('Generate')),
                  ],
                )),
              ),
            ),
          );
        }
      )),
    ); 
  }
}