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
            Text(c.id == -1 ? "invalid ID parameter (${c.id}), please check the inputed url" : "Data with ID ${c.id} didn't exist"),
            TextButton(onPressed: currentContext?.pop, child: Text('Go back'))
          ],
        ),
      ) 
      : Builder(
        builder: (context) {
          c.setInitialValue();
          return Obx(() => RefreshIndicator(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Barang yang Dipinjam ', textScaleFactor: 1.02),
                        if (c.barangE.any((v) => v != null) || c.banyakE.any((v) => v != null)) Text('*required', style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0)),
                      ],
                    ),
                    Column(
                      spacing: 8,
                      children: [
                        for (var i = 0; i < c.itemN.value; i++) Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: DropdownFlutter<String>.search(
                                controller: c.barangDC[i],
                                expandedHeaderPadding: EdgeInsets.only(right: 12),
                                closedHeaderPadding: EdgeInsets.only(right: 12),
                                listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item == 'custom' ? NC.isSyncing.value ? 'Syncing in progress, please wait...' : item : item, style: TextStyle(color: isSelected ? Colors.black : null)),
                                decoration: CustomDropdownDecoration(
                                  searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.scaffoldBackgroundColor),
                                  closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                  closedBorder: c.barangE[i] != null ? Border.all(color: appTheme.colorScheme.error) : null
                                ),
                                headerBuilder: (context, selectedItem, enabled) => TextField(
                                  controller: c.barangC[i],
                                  focusNode: c.barangF[i],
                                  decoration: InputDecoration(hintText: 'Nama Barang'),
                                  onChanged: (value) => c.selectIfExist(i, value),
                                ),
                                excludeSelected: false,
                                items: ['custom', if (!NC.isSyncing.value) ...c.items],
                                hintText: 'pilih nama barang',
                                onChanged: (v) => c.changeText(i, v),
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
                                  controller: c.banyakC[i],
                                  listItemBuilder: (context, item, isSelected, onItemSelect) => Text('$item', style: TextStyle(color: isSelected ? Colors.black : null),),
                                  decoration: CustomDropdownDecoration(
                                    closedFillColor: appTheme.inputDecorationTheme.fillColor,
                                    expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                                    closedSuffixIcon: SizedBox(),
                                    expandedSuffixIcon: SizedBox(),
                                    closedBorder: c.banyakE[i] != null ? Border.all(color: appTheme.colorScheme.error) : null
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
                              onTap: c.itemN.value <= 1 ? null : () => c.removeItem(i),
                              child: Icon(Icons.delete, color: c.itemN.value <= 1 ? null : Colors.redAccent)
                            ),
                          ],
                        )
                      ],
                    ),
                    ElevatedButton.icon(onPressed: c.itemN.value >= 4 ? null : c.addItem, icon: Icon(Icons.add), label: Text('Tambah Barang'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary)),
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
                    ElevatedButton(onPressed: c.submit, child: Text('Update')),
                  ],
                ),
              ),
            ),
          ));
        }
      )),
    ); 
  }
}