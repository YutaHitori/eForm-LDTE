import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/widget.dart';

class Pinjam extends StatelessWidget {
  const Pinjam({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PeminjamanPeralatanController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Peminjaman Peralatan')
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
      : RefreshIndicator(
        onRefresh: hardRefresh,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                ExpansionTile(
                  minTileHeight: 0,
                  title: Text(
                    "Cara Pengisisan Formulir Peminjaman Peralatan:",
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
                  labelText: 'Nama Peminjam',
                  errorText: c.namaE.value,
                  decoration: InputDecoration(hintText: 'e.g. Safaraz Akma Fadhil'),
                ),
                CustomTextField(
                  controller: c.nimC,
                  focusNode: c.nimF,
                  labelText: 'NIM Peminjam',
                  errorText: c.nimE.value,
                  decoration: InputDecoration(hintText: 'e.g. 123456789'),
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
                        Text(item, style: TextStyle(color: item == 'reset' ? Colors.red : isSelected ? Colors.black : null)),
                      decoration: CustomDropdownDecoration(
                        expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                        closedFillColor: appTheme.inputDecorationTheme.fillColor,
                        listItemStyle: TextStyle(color: Colors.black),
                      ),
                      excludeSelected: false,
                      items: ['reset'] + (NC.isSyncing.value ? [] : c.fakultasList),
                      hintText: NC.isSyncing.value ? 'Syncing in progress, please wait...' : 'pilih fakultas/sekolah',
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
                      hintText: c.fakultasC.hasValue ? 'pilih program studi' : 'pilih fakultas/sekolah terlebih dahulu',
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
                CustomTextField(
                  controller: c.dosenC,
                  focusNode: c.dosenF,
                  labelText: 'Dosen Pembimbing',
                  decoration: InputDecoration(hintText: 'e.g. Safaraz Akma Fadhil'),
                ),
                CustomTextField(
                  controller: c.nipDosenC,
                  focusNode: c.nipDosenF,
                  labelText: 'NIP Dosen Pembimbing',
                  decoration: InputDecoration(hintText: 'e.g. 123456789'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\/\s]')) ],
                ),
                CustomTextField(
                  controller: c.ketuaC,
                  focusNode: c.ketuaF,
                  labelText: 'Ketua Prodi',
                  decoration: InputDecoration(hintText: 'e.g. Safaraz Akma Fadhil'),
                ),
                CustomTextField(
                  controller: c.nipKetuaC,
                  focusNode: c.nipKetuaF,
                  labelText: 'NIP Ketua Prodi',
                  decoration: InputDecoration(hintText: 'e.g. 123456789'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\/\s]')) ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Barang yang Dipinjam ', textScaleFactor: 1.02),
                    if (c.barangE.value.any((v) => v != null) || c.banyakE.value.any((v) => v != null)) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
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
                                listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item == 'custom' ? NC.isSyncing.value ? 'Syncing in progress, please wait...' : item : item, style: TextStyle(color: isSelected ? Colors.black : null)),
                                decoration: CustomDropdownDecoration(
                                  searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.scaffoldBackgroundColor),
                                  closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  closedBorder: c.barangE.value[i] != null ? Border.all(color: appTheme.colorScheme.error) : null
                                ),
                                headerBuilder: (context, selectedItem, enabled) {
                                  return TextField(
                                    controller: c.barangC.value[i],
                                    decoration: InputDecoration(hintText: 'Nama Barang'),
                                    onChanged: (value) {
                                      change = false;
                                      final contain = c.items.firstWhereOrNull((v) => v.toLowerCase() == value.trim().toLowerCase());
                                      c.barangDC.value[i].value = contain ?? 'custom';
                                      change = true;
                                    },
                                  );
                                },
                                excludeSelected: false,
                                items: ['custom', if (!NC.isSyncing.value) ...c.items],
                                hintText: 'pilih nama barang',
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
                              width: 64,
                              child: Column(
                              spacing: 4,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownFlutter<int>(
                                  controller: c.banyakC.value[i],
                                  listItemBuilder: (context, item, isSelected, onItemSelect) => Text('$item', style: TextStyle(color: isSelected ? Colors.black : null),),
                                  decoration: CustomDropdownDecoration(
                                    closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                    expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                    closedSuffixIcon: SizedBox(),
                                    expandedSuffixIcon: SizedBox(),
                                    closedBorder: c.banyakE.value[i] != null ? Border.all(color: appTheme.colorScheme.error) : null
                                  ),
                                  excludeSelected: false,
                                  items: List.generate(9, (i) => i + 1),
                                  hintText: 'q',
                                  onChanged: (v) {},
                                ),
                              ],
                            ),
                            ),
                            GestureDetector(
                              onTap: c.barangDC.length <= 1 ? null :() { 
                                c.barangDC.value.removeAt(i); c.barangDC.refresh(); 
                                c.barangC.value.removeAt(i); c.barangC.refresh(); 
                                c.banyakC.value.removeAt(i); c.banyakC.refresh(); 
                                c.barangE.value.removeAt(i); c.barangE.refresh(); 
                                c.banyakE.value.removeAt(i); c.banyakE.refresh(); 
                              },
                              child: Icon(Icons.delete, color: c.barangDC.length <= 1 ? null : Colors.redAccent,)
                            ),
                          ],
                        )
                      ],
                    );
                  }
                ),
                ElevatedButton.icon(onPressed: c.barangDC.length >= 4 ? null : () {
                  c.barangDC.add(SingleSelectController<String>('custom'));
                  c.barangC.add(TextEditingController());
                  c.banyakC.add(SingleSelectController<int>(null));
                  c.barangE.add(null);
                  c.banyakE.add(null);
                }, icon: Icon(Icons.add), label: Text('Tambah Barang'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary)),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: c.mulaiC,
                        labelText: 'Tanggal Pinjam',
                        errorText: c.mulaiE.value,
                        labelFlexAxis: Axis.vertical,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          hintText: 'yyyy/mm/dd',
                          suffixIcon: IconButton(onPressed: c.selectDateStart, icon: Icon(Icons.date_range))
                        ),
                        onChanged: (v) {
                          if (v.length > 10) c.mulaiC.text = v.substring(0, 10);
                        },
                      ),
                    ),
                    Text('-', textScaleFactor: 1.6),
                    Expanded(
                      child: CustomTextField(
                        controller: c.akhirC,
                        labelText: 'Tanggal Pengembalian',
                        errorText: c.akhirE.value,
                        labelFlexAxis: Axis.vertical,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          hintText: 'yyyy/mm/dd',
                          suffixIcon: IconButton(onPressed: c.selectDateEnd, icon: Icon(Icons.date_range))
                        ),
                        onChanged: (v) {
                          if (v.length > 10) c.akhirC.text = v.substring(0, 10);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Foto/Scan Kartu Identitas Peminjam', textScaleFactor: 1.02,),
                    if (c.idCardE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
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
                        style: ElevatedButton.styleFrom(backgroundColor: c.idCardE.value != null ? appTheme.colorScheme.error : appTheme.colorScheme.secondary),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: c.idCard.value == null
                          ? null : c.previewImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appTheme.colorScheme.tertiary,
                      ),
                      child: Text('Preview'),
                    ),
                  ],  
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text("Selected: ${c.idCard.value?.name ?? '- none -'}"),
                      ),
                    ),
                    IconButton(
                      onPressed: c.idCard.value == null ? null : c.resetImage,
                      icon: Icon(Icons.delete_rounded, color: c.idCard.value == null ? null : Colors.redAccent),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                ElevatedButton(onPressed: c.submit, child: Text('Pinjam')),
              ],
            ),
          ),
        ),
      )),
    ); 
  }
}