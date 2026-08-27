import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/core/service.dart';
import 'package:eform_ldte/misc/function.dart';
import 'package:eform_ldte/misc/global.dart';

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
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: const Color(0xFF0D6EFD),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: const Color(0xFFFFA94D),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    this.decoration,
    this.keyboardType,
    this.obscureText,
    this.canError = true,
    this.onChanged,
    this.enabled,
    this.readOnly = false,
    this.scrollbar = true,
    this.onSubmitted,
    this.autofillHints = const <String>[],
    this.inputFormatters,
    this.labelFlexAxis = Axis.horizontal,
    this.maxHeight = double.infinity,
  });

  final String? labelText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLines;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final bool canError;
  final bool? enabled;
  final bool readOnly;
  final bool scrollbar;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final Axis labelFlexAxis;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final child = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: TextField(
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        inputFormatters: inputFormatters,
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        decoration: (decoration ?? InputDecoration()).copyWith(
          filled: true,
          helperText: canError ? '' : null,
          errorText: errorText == null ? null : ''
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        obscureText: obscureText ?? false,
        onSubmitted: onSubmitted,
        autofillHints: autofillHints,
        enabled: enabled,
        readOnly: readOnly,
        scrollPhysics: readOnly && maxLines != 1 ? NeverScrollableScrollPhysics() : null,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          if (labelText != null) Flex(
            direction: labelFlexAxis,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (labelFlexAxis == Axis.horizontal) Expanded(child: Text(labelText!, textScaleFactor: 1.02, overflow: TextOverflow.ellipsis))
              else Text(labelText!, textScaleFactor: 1.02, overflow: TextOverflow.ellipsis),
              if (errorText != null) ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth - 24),
                child: Text(
                  errorText!.replaceAll('\n', ''),
                  style: TextStyle(color: ColorScheme.dark().error, fontSize: 12.0),
                ),
              ),
            ]
          ),
          maxLines != 1 && !scrollbar ? ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: child
          ) : child,
        ],
      ),
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
            style: TextButton.styleFrom(
              minimumSize: Size(56, 32),
              backgroundColor: map['all']!
                ? appTheme.colorScheme.primary : null,
              foregroundColor: map['all']!
                ? Colors.white : null,
            ),
            child: Text('all'),
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
                      child: Text(item.key),
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
                Text('eFrom LDTE', textScaleFactor: 1.42, textAlign: TextAlign.center,),
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
                Text('${NC.buildVersion.value}', textScaleFactor: 0.92),
              ],
            ),
          )),
        ),
      ),
    );
  }

class GetXRouteBinding<T extends GetxController> extends StatefulWidget {
  final T Function() controllerBuilder;
  final void Function()? initCallback;
  final Widget child;

  const GetXRouteBinding({
    super.key, 
    required this.controllerBuilder, 
    required this.child,
    this.initCallback
  });

  @override
  State<GetXRouteBinding<T>> createState() => _GetXRouteBindingState<T>();
}

class _GetXRouteBindingState<T extends GetxController> extends State<GetXRouteBinding<T>> {
  @override
  void initState() {
    super.initState();
    widget.controllerBuilder();
    widget.initCallback?.call();
  }

  @override
  void dispose() {
    Get.delete<T>();
    super.dispose();
  }

  @override
  void readyState() {

  }

  @override
  Widget build(BuildContext context) => widget.child;
}