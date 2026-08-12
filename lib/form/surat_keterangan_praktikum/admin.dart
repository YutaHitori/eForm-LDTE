import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/extension.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:number_paginator/number_paginator.dart';

class AdminSuratKeteranganPraktikum extends StatelessWidget {
  const AdminSuratKeteranganPraktikum({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AdminSuratKeteranganPraktikumController>();
    return  Obx(() {
      final sub = c.qfsped.value;
      final isAnySelected = sub.any((v) => c.isSelected.contains(v.id));
      final isMassLoading = c.isMassLoading.value;
      final canMassUpdate = isAnySelected && !isMassLoading && c.loadingIndicator.isEmpty;      
      return Scaffold(
        appBar: AppBar(
          title: Text('Kiriman - Surat Keterangan Praktikum'),
          actions: [
            IconButton(onPressed: c.isLoading.value ? null : c.getAllSubmissions, icon: Icon(Icons.refresh_rounded))
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  CustomTextField(
                    controller: c.qfsp.queryController,
                    onChanged: (v) => c.qfsp.onChanged(),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: 'Search by Name or NIM'
                    ),
                    canError: false
                  ),
                  FilterRow(controller: c.qfsp, filterKey: 'status'),
                  SortRow(controller: c.qfsp),
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: c.startDateC,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            hintText: 'yyyy/mm/dd',
                            suffixIcon: IconButton(onPressed: c.selectDateFilterStart, icon: Icon(Icons.date_range))
                          ),
                          onChanged: (v) {
                            if (v.length > 10) c.startDateC.text = v.substring(0, 10);
                          },
                        ),
                      ),
                      Text('-', textScaleFactor: 1.6),
                      Expanded(
                        child: CustomTextField(
                          controller: c.endDateC,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            hintText: 'yyyy/mm/dd',
                            suffixIcon: IconButton(onPressed: c.selectDateFilterEnd, icon: Icon(Icons.date_range))
                          ),
                          onChanged: (v) {
                            if (v.length > 10) c.endDateC.text = v.substring(0, 10);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 0, color: appTheme.colorScheme.surface),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constrains) {
                  return c.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                    onRefresh: c.getAllSubmissions,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constrains.maxHeight,
                      ),
                      child: sub.isEmpty
                      ? SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: SizedBox( 
                          height: constrains.maxHeight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('- no data to display -', textScaleFactor: 1.2,),
                              Text('please use a different filters or scroll down to refresh'),
                            ],
                          ),
                        )
                      ) 
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: constrains.maxWidth > 860 ? constrains.maxWidth : 860,
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.only(right: 12),
                                leading: Transform.translate(
                                  offset: Offset(8, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        tristate: true,
                                        value: sub.any((v) => c.isSelected.contains(v.id)) 
                                        ? sub.every((v) => c.isSelected.contains(v.id)) 
                                          ? true : null 
                                        : false,
                                        onChanged: isMassLoading ? null : c.selectPageItem,
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Text('ID', textScaleFactor: 1.2, maxLines: 1, textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text('Nama'),
                                subtitle: Text('NIM'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 152,
                                      child: Text('Tanggal Dibuat', textScaleFactor: 1.2),
                                    ),
                                    IconButton(
                                      onPressed: !canMassUpdate ? null : () => c.setSelectedStatus('pending'),
                                        icon: Icon(Icons.pending_rounded, color: !canMassUpdate ? null : Colors.orange), tooltip: 'mark as pending'
                                    ),
                                    IconButton(
                                      onPressed: !canMassUpdate ? null : () => c.setSelectedStatus('exported'),
                                      icon: Icon(Icons.unarchive_rounded, color: !canMassUpdate ? null : Colors.green), tooltip: 'mark as exported'
                                    ),
                                    IconButton(
                                      onPressed: !canMassUpdate ? null : () => c.setSelectedStatus('spam'),
                                      icon: Icon(Icons.report_rounded, color: !canMassUpdate ? null : Colors.red), tooltip: 'mark as spam'
                                    ),
                                    VerticalDivider(color: appTheme.colorScheme.surface),
                                    IconButton(
                                      onPressed: null,
                                      icon: Icon(Icons.print_disabled_rounded), tooltip: 'unable to mass export'
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 0, color: appTheme.colorScheme.surface),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: c.getAllSubmissions,
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, i) {
                                      final entry = sub[i];
                                      final isLoading = c.loadingIndicator.contains(entry.id);
                                      final isPending = isLoading || entry.status == 'pending';
                                      final isExported = isLoading || entry.status == 'exported';
                                      final isSpam = isLoading || entry.status == 'spam';
                                      return ListTile(
                                        contentPadding: EdgeInsets.only(right: 12),
                                        // onLongPress: entry.nama.isBlank() ? null : () {
                                        //   Clipboard.setData(
                                        //     ClipboardData(text: entry.phone!),
                                        //   );
                                        //   ScaffoldMessenger.of(context).showSnackBar(
                                        //     SnackBar(content: Text('Phone number copied to clipboard!')),
                                        //   );
                                        // },
                                        onTap: () => c.detail(entry.id),
                                        leading: Transform.translate(
                                          offset: Offset(8, 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: c.isSelected.contains(entry.id), 
                                                onChanged: isMassLoading || isLoading ? null : (v) => c.selectItem(entry.id, v!)
                                              ),
                                              SizedBox(
                                                width: 40,
                                                child: Text(
                                                  '${entry.id}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: getColorFromSubmissionStatus(entry.status)
                                                  ),
                                                  maxLines: 1, 
                                                  textAlign: TextAlign.center
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        title: Text(entry.nama.toFormatedString(), overflow: TextOverflow.ellipsis,),
                                        subtitle: Text(entry.nim.toFormatedString()),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: 12),
                                            SizedBox(
                                              width: 152,
                                              child: Text(entry.createdAt.toDateTimeFormatedString(), textScaleFactor: 1.2),
                                            ),
                                            IconButton(
                                              onPressed: isPending ? null : () => c.setStatus(entry.id, 'pending'),
                                                icon: Icon(Icons.pending_rounded, color: isPending ? null : Colors.orange), tooltip: 'mark as pending'
                                            ),
                                            IconButton(
                                              onPressed: isExported ? null : () => c.setStatus(entry.id, 'exported'),
                                              icon: Icon(Icons.unarchive_rounded, color: isExported ? null : Colors.green), tooltip: 'mark as exported'
                                            ),
                                            IconButton(
                                              onPressed: isSpam ? null : () => c.setStatus(entry.id, 'spam'),
                                              icon: Icon(Icons.report_rounded, color: isSpam ? null : Colors.red), tooltip: 'mark as spam'
                                            ),
                                            VerticalDivider(color: appTheme.colorScheme.surface),
                                            IconButton(
                                              onPressed: c.isExporting.value ? null : () => c.preview(entry),
                                              icon: Icon(c.isExporting.value ? Icons.hourglass_top_rounded : Icons.print_rounded), tooltip: c.isExporting.value ? 'Export in progress, please wait' : 'preview and export'
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    itemCount: sub.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
            Divider(height: 0, color: appTheme.colorScheme.surface),
            NumberPaginator(
              numberPages: c.pageNum.value,
              controller: c.pageC,
              onPageChange: (int i) => c.qfsp.onChanged(),
              child: const SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PrevButton(),
                    Flexible(child: ScrollableNumberContent(shrinkWrap: true)),
                    NextButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}