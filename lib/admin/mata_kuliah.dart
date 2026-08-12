import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:number_paginator/number_paginator.dart';

class MataKuliahPraktikum extends StatelessWidget {
  const MataKuliahPraktikum({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MataKuliahPraktikumController>();
    return Obx(() {
      c.qfsped.value;
      final paged = c.qfsped.value;
      final selected = paged.where((v) => c.isSelected.contains(v.id));
      final isAnyQueued = c.config.isAnyQueued;
      final isAnyMatprakQueued = c.sim.any((v) => {...c.insertQueue, ...c.updateQueue, ...c.deleteQueue}.contains(v.id));
      final isAnySelected = paged.any((v) => c.isSelected.contains(v.id));
      final isPageAnyQueued = paged.any((v) => c.updateQueue.contains(v.id) || c.insertQueue.contains(v.id) || c.deleteQueue.contains(v.id));
      final isPageDeleting = !isAnySelected ? paged.every((v) => c.deleteQueue.contains(v.id)) : c.deleteQueue.isEmpty ? false : selected.every((v) => c.deleteQueue.contains(v.id));
      final isPageInserting = !isAnySelected ? paged.every((v) => c.insertQueue.contains(v.id)) : c.insertQueue.isEmpty ? false : selected.every((v) => c.insertQueue.contains(v.id));
      final isPageUpdating = !isAnySelected ? paged.every((v) => c.updateQueue.contains(v.id)) : c.updateQueue.isEmpty ? false : selected.every((v) => c.updateQueue.contains(v.id));
      final canQueue = c.loadingIndicator.isEmpty;
      final canPageUpdate = canQueue && isAnySelected;
      final canSelectedUndoDelete = canQueue && selected.every((v) => c.deleteQueue.contains(v.id));
      return Scaffold(
        appBar: AppBar(
          title: Text(c.programStudi),
          actions: [
            // if (isAnyQueued) IconButton(onPressed: !canQueue ? null : c.pushQueuedAction, icon: Icon(Icons.save_rounded), tooltip: 'Save All',),
            if (isAnyMatprakQueued) IconButton(onPressed: !canQueue ? null : c.pushQueuedAction, icon: Icon(Icons.save_rounded), tooltip: 'Save All',),
            if (isAnyMatprakQueued) IconButton(onPressed: !canQueue ? null : c.pushQueuedAction, icon: Icon(Icons.save_rounded), tooltip: 'Save All',),
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
                      child: c.qfsped.value.isEmpty
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
                              Card(
                                color: Colors.transparent,
                                margin: EdgeInsets.zero,
                                shape: BorderDirectional(
                                  start: BorderSide(
                                    color: isPageDeleting
                                    ? Colors.red 
                                    : isPageInserting
                                      ? Colors.green 
                                      : isPageUpdating
                                        ? Colors.yellow  
                                        : Colors.white, 
                                    width: 8
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(right: 12, left: 8),
                                  leading: Transform.translate(
                                    offset: Offset(8, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          tristate: true,
                                          value: paged.any((v) => c.isSelected.contains(v.id)) 
                                          ? paged.every((v) => c.isSelected.contains(v.id)) 
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
                                  title: Text('Kode - Nama'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 12),
                                      SizedBox(
                                        width: 128,
                                        child: Text('Type', textScaleFactor: 1.2),
                                      ),
                                      SizedBox(
                                        width: 96,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            if (isPageAnyQueued) IconButton(onPressed: !canQueue ? null : c.pushPageAction, icon: Icon(Icons.save_rounded), tooltip: 'Save Page',),
                                            if (canPageUpdate && canSelectedUndoDelete) IconButton(
                                              onPressed: !canSelectedUndoDelete ? null : c.undoDeletePageSelectedData,
                                              icon: Icon(Icons.restore_from_trash_rounded, color: Colors.red),
                                              tooltip: 'Undo Delete',
                                            ) else IconButton(
                                              onPressed: !canPageUpdate ? null : c.deletePageSelectedData,
                                              icon: Icon(isAnySelected ? Icons.delete_rounded : Icons.delete_forever_rounded, color: !canPageUpdate ? null : Colors.red),
                                              tooltip: 'Delete Selected'
                                            ),
                                          ]
                                        )
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Divider(height: 0, color: appTheme.colorScheme.surface),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async {},
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: c.qfsped.value.length,
                                    itemBuilder: (context, i) {
                                      final entry = c.qfsped.value[i];
                                      final isLoading = c.loadingIndicator.contains(entry.id);
                                      final isPraktikum = entry.isPraktikum;
                                      final isAdding = c.insertQueue.contains(entry.id);
                                      final isUpdating = c.updateQueue.contains(entry.id);
                                      final isDeleting = c.deleteQueue.contains(entry.id);
                                      return Card(
                                        color: appTheme.appBarTheme.backgroundColor,
                                        margin: EdgeInsets.zero,
                                        shape: BorderDirectional(
                                          start: BorderSide(
                                            color: isDeleting
                                            ? Colors.red 
                                            : isAdding
                                              ? Colors.green 
                                              : isUpdating
                                                ? Colors.yellow  
                                                : Colors.white, 
                                            width: 8
                                          ),
                                        ),
                                        child: ListTile(
                                        tileColor: isDeleting 
                                          ? appTheme.scaffoldBackgroundColor.withRed(36) 
                                          : isAdding 
                                            ? appTheme.scaffoldBackgroundColor.withGreen(36) 
                                            : isUpdating 
                                              ? appTheme.scaffoldBackgroundColor.withRed(36).withGreen(36) 
                                              : null,
                                          contentPadding: EdgeInsets.only(right: 12, left: 8),
                                          onTap: isDeleting || isLoading ? null : () => c.inputDialog(entry),
                                          leading: Transform.translate(
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
                                                      fontSize: 12.8,
                                                    ),
                                                    maxLines: 1, 
                                                    textAlign: TextAlign.center
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          title: Text('${entry.kode} - ${entry.nama}', overflow: TextOverflow.ellipsis),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(width: 12),
                                              SizedBox(
                                                width: 128,
                                                child: Text(entry.type, textScaleFactor: 1.2),
                                              ),
                                              SizedBox(
                                                width: 96,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
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
                                                    ) else if (isDeleting) IconButton(
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
                                              )
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