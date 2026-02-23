import 'package:flutter/material.dart';
import 'package:fitmetrics_app/constants/colors.dart'; // adjust import if needed

class GenderRadioGroup extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onChanged;

  const GenderRadioGroup({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Male'),
            value: 'Male',
            groupValue: selectedGender,
            onChanged: onChanged,
            activeColor: AppColors.primary, // or Color(0xFF3B82F6)
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Female'),
            value: 'Female',
            groupValue: selectedGender,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }
}