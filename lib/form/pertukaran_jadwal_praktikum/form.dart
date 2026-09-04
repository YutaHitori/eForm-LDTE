import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/misc/widget.dart';

class PertukaranJadwalPraktikum extends StatelessWidget {
  const PertukaranJadwalPraktikum({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PertukaranJadwalPraktikumController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Pertukaran Jadwal Praktikum')
      ),
      body: storage.cached.globalConfig.disabledForm?.contains(router.state.fullPath) ?? false
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
        ) : LayoutBuilder(
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
                        "Cara Pengisian Formulir Pergantian Jadwal Praktikum:",
                        style: TextStyle(fontSize: 14.8),
                      ),
                      expandedAlignment: Alignment.centerLeft,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.only(bottom: 8),
                      children: [
                        Text(c.cara,style: TextStyle(fontSize: 12.4)),
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
                      labelText: 'NIM Praktikian',
                      errorText: c.nimE.value,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                      decoration: InputDecoration(hintText: 'e.g. 12345678'),
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
                    ),
            
                    Divider(),
            
                    CustomTextField(
                      controller: c.namaPC,
                      focusNode: c.namaPF,
                      labelText: 'Nama Praktikan Pengganti',
                      errorText: c.namaPE.value,
                      decoration: InputDecoration(hintText: 'e.g. Safaraz Akma Fadhil'),
                    ),
                    CustomTextField(
                      controller: c.nimPC,
                      focusNode: c.nimPF,
                      labelText: 'Nim Praktikan Pengganti',
                      errorText: c.nimPE.value,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                      decoration: InputDecoration(hintText: 'e.g. 12345678'),
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
                    ),

                    Divider(), 
                    
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
                                  Text('Praktikum', textScaleFactor: 1.02,),
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
                                listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item + (item == 'Lainnya...' && NC.isSyncing.value ? ' (Syncing in progress, please wait...)' : ''), style: TextStyle(color: isSelected ? Colors.black : null),),
                                decoration: CustomDropdownDecoration(
                                  searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.scaffoldBackgroundColor),
                                  closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  closedBorder: c.praktikumE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                                ),
                                excludeSelected: false,
                                items: ['Lainnya...', if (!NC.isSyncing.value) ...c.praktikumList],
                                hintText: 'pilih praktikum',
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
                                items: List.generate(9, (i) => i + 1),
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
                            focusNode: c.kodePraktikumF,
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
                            focusNode: c.namaPraktikumF,
                            labelText: 'Nama',
                            errorText: c.namaPraktikumE.value,
                            decoration: InputDecoration(
                              hintText: 'e.g. Sistem Tenaga Elektrik',
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),
                    ElevatedButton(onPressed: c.isLoading.value ? null : c.submit, child: Text('Format')),
                  ],
                )),
              ),
            ),
          );
        }
      ),
    ); 
  }
}