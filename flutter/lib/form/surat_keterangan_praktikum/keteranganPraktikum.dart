import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/misc/extension.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/core/custom-widget.dart';
import 'package:ldte_stei_itb/misc/matkul.dart';

class SuratKeteranganPraktikum extends StatelessWidget {
  const SuratKeteranganPraktikum({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SuratKeteranganPraktikumController());
    return Scaffold(
      appBar: AppBar(
        leading: canPop
          ? null : IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Get.offNamed('/'),
          ),
        title: Text('Surat Keterangan Praktikum')
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text('''Cara Pengisisan Surat Keterangan Praktikum LDTE STEI ITB :
- 
              ''',),
              for (var i = 0; i < c.namaC.value.length; i++) ...[
                AutoHideTextField(
                  controller: c.namaC.value[i],
                  labelText: 'Nama ${c.namaC.value.length == 1 ? '' : i+1}',
                  errorText: c.namaE.value[i],
                  decoration: InputDecoration(hintText: 'Nama'),
                ),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: AutoHideTextField(
                        controller: c.nimC.value[i],
                        labelText: 'Nim ${c.namaC.value.length == 1 ? '' : i+1}',
                        errorText: c.nimE.value[i],
                        keyboardType: TextInputType.number,
                        inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                        decoration: InputDecoration(hintText: 'Nim'),
                      ),
                    ),
                    GestureDetector(
                      onTap: c.namaC.length <= 1 ? null :() { 
                        c.namaC.value.removeAt(i); c.namaC.refresh(); 
                        c.nimC.value.removeAt(i); c.nimC.refresh(); 
                        c.namaE.value.removeAt(i); c.namaE.refresh(); 
                        c.nimE.value.removeAt(i); c.nimE.refresh(); 
                      },
                      child: Icon(Icons.delete, color: c.namaC.length <= 1 ? null : Colors.redAccent,)
                    ),
                  ],
                ),
                if (i + 1 < c.namaC.value.length) Divider()
              ],
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kIsWeb ? 8 : 0),
                child: ElevatedButton.icon(onPressed: c.namaC.length >= 4 ? null : () {
                  c.namaC.add(TextEditingController());
                  c.nimC.add(TextEditingController());
                  c.namaE.add(null);
                  c.nimE.add(null);
                }, icon: Icon(Icons.add), label: Text('Add'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mata Kuliah Yang Berhalangan Hadir', textScaleFactor: 1.02,),
                  if (c.matkulE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error)),
                ],
              ),
              DropdownFlutter<String>.search(
                controller: c.matkul,
                listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                decoration: CustomDropdownDecoration(
                  searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.inputDecorationTheme.fillColor),
                  closedFillColor: appTheme.inputDecorationTheme.fillColor,
                  expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                  closedBorder: c.matkulE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                ),
                excludeSelected: false,
                items: ['Lainnya...'] + matkul,
                hintText: 'select',
                onChanged: (v) => c.isMatkulLainnya.value = v == 'Lainnya...',
              ),
              if (c.isMatkulLainnya.value) Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: AutoHideTextField(
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
                    child: AutoHideTextField(
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
                    flex: 6,
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Praktikum Yang Dihadiri', textScaleFactor: 1.02,),
                            if (c.matkulE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error)),
                          ],
                        ),
                        DropdownFlutter<String>.search(
                          controller: c.praktikum,
                          listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                          decoration: CustomDropdownDecoration(
                            searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.inputDecorationTheme.fillColor),
                            closedFillColor: appTheme.inputDecorationTheme.fillColor,
                            expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                            closedBorder: c.praktikumE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                          ),
                          excludeSelected: false,
                          items: ['Lainnya...'] + matkul,
                          hintText: 'select',
                          onChanged: (v) => c.isPraktikumLainnya.value = v == 'Lainnya...',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Modul', textScaleFactor: 1.02,),
                            if (c.modulE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error)),
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
                    child: AutoHideTextField(
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
                    child: AutoHideTextField(
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
              AutoHideTextField(
                controller: c.dateC,
                labelText: 'Tanggal Praktikum',
                errorText: c.dateE.value,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  hintText: 'yyyy/mm/dd',
                  suffixIcon: IconButton(onPressed: () => c.selectDate(context), icon: Icon(Icons.date_range))
                ),
                onChanged: (v) {
                  if (v.length > 10) c.dateC.text = v.substring(0, 10);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Waktu Praktikum', textScaleFactor: 1.02,),
                  if (c.timeStartE.value != null || c.timeEndE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error)),
                ],
              ),
              SizedBox(
                height: 92,
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Card(
                        color: c.timeStartE.value != null ? ColorScheme.dark().error : null,
                        child: InkWell(
                          onTap: () => c.selectTimeStart(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Mulai'),
                              Text(c.timeStartC.value?.toFormatedString() ?? 'XX:XX', textScaleFactor: 1.8,),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        color: c.timeEndE.value != null ? ColorScheme.dark().error : null,
                        child: InkWell(
                          onTap: () => c.selectTimeEnd(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Selesai'),
                              Text(c.timeEndC.value?.toFormatedString() ?? 'XX:XX', textScaleFactor: 1.8,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Screenshot bukti jadwal praktikum', textScaleFactor: 1.02,),
                      if (c.buktiE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error)),
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
                            style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary),
                          ),
                        ),
                      ElevatedButton(onPressed: c.bukti.value == null ? null : c.previewImage, child: Text('Preview'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.tertiary)),
                    ],  
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text("Selected: ${c.bukti.value?.name ?? '- none -'}"),
                      ),
                      IconButton(
                        onPressed: c.bukti.value == null ? null : c.resetImage,
                        icon: Icon(Icons.delete_rounded, color: c.bukti.value == null ? null : Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(onPressed: c.isLoading.value ? null : c.submit, child: Text(c.isLoading.value ? 'Generating...' : 'Submit')),
            ],
          )),
        ),
      ),
    ); 
  }
}