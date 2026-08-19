import 'package:eform_ldte/misc/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:go_router/go_router.dart';
import 'package:number_paginator/number_paginator.dart';

class ProgramStudi extends StatelessWidget {
  const ProgramStudi({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProgramStudiController>();
    return Obx(() {
      c.qfsped.value;
      return Scaffold(
        appBar: AppBar(
          title: Text(c.name),
          actions: [
            if (c.isSimAnyQueued) IconButton(onPressed: c.pushSimAction, icon: Icon(Icons.save_rounded), tooltip: 'Save ${c.name}'),
            if (c.isAnyQueued) TextButton(onPressed: c.config.saveQueuedAction, child: Text('Save All')),
          ],
        ),
        floatingActionButton: c.fakultas == null ? null : Padding(
          padding: const EdgeInsets.only(bottom: 52),
          child: FloatingActionButton(onPressed: c.inputDialog, child: Icon(Icons.add_rounded)),
        ),
        body: c.fakultas == null
        ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              Text("${c.name} didn't exist, please check the inputed url"),
              TextButton(onPressed: currentContext?.pop, child: Text('Go back'))
            ],
          ),
        )
        : Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: c.qfsp.queryController,
                    onChanged: (v) => c.qfsp.onChanged(),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: 'Search by Name'
                    ),
                    canError: false
                  ),
                  FilterRow(controller: c.qfsp, filterKey: 'action'),
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
                                    color: (c.areDeleting
                                      ? Colors.red 
                                      : c.areInserting
                                        ? Colors.green 
                                        : c.areUpdating
                                          ? Colors.amber  
                                          : c.areModifying
                                            ? Colors.blue
                                            : Colors.white).withAlpha(c.isPagedLoading ? 128 : 255), 
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
                                          value: c.isPagedLoading ? null : c.isPageSelected,
                                          onChanged: c.isPagedLoading ? null : c.selectPageItem,
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: Text('ID', textScaleFactor: 1.2, maxLines: 1, textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Text('Nama'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 12),
                                      SizedBox(
                                        width: 192,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: c.isPageAnyQueued ? c.pushPageAction : null, 
                                              icon: Icon(Icons.save_outlined), 
                                              tooltip: 'Save Page'
                                            ),
                                            IconButton(
                                              onPressed: c.isPageSelectedAnyQueued ? c.pushPageSelectedAction : null,
                                              icon: Icon(Icons.save_rounded),
                                              tooltip: 'Save Selected'
                                            ),
                                            if (c.canPagedSelectedUndoChange) IconButton(
                                              onPressed: c.undoChangePageSelectedData,
                                              icon: Icon(Icons.undo_outlined, color: Colors.amber),
                                              tooltip: 'Undo Selected Changes',
                                            ) else if (c.canPagedUndoChange) IconButton(
                                              onPressed: !c.canPagedUndoChange ? null : c.undoChangePageData,
                                              icon: Icon(Icons.undo_rounded, color: !c.canPagedUndoChange ? null : Colors.amber),
                                              tooltip: 'Undo Changes',
                                            ) else if (c.canPagedSelectedUndoDelete) IconButton(
                                              onPressed: c.undoDeletePageSelectedData,
                                              icon: Icon(Icons.restore_from_trash_rounded, color: Colors.red),
                                              tooltip: 'Undo Delete',
                                            ) else if (c.canPagedUndoDelete) IconButton(
                                              onPressed: c.undoDeletePageData, 
                                              icon: Icon(Icons.restore_from_trash_outlined, color: Colors.red),
                                            ) else IconButton(
                                              onPressed: !c.isPagedAnySelected ? null : c.deletePageSelectedData,
                                              icon: Icon(c.isPagedAnySelected ? Icons.delete_rounded : Icons.delete_forever_rounded, color: !c.isPagedAnySelected ? null : Colors.red),
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
                                    padding: EdgeInsets.only(bottom: 92),
                                    itemCount: c.qfsped.value.length,
                                    itemBuilder: (context, i) {
                                      final entry = c.qfsped.value[i];
                                      final isLoading = c.loadingQueue.contains(entry.id);
                                      final isAdding = c.insertQueue.contains(entry.id);
                                      final isModifying = entry.matprak.any((v) => c.config.matprakQueue.contains(v.id));
                                      final isUpdating = c.updateQueue.contains(entry.id);
                                      final isDeleting = c.deleteQueue.contains(entry.id);
                                      return Card(
                                        color: appTheme.appBarTheme.backgroundColor,
                                        margin: EdgeInsets.zero,
                                        shape: BorderDirectional(
                                          start: BorderSide(
                                            color: (isDeleting
                                              ? Colors.red 
                                              : isAdding
                                                ? Colors.green 
                                                : isUpdating
                                                  ? Colors.amber
                                                  : isModifying
                                                    ? Colors.blue
                                                    : Colors.white).withAlpha(isLoading ? 128 : 255), 
                                            width: 8
                                          ),
                                        ),
                                        child: ListTile(
                                        tileColor: isDeleting 
                                          ? appTheme.scaffoldBackgroundColor.withRed(isLoading ? 36 : 42) 
                                          : isAdding 
                                            ? appTheme.scaffoldBackgroundColor.withGreen(isLoading ? 36 : 42) 
                                            : isUpdating
                                              ? appTheme.scaffoldBackgroundColor.withRed(isLoading ? 36 : 42).withGreen(isLoading ? 36 : 42) 
                                              : isModifying
                                                ? appTheme.scaffoldBackgroundColor.withBlue(isLoading ? 36 : 42)
                                                : null,
                                          contentPadding: EdgeInsets.only(right: 12, left: 8),
                                          onTap: () => currentContext?.push('${NamedRoute.list}/${c.fakultas!.name}/${entry.name}'),
                                          leading: Transform.translate(
                                            offset: Offset(8, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Checkbox(
                                                  tristate: true,
                                                  value: isLoading ? null : c.isSelected.contains(entry.id), 
                                                  onChanged: isLoading ? null : (v) => c.selectItem(entry.id, v ?? false)
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
                                          title: Text(entry.name, overflow: TextOverflow.ellipsis),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(width: 12),
                                              SizedBox(
                                                width: 192,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        isLoading ? c.loadingQueue.remove(entry.id) : c.loadingQueue.add(entry.id);
                                                        c.qfsped.refresh();
                                                      },
                                                      icon: Icon(
                                                        isLoading ? Icons.remove : Icons.add,
                                                      ), tooltip: isLoading ? 'Testing...' : 'Test'
                                                    ),
                                                    if (isAdding || isUpdating || isDeleting || isModifying) IconButton(
                                                      onPressed: isLoading ? null : () => c.pushAction(entry),
                                                      icon: Icon(
                                                        Icons.save_rounded,
                                                      ), tooltip: isLoading ? 'Saving...' : 'Save'
                                                    ),
                                                    if (isUpdating) IconButton(
                                                      onPressed: isLoading ? null : () => c.undoChange({entry.id}),
                                                      icon: Icon(Icons.undo_rounded, color: isLoading ? null : Colors.amber),
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
                                                    IconButton(
                                                      onPressed: isDeleting || isLoading ? null : () => c.inputDialog(entry),
                                                      icon: Icon(Icons.edit_rounded),
                                                      tooltip: 'Edit',
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