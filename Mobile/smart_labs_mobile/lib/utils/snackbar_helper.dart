import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

void showTopSnackBar({
  required BuildContext context,
  required String title,
  required String message,
  ContentType contentType = ContentType.success,
}) {
  OverlayEntry? overlayEntry;
  bool isRemoved = false;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: AnimationController(
                vsync: Navigator.of(context),
                duration: const Duration(milliseconds: 300),
              )..forward(),
              curve: Curves.easeOut,
            )),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: contentType == ContentType.success
                      ? Colors.green
                      : contentType == ContentType.warning
                          ? Colors.orange
                          : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        if (!isRemoved) {
                          isRemoved = true;
                          overlayEntry?.remove();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    if (!isRemoved) {
      isRemoved = true;
      overlayEntry?.remove();
    }
  });
}
