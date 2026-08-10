import 'package:eform_ldte/misc/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/extension.dart';
import 'package:eform_ldte/misc/widget.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:go_router/go_router.dart';
import 'package:number_paginator/number_paginator.dart';

class ProgramStudi extends StatelessWidget {
  final String fakultas;
  const ProgramStudi({super.key, required this.fakultas});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProgramStudiController(fakultas));
    return Obx(() {
      c.QFSPedSubmissions.value;
      c.QFSPedSubmissions.value;
      final sub = c.QFSPedSubmissions.value;
      final isAnySelected = sub.any((v) => c.isSelected.contains(v.id));
      final isMassLoading = c.isMassLoading.value;
      final canSelect = c.canSelect.value;
      final canMassUpdate = isAnySelected && !isMassLoading;
      return Scaffold(
        appBar: AppBar(
          title: Text('$fakultas'),
          actions: [
            IconButton(onPressed: c.isLoading.value ? null : null, icon: Icon(Icons.refresh_rounded))
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
                      hintText: 'Search by Name'
                    ),
                    canError: false
                  ),
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
                          width: constrains.maxWidth > 920 ? constrains.maxWidth : 920,
                          height: constrains.maxHeight,
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.only(right: 12),
                                leading: Transform.translate(
                                  offset: Offset(8, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (canSelect) Checkbox(
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
                                title: Text('Nama'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (canSelect) IconButton(
                                      onPressed: !canMassUpdate ? null : c.deleteSelectedData,
                                      icon: Icon(Icons.delete_forever_rounded, color: !canMassUpdate ? null : Colors.red), tooltip: 'Delete Selected'
                                    ),
                                    IconButton(
                                      onPressed: isMassLoading ? null : () => c.canSelect.value = !canSelect,
                                      icon: Icon(
                                        canSelect ? Icons.edit_off_rounded : Icons.edit_rounded,
                                      ), tooltip: 'Edit'
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
                                    itemBuilder: (context, i) {
                                      final entry = c.QFSPedSubmissions.value[i];
                                      final isLoading = c.loadingIndicator.contains(entry.id);
                                      final canEdit = c.canEdit.contains(entry.id);
                                      return ListTile(
                                        contentPadding: EdgeInsets.only(right: 12),
                                        onLongPress: entry.name.isBlank() ? null : () {
                                          Clipboard.setData(
                                            ClipboardData(text: entry.name),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Name copied to clipboard!')),
                                          );
                                        },
                                        onTap: () => currentContext?.push('${NamedRoute.list}/$fakultas/${entry.name}'),
                                        leading: Transform.translate(
                                          offset: Offset(8, 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (canSelect) Checkbox(value: c.isSelected.contains(entry.id), onChanged: (v) => c.selectItem(entry.id, v!)),
                                              SizedBox(
                                                width: 40,
                                                child: Text(
                                                  '${entry.id}',
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
                                        title: Text(entry.name, overflow: TextOverflow.ellipsis),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (canEdit) IconButton(
                                              onPressed: isLoading ? null : () => c.deleteData(entry.id),
                                              icon: Icon(Icons.delete_forever_rounded, color: isLoading ? null : Colors.red), tooltip: 'Delete'
                                            ),
                                            IconButton(
                                              onPressed: isLoading ? null : () => c.canEditItem(entry.id),
                                              icon: Icon(
                                                canEdit ? Icons.edit_off_rounded : Icons.edit_rounded,
                                              ), tooltip: 'Delete'
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    itemCount: c.QFSPedSubmissions.value.length,
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