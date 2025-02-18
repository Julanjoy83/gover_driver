import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String messageText;
  final Color progressColor;
  final Color backgroundColor;
  final double borderRadius;
  final TextStyle? textStyle;

  const LoadingDialog({
    super.key,
    required this.messageText,
    this.progressColor = Colors.green,
    this.backgroundColor = Colors.white,
    this.borderRadius = 12.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      backgroundColor: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(width: 16.0),
              Flexible(
                child: Text(
                  messageText,
                  style: textStyle ?? Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}