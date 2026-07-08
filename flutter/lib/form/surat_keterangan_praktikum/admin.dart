import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/core/custom-widget.dart';
import 'package:ldte_stei_itb/misc/function.dart';
import 'package:number_paginator/number_paginator.dart';

class AdminSuratKeteranganPraktikum extends StatelessWidget {
  const AdminSuratKeteranganPraktikum({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AdminSuratKeteranganPraktikumController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
        leading: canPop
          ? null : IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Get.offNamed('/admin'),
          ),
      ),
      body: Obx(() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                AutoHideTextField(
                  controller: c.qfsp.queryController,
                  onChanged: (v) => c.qfsp.onChanged(),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'Search Name'
                  ),
                  canError: false
                ),
                Column(
                  spacing: kIsWeb ? 8 : 0,
                  children: [
                    FilterRow(controller: c.qfsp, filterKey: 'status'),
                  ],
                ),
                SortRow(controller: c.qfsp),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: AutoHideTextField(
                        controller: c.startDateC,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          hintText: 'yyyy/mm/dd',
                          suffixIcon: IconButton(onPressed: () => c.selectDateStart(context), icon: Icon(Icons.date_range))
                        ),
                        onChanged: (v) {
                          if (v.length > 10) c.startDateC.text = v.substring(0, 10);
                        },
                      ),
                    ),
                    Text('-', textScaleFactor: 1.6),
                    Expanded(
                      child: AutoHideTextField(
                        controller: c.endDateC,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          hintText: 'yyyy/mm/dd',
                          suffixIcon: IconButton(onPressed: () => c.selectDateEnd(context), icon: Icon(Icons.date_range))
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
            child: c.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
              onRefresh: c.getAllSubmissions,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: Get.height / 2.4,
                ),
                child: c.QFSPedSubmissions.value.isEmpty
                ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: Get.height / 2.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('- no data to display -', textScaleFactor: 1.2,),
                        Text('please use a different filters or scroll down to refresh'),
                      ],
                    ),
                  )
                ) : ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    final entry = c.QFSPedSubmissions.value[i];
                    return ListTile(
                      // onLongPress: entry.nama.isBlank() ? null : () {
                      //   Clipboard.setData(
                      //     ClipboardData(text: entry.phone!),
                      //   );
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(content: Text('Phone number copied to clipboard!')),
                      //   );
                      // },
                      onTap: () => c.preview(entry),
                      leading: Text(
                        entry.id.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: getColorFromSubmissionStatus(entry.status)
                        ),
                      ),
                      title: Text('${entry.nama.first}'),
                      subtitle: Text('${entry.createdAt}'),
                    );
                  },
                  itemCount: c.QFSPedSubmissions.value.length,
                ),
              ),
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
      ),
    );
  }
}