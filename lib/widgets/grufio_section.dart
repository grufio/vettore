import 'package:flutter/material.dart';

class GrufioSection extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GrufioSection({
    super.key,
    this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFDCDCDC),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );
  }
}
