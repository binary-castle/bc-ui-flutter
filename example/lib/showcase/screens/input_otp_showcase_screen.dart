import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class InputOtpShowcaseScreen extends StatelessWidget {
  const InputOtpShowcaseScreen({super.key});

  Widget _otp({
    BCInputOTPVariant variant = BCInputOTPVariant.primary,
    bool isInvalid = false,
    bool withSeparator = false,
  }) {
    return BCInputOTP(
      maxLength: 6,
      variant: variant,
      isInvalid: isInvalid,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BCInputOTPGroup(
            children: [
              BCInputOTPSlot(index: 0),
              BCInputOTPSlot(index: 1),
              BCInputOTPSlot(index: 2),
            ],
          ),
          if (withSeparator) const BCInputOTPSeparator(),
          if (!withSeparator) const SizedBox(width: 8),
          const BCInputOTPGroup(
            children: [
              BCInputOTPSlot(index: 3),
              BCInputOTPSlot(index: 4),
              BCInputOTPSlot(index: 5),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'InputOTP',
      variants: [
        UsageVariant(title: 'Default', builder: (context) => _otp()),
        UsageVariant(
          title: 'With separator',
          builder: (context) => _otp(withSeparator: true),
        ),
        UsageVariant(
          title: 'Secondary',
          builder: (context) =>
              _otp(variant: BCInputOTPVariant.secondary),
        ),
        UsageVariant(
          title: 'Invalid',
          builder: (context) => _otp(isInvalid: true),
        ),
      ],
    );
  }
}
