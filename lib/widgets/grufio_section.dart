import 'package:flutter/material.dart';

class GrufioSection extends StatelessWidget {
  const GrufioSection({
    super.key,
    this.title,
    required this.child,
    this.padding,
  });
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
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
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );
  }
}
