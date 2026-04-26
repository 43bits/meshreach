import 'package:flutter/material.dart';
import 'package:meshreach/theme.dart';

class SOSButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SOSButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: MeshColors.sosButton,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'SOS',
            style: dmMonoStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
