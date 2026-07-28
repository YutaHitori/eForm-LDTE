import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:ldte_stei_itb/misc/function.dart';
import 'package:ldte_stei_itb/misc/widget.dart';
import 'package:ldte_stei_itb/misc/global.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Obx(() => Row(
        children: [
          if (constraints.constrainWidth() > (800)) Material(child: SideMenuNavigation(context, NC.currentPage.value!)),
          Expanded(
            child: Scaffold(appBar: AppBar(title: Text(NC.title[NC.currentPage.value]!)),
                drawer: constraints.constrainWidth() > (800) ? null : SideMenuNavigation(context, NC.currentPage.value!),
              body: RefreshIndicator(
                  onRefresh: hardRefresh,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(height: constraints.maxHeight - 56, child: NC.pages[NC.currentPage.value]),
                  ),
                ),
              )
          ),
        ],
      )
    ));
  }
}