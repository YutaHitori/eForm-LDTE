import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:eform_ldte/core/service.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';

class Assets {
  static const String logo = 'assets/logo.png';
}

ThemeData appTheme = ThemeData(
  visualDensity: VisualDensity.standard,

  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),

  // Color Scheme (Flutter 3+ standard)
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF0D6EFD),
    secondary: Color(0xFFFD9A30),
    tertiary: Color(0xFFA4C639),
    surface: Color(0xFF252525),
    background: Color(0xFF121212),
    error: Color(0xFFCF6679),

    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Color(0xFFF5F5F5),
    onBackground: Color(0xFFF5F5F5),
    onError: Colors.black,
  ),

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFFF5F5F5)),
    titleTextStyle: TextStyle(
      color: Color(0xFFF5F5F5),
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  // Cards
  cardColor: const Color(0xFF252525),
  cardTheme: const CardThemeData(
    color: Color(0xFF252525),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  // Text
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFF5F5F5)),
    bodyMedium: TextStyle(color: Color(0xFFD8D8D8)),
    titleLarge: TextStyle(
      color: Color(0xFFF5F5F5),
      fontWeight: FontWeight.bold,
    ),
  ),

  // Icons
  iconTheme: const IconThemeData(
    color: Color(0xFFB0B0B0),
  ),

  // Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0D6EFD),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFFFFA94D),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  // Input fields
  inputDecorationTheme: InputDecorationTheme(
    fillColor: const Color(0xFF202020),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFCF6679)),
    ),
    hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
    helperStyle: const TextStyle(height: 0, fontSize: 0),
    errorStyle: const TextStyle(height: 0, fontSize: 0),
  ),

  // Bottom Navigation
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: Color(0xFFFFA94D),
    unselectedItemColor: Color(0xFFB0B0B0),
    type: BottomNavigationBarType.fixed,
  ),

  // Divider
  dividerColor: const Color(0xFF2C2C2C),
);

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.labelText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.maxLines = 1,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.obscureText,
    this.canError = true,
    this.onChanged,
    this.enabled = true,
    this.onSubmitted,
    this.autofillHints = const <String>[],
    this.inputFormatters,
    this.labelFlexAxis = Axis.horizontal,
  });

  final String? labelText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLines;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final bool canError;
  final bool enabled;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final Axis labelFlexAxis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (labelText != null) Flex(
          direction: labelFlexAxis,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(labelText!, textScaleFactor: 1.02, overflow: TextOverflow.ellipsis),
            if (errorText != null) Text(
              errorText!,
              style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0),
            ),
          ]
        ),
        TextField(
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          inputFormatters: inputFormatters,
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          decoration: decoration.copyWith(
            filled: true,
            helperText: canError ? '' : null,
            errorText: errorText == null ? null : ''
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
          obscureText: obscureText ?? false,
          onSubmitted: onSubmitted,
          autofillHints: autofillHints,
        ),
      ],
    );
  }
}

class FilterRow extends StatelessWidget {
  const FilterRow({
    super.key,
    required this.controller,
    required this.filterKey,
  });

  final QFSPController controller;
  final String filterKey;

  @override
  Widget build(BuildContext context) {
    final map = controller.getFilterEnrty(filterKey).value;
    return Row(
      spacing: 6,
        children: [
          TextButton(
            onPressed: () => controller.onChanged('all', filterKey),
            child: Text('all'),
            style: TextButton.styleFrom(
              minimumSize: Size(56, 32),
              backgroundColor: map['all']!
                ? appTheme.colorScheme.primary : null,
              foregroundColor: map['all']!
                ? Colors.white : null,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 6,
                children: [
                  for (var item in map.entries) ...[
                    if (item.key != 'all') TextButton(
                      onPressed: () => controller.onChanged(item.key, filterKey),
                      child: Text(item.key),
                      style: TextButton.styleFrom(
                        minimumSize: Size(56, 32),
                        backgroundColor: item.value
                          ? getColorFromSubmissionStatus(item.key) 
                            ?? appTheme.colorScheme.primary
                          : null,
                        foregroundColor: item.value
                          ? Colors.white 
                          : getColorFromSubmissionStatus(item.key)
                      ),
                    ),
                  ]
                ],
              ),
            ),
          )
        ]
      );
  }
}

class SortRow extends StatelessWidget {
  const SortRow({
    super.key,
    required this.controller,
  });

  final QFSPController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Sort by :  '),
        Expanded(
          child: DropdownFlutter(
            closedHeaderPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            listItemBuilder: (context, item, isSelected, onItemSelect) => Text('${item}', style: TextStyle(color: isSelected ? Colors.black : null),),
            decoration: CustomDropdownDecoration(
              expandedFillColor: appTheme.inputDecorationTheme.fillColor,
              closedFillColor: appTheme.inputDecorationTheme.fillColor,
              listItemStyle: TextStyle(color: ThemeData.dark().primaryColor),
            ),
            excludeSelected: false,
            items: ['Latest', 'Oldest', 'Name (A-Z)', 'Name (Z-A)'],
            controller: controller.sortController,
            onChanged: (value) => controller.onChanged(),
          ),
        ),
      ],
    );
  }
}

  Widget SideMenuNavigation(BuildContext context, String active) {
    return Container(
      color: appTheme.canvasColor,
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      width: Get.width * 0.3,
      constraints: BoxConstraints(maxWidth: 300, minWidth: 250),
      child: SideMenu(
        hasResizer: false,
        hasResizerToggle: false,
        mode: SideMenuMode.open,
        builder: (data) => SideMenuData(
          header: Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('eForm LDTE', textScaleFactor: 1.42,),
                Text(auth.isLoggedIn ? 'Logged in as ${auth.user?.email}' : 'User not logged in', textScaleFactor: 0.92)
              ],
            ),
          ),
          items: [
            SideMenuItemDataTitle(title: 'Page Navigation'),
            SideMenuItemDataTile(
              borderRadius: BorderRadius.circular(12),
              isSelected: active == '/',
              onTap: active == '/' ? () {} : () => NC.navigateToPage('/', context),
              title: 'Homepage',
              icon: const Icon(Icons.home_rounded),
            ),
            SideMenuItemDataTile(
              borderRadius: BorderRadius.circular(12),
              isSelected: active == '/admin' || active == '/login',
              onTap: active == '/admin' || active == '/login' ? () {} : () => NC.navigateToPage(auth.isLoggedIn ? '/admin' : '/login', context),
              title: auth.isLoggedIn ? 'Admin Panel' : 'Login',
              icon: Icon(auth.isLoggedIn ? Icons.person_rounded : Icons.login_rounded),
            ),
          ],
          footer: Container(
            padding: EdgeInsets.only(top: 12),
            child: Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Last Sync'),
                Text('${NC.lastSync.value}', textScaleFactor: 0.72,),
                SizedBox(height: 8),
                Text('App version 0.4.3 build 27', textScaleFactor: 0.92),
              ],
            ),
          )),
        ),
      ),
    );
  }