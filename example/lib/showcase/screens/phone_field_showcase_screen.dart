import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:flutter/cupertino.dart';

class PhoneFieldShowcaseScreen extends StatelessWidget {
  const PhoneFieldShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'PhoneField',
      variants: [
        UsageVariant(
          title: 'Default',
          builder: (context) => const BCPhoneField(
            label: 'Phone',
            description: 'No initialCountry — this opened on your device '
                'region.',
          ),
        ),
        UsageVariant(
          title: 'Labelled',
          builder: (context) => const BCPhoneField(
            label: 'Mobile',
            description: 'We only text you about deliveries.',
            isRequired: true,
            initialCountry: IsoCode.BD,
          ),
        ),
        UsageVariant(
          title: 'Preferred countries',
          builder: (context) => const BCPhoneField(
            label: 'Phone',
            description: 'Bangladesh, the UK and the US are pinned to the top.',
            preferredCountries: [IsoCode.BD, IsoCode.GB, IsoCode.US],
            initialCountry: IsoCode.BD,
          ),
        ),
        UsageVariant(
          title: 'Restricted list',
          builder: (context) => const BCPhoneField(
            label: 'Phone',
            description: 'We only deliver to these three.',
            countries: [IsoCode.BD, IsoCode.IN, IsoCode.PK],
            initialCountry: IsoCode.BD,
          ),
        ),
        UsageVariant(
          title: 'Live validation',
          builder: (context) => const _ValidationDemo(),
        ),
        UsageVariant(
          title: 'Server error',
          builder: (context) => const BCPhoneField(
            label: 'Mobile',
            initialValue:
                BCPhoneNumber(isoCode: IsoCode.US, nsn: '2015550123'),
            errorText: 'That number is already registered.',
          ),
        ),
        UsageVariant(
          title: 'Popover picker',
          builder: (context) => const BCPhoneField(
            label: 'Phone',
            description: 'The country list drops under the field.',
            countryPresentation: BCSelectPresentation.popover,
          ),
        ),
        UsageVariant(
          title: 'In a Cupertino form',
          builder: (context) => const _InlineFormDemo(),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const BCPhoneField(
            label: 'Mobile',
            initialValue:
                BCPhoneNumber(isoCode: IsoCode.GB, nsn: '7400123456'),
            isDisabled: true,
          ),
        ),
      ],
    );
  }
}

/// `inline: true` in the place it is for — a row of an iOS grouped form,
/// sitting between two native ones.
class _InlineFormDemo extends StatelessWidget {
  const _InlineFormDemo();

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection.insetGrouped(
      header: const Text('CONTACT'),
      footer: const Text(
        'The section draws the background and the hairlines between rows, so '
        'the field draws neither and its label moves beside the number.',
      ),
      children: [
        CupertinoTextFormFieldRow(
          prefix: const Text('Name'),
          placeholder: 'Jane Doe',
        ),
        const BCPhoneField(
          label: 'Mobile',
          inline: true,
          initialCountry: IsoCode.BD,
          preferredCountries: [IsoCode.BD, IsoCode.GB, IsoCode.US],
        ),
        CupertinoTextFormFieldRow(
          prefix: const Text('Email'),
          placeholder: 'jane@example.com',
        ),
      ],
    );
  }
}

/// Shows what the field reports back on every keystroke, and gates a submit
/// button on it.
class _ValidationDemo extends StatefulWidget {
  const _ValidationDemo();

  @override
  State<_ValidationDemo> createState() => _ValidationDemoState();
}

class _ValidationDemoState extends State<_ValidationDemo> {
  BCPhoneNumber _value =
      const BCPhoneNumber(isoCode: IsoCode.US, nsn: '');
  bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BCPhoneField(
          label: 'Mobile',
          isRequired: true,
          preferredCountries: const [IsoCode.US, IsoCode.GB, IsoCode.BD],
          onChanged: (value) => setState(() => _value = value),
          onValidityChanged: (valid) => setState(() => _isValid = valid),
        ),
        const SizedBox(height: ShowcaseSpacing.lg),
        Container(
          padding: const EdgeInsets.all(ShowcaseSpacing.md),
          decoration: BoxDecoration(
            color: bc.surfaceSecondary,
            borderRadius: BorderRadius.circular(ShowcaseRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: ShowcaseSpacing.xs,
            children: [
              _Row(label: 'e164', value: _value.e164),
              _Row(label: 'national', value: _value.national),
              _Row(label: 'country', value: _value.isoCode.name),
              _Row(label: 'isValid', value: '${_value.isValid}'),
            ],
          ),
        ),
        const SizedBox(height: ShowcaseSpacing.lg),
        BCButton(
          onPressed: _isValid ? () {} : null,
          isDisabled: !_isValid,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: BCTypography.textSm.copyWith(color: bc.muted),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: BCTypography.textSm.copyWith(color: bc.foreground),
          ),
        ),
      ],
    );
  }
}
