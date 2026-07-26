import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class TextFieldShowcaseScreen extends StatelessWidget {
  const TextFieldShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'TextField',
      variants: [
        UsageVariant(
          title: 'Anatomy',
          builder: (context) => const BCTextField(
            isRequired: true,
            children: [
              BCTextFieldLabel('Email'),
              BCTextFieldInput(hintText: 'you@example.com'),
              BCTextFieldDescription("We'll never share your email."),
            ],
          ),
        ),
        UsageVariant(
          title: 'Variants',
          builder: (context) => const Column(
            spacing: 24,
            children: [
              BCTextField(
                children: [
                  BCTextFieldLabel('Primary'),
                  BCTextFieldInput(hintText: 'Field background + shadow'),
                ],
              ),
              BCTextField(
                children: [
                  BCTextFieldLabel('Secondary'),
                  BCTextFieldInput(
                    variant: BCInputVariant.secondary,
                    hintText: 'Default background',
                  ),
                ],
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Invalid',
          builder: (context) => const BCTextField(
            isInvalid: true,
            children: [
              BCTextFieldLabel('Username'),
              BCTextFieldInput(hintText: 'Enter username'),
              BCTextFieldError('This username is already taken.'),
            ],
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const BCTextField(
            isDisabled: true,
            children: [
              BCTextFieldLabel('Disabled'),
              BCTextFieldInput(hintText: 'Cannot edit'),
              BCTextFieldDescription('This field is disabled.'),
            ],
          ),
        ),
      ],
    );
  }
}
