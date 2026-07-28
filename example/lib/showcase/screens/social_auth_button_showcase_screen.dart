import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SocialAuthButtonShowcaseScreen extends StatelessWidget {
  const SocialAuthButtonShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'SocialAuthButton',
      variants: [
        UsageVariant(
          title: 'Default',
          builder: (context) => const Column(
            spacing: 12,
            children: [
              BCSocialAuthButton(provider: BCSocialProvider.google),
              BCSocialAuthButton(provider: BCSocialProvider.apple),
              BCSocialAuthButton(provider: BCSocialProvider.github),
              BCSocialAuthButton(provider: BCSocialProvider.facebook),
            ],
          ),
        ),
        UsageVariant(
          title: 'Variants',
          builder: (context) => const Column(
            spacing: 12,
            children: [
              BCSocialAuthButton(
                provider: BCSocialProvider.microsoft,
                variant: BCButtonVariant.primary,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.notion,
                variant: BCButtonVariant.secondary,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.apple,
                variant: BCButtonVariant.tertiary,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.slack,
                variant: BCButtonVariant.outline,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.linear,
                variant: BCButtonVariant.ghost,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Sizes',
          builder: (context) => const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              _Labelled(
                'Small',
                child: BCSocialAuthButton(
                  provider: BCSocialProvider.google,
                  size: BCButtonSize.sm,
                ),
              ),
              _Labelled(
                'Medium (default)',
                child: BCSocialAuthButton(provider: BCSocialProvider.google),
              ),
              _Labelled(
                'Large',
                child: BCSocialAuthButton(
                  provider: BCSocialProvider.google,
                  size: BCButtonSize.lg,
                ),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Labels',
          builder: (context) => const Column(
            spacing: 12,
            children: [
              BCSocialAuthButton(
                provider: BCSocialProvider.apple,
                label: 'Continue with Apple',
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.google,
                label: 'Sign in with Google',
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.discord,
                label: 'Join with Discord',
                endContent: Icon(Icons.arrow_forward, size: 18),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Icon only',
          builder: (context) => const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              BCSocialAuthButton(
                provider: BCSocialProvider.google,
                isIconOnly: true,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.apple,
                isIconOnly: true,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.github,
                isIconOnly: true,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.x,
                isIconOnly: true,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.slack,
                isIconOnly: true,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Logo style',
          builder: (context) => const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              _Labelled(
                'auto — brand colors, tinted variants go monochrome',
                child: BCSocialAuthButton(provider: BCSocialProvider.facebook),
              ),
              _Labelled(
                'brand',
                child: BCSocialAuthButton(
                  provider: BCSocialProvider.facebook,
                  variant: BCButtonVariant.primary,
                  logoStyle: BCBrandLogoStyle.brand,
                ),
              ),
              _Labelled(
                'monochrome',
                child: BCSocialAuthButton(
                  provider: BCSocialProvider.facebook,
                  logoStyle: BCBrandLogoStyle.monochrome,
                ),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Loading & disabled',
          builder: (context) => const Column(
            spacing: 12,
            children: [
              BCSocialAuthButton(
                provider: BCSocialProvider.google,
                isLoading: true,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.microsoft,
                variant: BCButtonVariant.primary,
                isLoading: true,
              ),
              BCSocialAuthButton(
                provider: BCSocialProvider.github,
                isDisabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Caption above a demo row.
class _Labelled extends StatelessWidget {
  const _Labelled(this.label, {required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          label,
          style: BCTypography.textSm.copyWith(color: context.bcTheme.muted),
        ),
        child,
      ],
    );
  }
}
