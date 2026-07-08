import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/misc/global.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/core/custom-widget.dart';

class Pinjam extends StatelessWidget {
  const Pinjam({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PinjamController());
    return Scaffold(
      appBar: AppBar(
        leading: canPop
          ? null : IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Get.offNamed('/'),
          ),
        title: Text('Form Peminjaman Peralatan')
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text('''Cara Pengisisan Formulir Peminjaman Peralatan LDTE STEI ITB :
- Isi kolom yang diperlukan secara online.
- Kosongkan kolom jika tidak ada, tidak tahu, atau akan diisi setelah di print.
- Form yang telah diisi dapat di download dan di print untuk di tandatangani, kemudian diserahkan pada saat menerima barang.
              ''',),
              AutoHideTextField(
                labelText: 'Nama',
                decoration: InputDecoration(hintText: '-'),
                controller: c.namaC,
              ),
              AutoHideTextField(
                labelText: 'NIM',
                decoration: InputDecoration(hintText: '-'),
                controller: c.nimC,
                keyboardType: TextInputType.number,
                inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\/\s]')) ],
              ),
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('Fakultas/Sekolah ', textScaleFactor: 1.02,),
                  DropdownFlutter<String>(
                    listItemBuilder: (context, item, isSelected, onItemSelect) => 
                      Text('${item}', style: TextStyle(color: item == 'reset' ? Colors.red : isSelected ? Colors.black : null)),
                    decoration: CustomDropdownDecoration(
                      expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                      closedFillColor: appTheme.inputDecorationTheme.fillColor,
                      listItemStyle: TextStyle(color: Colors.black),
                    ),
                    excludeSelected: false,
                    items: ['reset', ...fakultas],
                    controller: c.fakultasC,
                    onChanged: (value) { 
                      if (value == 'reset') c.fakultasC.value = null;
                      c.setProdi(); 
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('Program Studi ', textScaleFactor: 1.02,),
                  DropdownFlutter<String>(
                    hintText: c.fakultasC.hasValue ? null : 'fakultas/sekolah belum dipilih',
                    listItemBuilder: (context, item, isSelected, onItemSelect) => 
                      Text('${item}', style: TextStyle(color: item == 'reset' ? Colors.red : isSelected ? Colors.black : null)),
                    decoration: CustomDropdownDecoration(
                      expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                      closedFillColor: appTheme.inputDecorationTheme.fillColor,
                      listItemStyle: TextStyle(color: Colors.black),
                    ),
                    excludeSelected: false,
                    items: ['reset', ...c.prodiList.value],
                    controller: c.prodiC,
                    onChanged: (value) {
                      if (value == 'reset') c.prodiC.value = null;
                    },
                    disabledDecoration: CustomDropdownDisabledDecoration(
                      fillColor: appTheme.hoverColor.withAlpha(6),
                      suffixIcon: Icon(Icons.lock, size: 0),
                    ),
                    enabled: c.fakultasC.hasValue,
                  ),
                ],
              ),
              AutoHideTextField(
                labelText: 'Dosen Pembimbing',
                decoration: InputDecoration(hintText: '-'),
                controller: c.dosenC,
              ),
              AutoHideTextField(
                labelText: 'NIP Dosen Pembimbing',
                decoration: InputDecoration(hintText: '-'),
                controller: c.nipDosenC,
                keyboardType: TextInputType.number,
                inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\/\s]')) ],
              ),
              AutoHideTextField(
                labelText: 'Ketua Prodi',
                decoration: InputDecoration(hintText: '-'),
                controller: c.ketuaC,
              ),
              AutoHideTextField(
                labelText: 'NIP Ketua Prodi',
                decoration: InputDecoration(hintText: '-'),
                controller: c.nipKetuaC,
                keyboardType: TextInputType.number,
                inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\/\s]')) ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Barang yang Dipinjam ', textScaleFactor: 1.02),
                ],
              ),
              Builder(
                builder: (context) {
                  var change = true;
                  return Column(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < c.barangC.value.length; i++) Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: DropdownFlutter<String>.search(
                              controller: c.barangDC.value[i],
                              expandedHeaderPadding: EdgeInsets.only(right: 12),
                              closedHeaderPadding: EdgeInsets.only(right: 12),
                              listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                              decoration: CustomDropdownDecoration(
                                searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.inputDecorationTheme.fillColor),
                                closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                              ),
                              headerBuilder: (context, selectedItem, enabled) {
                                return TextField(
                                  controller: c.barangC.value[i],
                                  decoration: InputDecoration(hintText: 'Nama Barang'),
                                  onChanged: (value) {
                                    change = false;
                                    var contain = items.where((v) => v.toLowerCase() == value.toLowerCase());
                                    if (contain.isEmpty) {
                                      c.barangDC.value[i].value = 'custom';
                                    } else c.barangDC.value[i].value = contain.first;
                                    change = true;
                                  },
                                );
                              },
                              excludeSelected: false,
                              items: items,
                              hintText: 'select',
                              onChanged: (v) {
                                if (!change) return;
                                var text = v;
                                if (v == 'custom') text = null;
                                c.barangC.value[i] = TextEditingController(text: text);
                              },
                            ),
                          ),
                          Text('x'),
                          SizedBox(
                            width: 48,
                            child: AutoHideTextField(
                              controller: c.banyakC.value[i],
                              keyboardType: TextInputType.number,
                              inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                              decoration: InputDecoration(hintText: 'q', contentPadding: EdgeInsets.all(6)),
                            ),
                          ),
                          GestureDetector(
                            onTap: c.barangDC.length <= 1 ? null :() { 
                              c.barangDC.value.removeAt(i); c.barangDC.refresh(); 
                              c.barangC.value.removeAt(i); c.barangC.refresh(); 
                              c.banyakC.value.removeAt(i); c.banyakC.refresh(); 
                            },
                            child: Icon(Icons.delete, color: c.barangDC.length <= 1 ? null : Colors.redAccent,)
                          ),
                        ],
                      )
                    ],
                  );
                }
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kIsWeb ? 8 : 0),
                child: ElevatedButton.icon(onPressed: c.barangDC.length >= 4 ? null : () {
                  c.barangDC.add(SingleSelectController<String>('custom'));
                  c.barangC.add(TextEditingController());
                  c.banyakC.add(TextEditingController(text: '1'));
                }, icon: Icon(Icons.add), label: Text('Add item'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary)),
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: AutoHideTextField(
                      labelText: 'Tanggal Pinjam',
                      controller: c.startDateC,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: 'yyyy/mm/dd',
                        suffixIcon: IconButton(onPressed: () => c.selectDateStart(context), icon: Icon(Icons.date_range))
                      ),
                      onChanged: (v) {
                        if (v.length > 10) c.startDateC.text = v.substring(0, 10);
                      },
                    ),
                  ),
                  Text('-', textScaleFactor: 1.6),
                  Expanded(
                    child: AutoHideTextField(
                      labelText: 'Tanggal Pengembalian',
                      controller: c.endDateC,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: 'yyyy/mm/dd',
                        suffixIcon: IconButton(onPressed: () => c.selectDateEnd(context), icon: Icon(Icons.date_range))
                      ),
                      onChanged: (v) {
                        if (v.length > 10) c.endDateC.text = v.substring(0, 10);
                      },
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Foto/Scan KTM peminjam', textScaleFactor: 1.02,),
                  Row(
                    spacing: 8,
                    children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: c.selectKtm,
                            label: Text('Choose an image'),
                            icon: Icon(Icons.image_search_rounded),
                            style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary),
                          ),
                        ),
                      ElevatedButton(onPressed: c.ktm.value == null ? null : c.previewKtm, child: Text('Preview'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.tertiary)),
                    ],  
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text("Selected: ${c.ktm.value?.name.substring(4) ?? '- none -'}"),
                      ),
                      IconButton(
                        onPressed: c.ktm.value == null ? null : c.resetKtm,
                        icon: Icon(Icons.delete_rounded, color: c.ktm.value == null ? null : Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Foto/Scan KTP peminjam', textScaleFactor: 1.02,),
                  Row(
                    spacing: 8,
                    children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: c.selectKtp,
                            label: Text('Choose an image'),
                            icon: Icon(Icons.image_search_rounded),
                            style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary),
                          ),
                        ),
                      ElevatedButton(onPressed: c.ktp.value == null ? null : c.previewKtp, child: Text('Preview'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.tertiary)),
                    ],  
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text("Selected: ${c.ktp.value?.name.substring(4) ?? '- none -'}"),
                      ),
                      IconButton(
                        onPressed: c.ktp.value == null ? null : c.resetKtp,
                        icon: Icon(Icons.delete_rounded, color: c.ktp.value == null ? null : Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(onPressed: c.isLoading.value ? null : c.pinjam, child: Text(c.isLoading.value ? 'Generating...' : 'Pinjam')),
            ],
          )),
        ),
      ),
    ); 
  }
}