import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final c = Get.put(AdminPeminjamanPeralatanController());
    return  Obx(() {
      c.QFSPedSubmissions.value;
      final isMassLoading = !c.QFSPedSubmissions.value.any((v) => c.isSelected[v.id]!) || c.QFSPedSubmissions.value.every((v) => c.loadingIndicator[v.id]!);
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
                  return c.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                    onRefresh: c.getAllSubmissions,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constrains.maxHeight,
                      ),
                      child: c.QFSPedSubmissions.value.isEmpty
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
                          width: constrains.maxWidth > 920 ? constrains.maxWidth : 920,
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
                                        value: c.QFSPedSubmissions.value.any((v) => c.isSelected[v.id]!) 
                                        ? c.QFSPedSubmissions.value.every((v) => c.isSelected[v.id]!) 
                                          ? true : null 
                                        : false,
                                        onChanged: c.selectPageItem,
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
                                    SizedBox(width: 12),
                                    SizedBox(
                                      width: 192,
                                      child: Text('Barang yang dipinjam', textScaleFactor: 1.2),
                                    ),
                                    SizedBox(width: 12),
                                    SizedBox(
                                      width: 152,
                                      child: Text('Tanggal Dibuat', textScaleFactor: 1.2),
                                    ),
                                    IconButton(
                                      onPressed: isMassLoading ? null : () => c.setSelectedStatus('borrowed'),
                                        icon: Icon(Icons.outbox_rounded, color: isMassLoading ? null : Colors.blue), tooltip: 'mark as borrowed'
                                    ),
                                    IconButton(
                                      onPressed: isMassLoading ? null : () => c.setSelectedStatus('returned'),
                                      icon: Icon(Icons.assignment_turned_in_rounded, color: isMassLoading ? null : Colors.green), tooltip: 'mark as returned'
                                    ),
                                    IconButton(
                                      onPressed: isMassLoading ? null : () => c.setSelectedStatus('overdue'),
                                      icon: Icon(Icons.running_with_errors_rounded, color: isMassLoading ? null : Colors.orange), tooltip: 'mark as overdue'
                                    ),
                                    IconButton(
                                      onPressed: isMassLoading ? null : () => c.setSelectedStatus('damaged'),
                                      icon: Icon(Icons.heart_broken_rounded, color: isMassLoading ? null : Colors.deepOrange), tooltip: 'mark as damaged'
                                    ),
                                    IconButton(
                                      onPressed: isMassLoading ? null : () => c.setSelectedStatus('lost'),
                                      icon: Icon(Icons.question_mark_rounded, color: isMassLoading ? null : Colors.purpleAccent), tooltip: 'mark as lost'
                                    ),
                                    IconButton(
                                      onPressed: isMassLoading ? null : () => c.setSelectedStatus('spam'),
                                      icon: Icon(Icons.report_rounded, color: isMassLoading ? null : Colors.red), tooltip: 'mark as spam'
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 0, color: appTheme.colorScheme.surface),
                              RefreshIndicator(
                                onRefresh: c.getAllSubmissions,
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    final entry = c.QFSPedSubmissions.value[i];
                                    final isLoading = c.loadingIndicator[entry.id] ?? true;
                                    final isBorrowed = isLoading || entry.status == 'borrowed';
                                    final isReturned = isLoading || entry.status == 'returned';
                                    final isOverdue = isLoading || entry.status == 'overdue';
                                    final isDamaged = isLoading || entry.status == 'damaged';
                                    final isLost = isLoading || entry.status == 'lost';
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
                                            Checkbox(value: c.isSelected[entry.id], onChanged: (v) => c.selectItem(entry.id, v!)),
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
                                      title: Text(entry.nama, overflow: TextOverflow.ellipsis,),
                                      subtitle: Text(entry.nim),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(width: 12),
                                          SizedBox(
                                            width: 192,
                                            child: Text(entry.banyakBarang().toFormatedString(), textScaleFactor: 1.2),
                                          ),
                                          SizedBox(width: 12),
                                          SizedBox(
                                            width: 152,
                                            child: Text(entry.createdAt.toDateTimeFormatedString(), textScaleFactor: 1.2),
                                          ),
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
                                    );
                                  },
                                  itemCount: c.QFSPedSubmissions.value.length,
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