import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:go_router/go_router.dart';

class DetailPeminjamanPeralatan extends StatelessWidget {
  const DetailPeminjamanPeralatan({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DetailPeminjamanPeralatanController>();
    final ac = Get.find<AdminPeminjamanPeralatanController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail - Peminjaman Peralatan')
      ),
      body: Obx(() => ac.isLoading.value
      ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            CircularProgressIndicator(),
            Text(
              ac.submissions.isEmpty
                ? 'Fetching form data, please wait'
                : 'Updating form data, please wait'
            )
          ],
        ),
      ) 
      : ac.submissions.every((v) => v.id != c.id)
      ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            Text(c.id == -1 ? "invalid ID parameter, please check the inputed url" : "Data with ID ${c.id} didn't exist"),
            TextButton(onPressed: currentContext?.pop, child: Text('Go back'))
          ],
        ),
      ) 
      : RefreshIndicator(
        onRefresh: hardRefresh,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                ExpansionTile(
                  minTileHeight: 0,
                  title: Text(
                    "Cara Pengisisan Formulir Peminjaman Peralatan:",
                    style: TextStyle(fontSize: 13.2),
                  ),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.only(bottom: 8),
                  expandedAlignment: Alignment.centerLeft,
                  children: [
                    Text(
'''- Isi kolom yang diperlukan secara online.
- Beberapa kolom dapat dikosongkan jika tidak ada, tidak tahu, atau akan diisi setelah formulir diprint.
- 1 formulir dapat digunakan untuk meminjam beberapa barang sekaligus (hingga 4 barang).
- Setelah mengisi, klik tombol "Pinjam" untuk preview dokumen dan periksa apakah semua data sudah benar.
- Dokumen kemudian dapat didownload dan diprint untuk ditandatangani, kemudian diserahkan pada saat menerima barang.''',
                      style: TextStyle(fontSize: 12.4),
                    ),
                  ],
                ),
                CustomTextField(
                  controller: c.namaC,
                  labelText: 'Nama Peminjam',
                  errorText: c.namaE.value,
                  decoration: InputDecoration(hintText: '-'),
                ),
                CustomTextField(
                  controller: c.nimC,
                  labelText: 'NIM Peminjam',
                  errorText: c.nimE.value,
                  decoration: InputDecoration(hintText: '-'),
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
                                listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
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
                }, icon: Icon(Icons.add), label: Text('Add item'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary)),
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
                ElevatedButton(onPressed: c.updateForm, child: Text('Update')),
              ],
            ),
          ),
        ),
      )),
    ); 
  }
}