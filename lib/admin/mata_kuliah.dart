import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:number_paginator/number_paginator.dart';

class MataKuliahPraktikum extends StatelessWidget {
  final String programStudi;
  const MataKuliahPraktikum({super.key, required this.programStudi});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MataKuliahPraktikumController(programStudi));
    return Obx(() {
      c.QFSPedSubmissions.value;
      final sub = c.QFSPedSubmissions.value;
      final isAnyQueued = c.submissions.any((v) => c.updateForms.contains(v.id) || c.insertForms.contains(v.id) || c.deleteForms.contains(v.id));
      final isAnySelected = sub.any((v) => c.isSelected.contains(v.id));
      final canQueue = c.loadingIndicator.isEmpty;
      final canPageUpdate = canQueue && isAnySelected;
      final canSelectedUndoDelete = canQueue && c.isSelected.where(((v) => sub.any((a) => a.id == v))).every((v) => c.deleteForms.contains(v));
      return Scaffold(
        appBar: AppBar(
          title: Text(programStudi),
          actions: [
            if (isAnyQueued) IconButton(onPressed: !canQueue ? null : c.pushQueuedAction, icon: Icon(Icons.save_rounded)),
            IconButton(onPressed: c.isLoading.value ? null : null, icon: Icon(Icons.refresh_rounded)),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 52.0),
          child: FloatingActionButton(onPressed: !canQueue ? null : c.inputDialog, child: Icon(Icons.add_rounded),),
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
                      hintText: 'Search by Name or Code'
                    ),
                    canError: false
                  ),
                  FilterRow(controller: c.qfsp, filterKey: 'type'),
                  SortRow(controller: c.qfsp),
                ],
              ),
            ),
            Divider(height: 0, color: appTheme.colorScheme.surface),
            Expanded(
              child: c.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                builder: (context, constrains) {
                  return RefreshIndicator(
                    onRefresh: () async {},
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
                          width: constrains.maxWidth > 800 ? constrains.maxWidth : 800,
                          height: constrains.maxHeight,
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.only(right: 12),
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    VerticalDivider(
                                      width: 5,
                                      thickness: 2,
                                    ),
                                    Transform.translate(
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
                                            onChanged: c.selectPageItem,
                                          ),
                                          SizedBox(
                                            width: 40,
                                            child: Text('ID', textScaleFactor: 1.2, maxLines: 1, textAlign: TextAlign.center),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text('Kode - Nama'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (canPageUpdate && canSelectedUndoDelete) IconButton(
                                      onPressed: !canSelectedUndoDelete ? null : c.undoDeleteSelectedData,
                                      icon: Icon(Icons.restore_from_trash_rounded, color: Colors.red),
                                      tooltip: 'Undo Delete',
                                    ) else IconButton(
                                      onPressed: !canPageUpdate ? null : c.deleteSelectedData,
                                      icon: Icon(isAnySelected ? Icons.delete_rounded : Icons.delete_forever_rounded, color: !canPageUpdate ? null : Colors.red),
                                      tooltip: 'Delete Selected'
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 0, color: appTheme.colorScheme.surface),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async {},
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: c.QFSPedSubmissions.value.length,
                                    itemBuilder: (context, i) {
                                      final entry = c.QFSPedSubmissions.value[i];
                                      final isLoading = c.loadingIndicator.contains(entry.id);
                                      final isPraktikum = entry.isPraktikum;
                                      final isAdding = c.insertForms.contains(entry.id);
                                      final isUpdating = c.updateForms.contains(entry.id);
                                      final isDeleting = c.deleteForms.contains(entry.id);
                                      return Container(
                                        color: isDeleting 
                                          ? appTheme.scaffoldBackgroundColor.withRed(36) 
                                          : isAdding 
                                            ? appTheme.scaffoldBackgroundColor.withGreen(36) 
                                            : isUpdating 
                                              ? appTheme.scaffoldBackgroundColor.withRed(36).withGreen(36) 
                                              : null,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.only(right: 12),
                                          // onLongPress: entry.nama.isBlank() ? null : () {
                                          //   Clipboard.setData(
                                          //     ClipboardData(text: '${entry.kode} ${entry.nama}'),
                                          //   );
                                          //   ScaffoldMessenger.of(context).showSnackBar(
                                          //     SnackBar(content: Text('Code and Name copied to clipboard!')),
                                          //   );
                                          // },
                                          onTap: isDeleting || isLoading ? null : () => c.inputDialog(entry),
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              VerticalDivider(
                                                color: isDeleting
                                                  ? Colors.red 
                                                  : isAdding
                                                    ? Colors.green 
                                                    : isUpdating
                                                      ? Colors.yellow  
                                                      : Colors.white,
                                                width: 5,
                                                thickness: 2,
                                              ),
                                              Transform.translate(
                                                offset: Offset(8, 0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Checkbox(
                                                      value: c.isSelected.contains(entry.id), 
                                                      onChanged: (v) => c.selectItem(entry.id, v!)
                                                    ),
                                                    SizedBox(
                                                      width: 40,
                                                      child: Text(
                                                        '${entry.id.isNegative ? 'new' : entry.id}',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                        maxLines: 1, 
                                                        textAlign: TextAlign.center
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          title: Text('${entry.kode} - ${entry.nama}', overflow: TextOverflow.ellipsis),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isAdding || isUpdating || isDeleting) IconButton(
                                                onPressed: isLoading ? null : () => c.pushAction(entry.id),
                                                icon: Icon(
                                                  Icons.save_rounded,
                                                ), tooltip: 'Save'
                                              ),
                                              if (isUpdating) IconButton(
                                                onPressed: isLoading ? null : () => c.undoChange(entry.id),
                                                icon: Icon(Icons.restore_outlined, color: isLoading ? null : Colors.yellow),
                                                tooltip: 'Undo Changes',
                                              ),
                                              if (isDeleting) IconButton(
                                                onPressed: isLoading ? null : () => c.undoDelete(entry.id),
                                                icon: Icon(Icons.restore_from_trash_rounded, color: isLoading ? null : Colors.red),
                                                tooltip: 'Undo Delete',
                                              ) else IconButton(
                                                onPressed: isLoading ? null : () => c.delete(entry.id),
                                                icon: Icon(Icons.delete_rounded, color: isLoading ? null : Colors.red),
                                                tooltip: 'Delete',
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
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