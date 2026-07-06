import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:flutter/material.dart';

class InputShowcaseScreen extends StatelessWidget {
  const InputShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inputs')),
      body: ListView(
        padding: const EdgeInsets.all(ShowcaseSpacing.lg),
        children: const [
          ShowcaseSectionTitle('Variants'),
          BCTextField(
            children: [
              BCTextFieldLabel('Primary'),
              BCTextFieldInput(
                hintText: 'Enter text',
                variant: BCTextFieldVariant.primary,
              ),
            ],
          ),
          SizedBox(height: ShowcaseSpacing.md),
          BCTextField(
            children: [
              BCTextFieldLabel('Secondary'),
              BCTextFieldInput(
                hintText: 'Enter text',
                variant: BCTextFieldVariant.secondary,
              ),
            ],
          ),
          SizedBox(height: ShowcaseSpacing.xl),
          ShowcaseSectionTitle('With Label + Description'),
          BCTextField(
            children: [
              BCTextFieldLabel('Email'),
              BCTextFieldInput(hintText: 'you@example.com'),
              BCTextFieldDescription('We will never share your email.'),
            ],
          ),
          SizedBox(height: ShowcaseSpacing.xl),
          ShowcaseSectionTitle('States'),
          BCTextField(
            isRequired: true,
            children: [
              BCTextFieldLabel('Username'),
              BCTextFieldInput(hintText: 'Required field'),
            ],
          ),
          SizedBox(height: ShowcaseSpacing.md),
          BCTextField(
            isInvalid: true,
            children: [
              BCTextFieldLabel('Password'),
              BCTextFieldInput(hintText: '••••••••', obscureText: true),
              BCTextFieldError('Password must be at least 8 characters'),
            ],
          ),
          SizedBox(height: ShowcaseSpacing.md),
          BCTextField(
            isDisabled: true,
            children: [
              BCTextFieldLabel('Disabled'),
              BCTextFieldInput(hintText: 'Cannot edit'),
            ],
          ),
          SizedBox(height: ShowcaseSpacing.xl),
          ShowcaseSectionTitle('Affixes'),
          BCTextField(
            children: [
              BCTextFieldLabel('Amount'),
              BCTextFieldInput(
                hintText: '0.00',
                prefix: Icon(Icons.attach_money),
                suffix: Icon(Icons.currency_exchange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
