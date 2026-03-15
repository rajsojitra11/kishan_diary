import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/localization.dart';

PreferredSizeWidget buildKishanAppBar({
  required BuildContext context,
  required AppLanguage language,
  String? title,
  bool showMenu = false,
  VoidCallback? onDownload,
}) {
  final appBarTitle = title ?? t(language, 'appTitle');

  return AppBar(
    toolbarHeight: 86,
    backgroundColor: const Color(0xFF2E7D32),
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    automaticallyImplyLeading: false,
    leadingWidth: showMenu ? 56 : null,
    leading: showMenu
        ? Builder(
            builder: (leadingContext) {
              return IconButton(
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                icon: const Icon(Icons.menu, size: 30),
                onPressed: () {
                  Scaffold.maybeOf(leadingContext)?.openDrawer();
                },
              );
            },
          )
        : null,
    title: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: Color(0xFFF1F8E9),
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            appBarTitle,
            style: const TextStyle(
              color: Color(0xFFF1F8E9),
              fontWeight: FontWeight.w700,
              fontSize: 38,
            ),
          ),
        ],
      ),
    ),
    actions: [
      if (onDownload != null)
        IconButton(
          tooltip: t(language, 'downloadPdfTooltip'),
          icon: const Icon(Icons.download, size: 28),
          onPressed: onDownload,
        ),
      IconButton(
        tooltip: t(language, 'shareAppTooltip'),
        icon: const Icon(Icons.share, size: 28),
        onPressed: () async {
          await Share.share(t(language, 'shareAppText'));
        },
      ),
      const SizedBox(width: 4),
    ],
  );
}
