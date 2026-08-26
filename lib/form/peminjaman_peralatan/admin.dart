import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/extension.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:number_paginator/number_paginator.dart';

class AdminPeminjamanPeralatan extends StatelessWidget {
  const AdminPeminjamanPeralatan({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AdminPeminjamanPeralatanController>();
    return  Obx(() {
      final sub = c.qfsped.value;
      final isAnySelected = sub.any((v) => c.isSelected.contains(v.id));
      final isMassLoading = c.isMassLoading.value;
      final canMassUpdate = isAnySelected && !isMassLoading && c.loadingIndicator.isEmpty;
      return Scaffold(
        appBar: AppBar(
          title: Text('Admin - Peminjaman Peralatan'),
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
                  final scale = constrains.maxWidth > 1280.0 ? (constrains.maxWidth / 1280.0) * 1.1 : 1.0;
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
                          width: constrains.maxWidth > 1280 ? constrains.maxWidth : 1280,
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
                                    SizedBox(width: 24),
                                    SizedBox(
                                      width: 224 * scale * 1.25,
                                      child: Text('Barang yang dipinjam', textScaleFactor: 1.2),
                                    ),
                                    SizedBox(width: 24),
                                    SizedBox(
                                      width: 192 * scale,
                                      child: Column(
                                        spacing: 4,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Tanggal Peminjaman', textScaleFactor: 1.2),
                                          Text('Tanggal Pengembalian', textScaleFactor: 1.2),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 24),
                                    SizedBox(
                                      width: 144 * scale,
                                      child: Text('Tanggal Dibuat', textScaleFactor: 1.2),
                                    ),
                                    SizedBox(width: 12),
                                    IconButton(
                                      onPressed: !canMassUpdate ? null : () => c.setSelectedStatus('borrowed'),
                                        icon: Icon(Icons.outbox_rounded, color: !canMassUpdate ? null : Colors.blue), tooltip: 'mark as borrowed'
                                    ),
                                    IconButton(
                                      onPressed: !canMassUpdate ? null : () => c.setSelectedStatus('returned'),
                                      icon: Icon(Icons.assignment_turned_in_rounded, color: !canMassUpdate ? null : Colors.green), tooltip: 'mark as returned'
                                    ),
                                    IconButton(
                                      onPressed: !canMassUpdate ? null : () => c.setSelectedStatus('overdue'),
                                      icon: Icon(Icons.running_with_errors_rounded, color: !canMassUpdate ? null : Colors.orange), tooltip: 'mark as overdue'
                                    ),
                                    IconButton(
                                      onPressed: !canMassUpdate ? null : () => c.setSelectedStatus('damaged'),
                                      icon: Icon(Icons.heart_broken_rounded, color: !canMassUpdate ? null : Colors.deepOrange), tooltip: 'mark as damaged'
                                    ),
                                    IconButton(
                                      onPressed: !canMassUpdate ? null : () => c.setSelectedStatus('lost'),
                                      icon: Icon(Icons.question_mark_rounded, color: !canMassUpdate ? null : Colors.purpleAccent), tooltip: 'mark as lost'
                                    ),
                                    IconButton(
                                      onPressed: !canMassUpdate ? null : () => c.setSelectedStatus('spam'),
                                      icon: Icon(Icons.report_rounded, color: !canMassUpdate ? null : Colors.red), tooltip: 'mark as spam'
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
                                      final isBorrowed = isLoading || entry.status == 'borrowed';
                                      final isReturned = isLoading || entry.status == 'returned';
                                      final isOverdue = isLoading || entry.status == 'overdue';
                                      final isDamaged = isLoading || entry.status == 'damaged';
                                      final isLost = isLoading || entry.status == 'lost';
                                      final isSpam = isLoading || entry.status == 'spam';
                                      return Card(
                                        color: appTheme.appBarTheme.backgroundColor,
                                        margin: EdgeInsets.zero,
                                        shape: BorderDirectional(
                                          start: BorderSide(
                                            color: (getColorFromSubmissionStatus(entry.status) ?? Colors.white).withAlpha(isLoading ? 128 : 255), 
                                            width: 8
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
                                                      fontSize: 15,
                                                      color: getColorFromSubmissionStatus(entry.status)
                                                    ),
                                                    maxLines: 1, 
                                                    textAlign: TextAlign.center
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          title: Text(entry.nama, overflow: TextOverflow.ellipsis,),
                                          subtitle: Text(entry.nim),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(width: 24),
                                              SizedBox(
                                                width: 224 * scale * 1.25,
                                                child: Text(entry.banyakBarang().join(', '), textScaleFactor: 1.2),
                                              ),
                                              SizedBox(width: 24),
                                              SizedBox(
                                                width: 192 * scale,
                                                child: Column(
                                                  spacing: 4,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(entry.mulai.toDateFormatString(), textScaleFactor: 1.2),
                                                    Text(entry.akhir.toDateFormatString(), textScaleFactor: 1.2),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 24),
                                              SizedBox(
                                                width: 144 * scale,
                                                child: Text(entry.createdAt.toDateTimeFormatedString(), textScaleFactor: 1.2),
                                              ),
                                              SizedBox(width: 12),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: isBorrowed ? null : () => c.setStatus(entry.id, 'borrowed'),
                                                      icon: Icon(Icons.outbox_rounded, color: isBorrowed ? null : Colors.blue), tooltip: 'mark as borrowed'
                                                  ),
                                                  IconButton(
                                                    onPressed: isReturned ? null : () => c.setStatus(entry.id, 'returned'),
                                                    icon: Icon(Icons.assignment_turned_in_rounded, color: isReturned ? null : Colors.green), tooltip: 'mark as returned'
                                                  ),
                                                  IconButton(
                                                    onPressed: isOverdue ? null : () => c.setStatus(entry.id, 'overdue'),
                                                    icon: Icon(Icons.running_with_errors_rounded, color: isOverdue ? null : Colors.orange), tooltip: 'mark as overdue'
                                                  ),
                                                  IconButton(
                                                    onPressed: isDamaged ? null : () => c.setStatus(entry.id, 'damaged'),
                                                    icon: Icon(Icons.heart_broken_rounded, color: isDamaged ? null : Colors.deepOrange), tooltip: 'mark as damaged'
                                                  ),
                                                  IconButton(
                                                    onPressed: isLost ? null : () => c.setStatus(entry.id, 'lost'),
                                                    icon: Icon(Icons.question_mark_rounded, color: isLost ? null : Colors.purpleAccent), tooltip: 'mark as lost'
                                                  ),
                                                  IconButton(
                                                    onPressed: isSpam ? null : () => c.setStatus(entry.id, 'spam'),
                                                    icon: Icon(Icons.report_rounded, color: isSpam ? null : Colors.red), tooltip: 'mark as spam'
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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