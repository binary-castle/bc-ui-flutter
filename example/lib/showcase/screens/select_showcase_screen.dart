import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SelectShowcaseScreen extends StatefulWidget {
  const SelectShowcaseScreen({super.key});

  @override
  State<SelectShowcaseScreen> createState() => _SelectShowcaseScreenState();
}

class _SelectShowcaseScreenState extends State<SelectShowcaseScreen> {
  String? _country;
  String? _plan;
  String? _searchable;
  String? _sheet;
  String? _wheel;
  String? _remote;
  String? _assignee;
  String? _tier;

  /// A long list, the case that motivates search and a sheet.
  static final List<BCSelectItem<String>> _timezones = [
    for (final zone in _zoneNames)
      BCSelectItem(
        value: zone,
        label: zone.split('/').last.replaceAll('_', ' '),
        description: zone,
      ),
  ];

  // Paginated demo: a page of 20 arrives each time the list nears its end.
  final List<BCSelectItem<String>> _paged = [
    for (var i = 1; i <= 20; i++)
      BCSelectItem(value: 'row-$i', label: 'Row $i'),
  ];
  bool _isLoadingPage = false;

  Future<void> _loadPage() async {
    if (_isLoadingPage || _paged.length >= 100) return;
    setState(() => _isLoadingPage = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      final start = _paged.length + 1;
      _paged.addAll([
        for (var i = start; i < start + 20; i++)
          BCSelectItem(value: 'row-$i', label: 'Row $i'),
      ]);
      _isLoadingPage = false;
    });
  }

  /// Stands in for a network lookup.
  Future<List<BCSelectItem<String>>> _searchTimezones(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _timezones.take(12).toList();
    return [
      for (final item in _timezones)
        if (item.label.toLowerCase().contains(q) ||
            item.description!.toLowerCase().contains(q))
          item,
    ].take(20).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Select',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => BCSelect<String>(
            placeholder: 'Select a country',
            items: const [
              BCSelectItem(value: 'bd', label: 'Bangladesh'),
              BCSelectItem(value: 'us', label: 'United States'),
              BCSelectItem(value: 'jp', label: 'Japan'),
              BCSelectItem(value: 'de', label: 'Germany'),
            ],
            value: _country,
            onValueChange: (value) => setState(() => _country = value),
          ),
        ),
        UsageVariant(
          title: 'With descriptions',
          builder: (context) => BCSelect<String>(
            placeholder: 'Choose a plan',
            listLabel: 'Plans',
            items: const [
              BCSelectItem(
                value: 'free',
                label: 'Free',
                description: 'For personal projects',
              ),
              BCSelectItem(
                value: 'pro',
                label: 'Pro',
                description: 'For professionals',
              ),
              BCSelectItem(
                value: 'team',
                label: 'Team',
                description: 'For organizations',
              ),
            ],
            value: _plan,
            onValueChange: (value) => setState(() => _plan = value),
          ),
        ),
        UsageVariant(
          title: 'Searchable',
          builder: (context) => BCSelect<String>(
            placeholder: 'Select a timezone',
            listLabel: 'Timezones',
            isSearchable: true,
            searchPlaceholder: 'Search timezones',
            items: _timezones,
            value: _searchable,
            onValueChange: (value) => setState(() => _searchable = value),
          ),
        ),
        UsageVariant(
          title: 'Bottom sheet',
          builder: (context) => BCSelect<String>(
            placeholder: 'Select a timezone',
            listLabel: 'Timezones',
            presentation: BCSelectPresentation.bottomSheet,
            isSearchable: true,
            searchPlaceholder: 'Search timezones',
            items: _timezones,
            value: _sheet,
            onValueChange: (value) => setState(() => _sheet = value),
          ),
        ),
        UsageVariant(
          title: 'Wheel',
          builder: (context) => BCSelect<String>(
            placeholder: 'Party size',
            listLabel: 'Party size',
            presentation: BCSelectPresentation.wheel,
            items: [
              for (var i = 1; i <= 12; i++)
                BCSelectItem(
                  value: '$i',
                  label: i == 1 ? '1 guest' : '$i guests',
                ),
            ],
            value: _wheel,
            onValueChange: (value) => setState(() => _wheel = value),
          ),
        ),
        UsageVariant(
          title: 'Async search',
          builder: (context) => BCSelect<String>(
            placeholder: 'Search a timezone',
            listLabel: 'Timezones',
            presentation: BCSelectPresentation.bottomSheet,
            searchPlaceholder: 'Type to search',
            items: const [],
            onSearch: _searchTimezones,
            value: _remote,
            onValueChange: (value) => setState(() => _remote = value),
          ),
        ),
        UsageVariant(
          title: 'Pagination',
          builder: (context) => BCSelect<String>(
            placeholder: 'Scroll for more',
            listLabel: '${_paged.length} of 100 loaded',
            items: _paged,
            onLoadMore: _loadPage,
            isLoadingMore: _isLoadingPage,
            value: null,
            onValueChange: (_) {},
          ),
        ),
        UsageVariant(
          title: 'Rows with slots',
          builder: (context) => BCSelect<String>(
            placeholder: 'Assign to',
            listLabel: 'Teammates',
            items: [
              BCSelectItem(
                value: 'ada',
                label: 'Ada Lovelace',
                description: 'Engineering',
                leading: BCAvatar.withInitials('AL', size: BCAvatarSize.small),
                trailing: BCChip.label(
                  'Owner',
                  size: BCChipSize.sm,
                  variant: BCChipVariant.soft,
                ),
              ),
              BCSelectItem(
                value: 'grace',
                label: 'Grace Hopper',
                description: 'Design',
                leading: BCAvatar.withInitials('GH', size: BCAvatarSize.small),
              ),
              BCSelectItem(
                value: 'alan',
                label: 'Alan Turing',
                description: 'On leave',
                leading: BCAvatar.withInitials('AT', size: BCAvatarSize.small),
                isDisabled: true,
              ),
              BCSelectItem(
                value: 'invite',
                label: 'Invite someone…',
                leading: const Icon(Icons.person_add_alt, size: 20),
                // The side errand a row sometimes carries.
                onTap: () => debugPrint('open the invite flow'),
              ),
            ],
            value: _assignee,
            onValueChange: (value) => setState(() => _assignee = value),
          ),
        ),
        UsageVariant(
          title: 'Custom rows',
          builder: (context) {
            final bc = context.bcTheme;
            return BCSelect<String>(
              placeholder: 'Choose a tier',
              listLabel: 'Tiers',
              items: const [
                BCSelectItem(value: 'basic', label: 'Basic', description: r'$0'),
                BCSelectItem(value: 'plus', label: 'Plus', description: r'$12'),
                BCSelectItem(value: 'max', label: 'Max', description: r'$29'),
              ],
              value: _tier,
              onValueChange: (value) => setState(() => _tier = value),
              // The whole row is yours; selection is handed in.
              itemBuilder: (context, item, isSelected) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  color: isSelected ? bc.accentSoft : bc.backgroundSecondary,
                  shape: BCShapes.continuous(
                    BCRadius.xxl,
                    side: isSelected
                        ? BorderSide(color: bc.accent, width: bc.borderWidth)
                        : BorderSide.none,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: BCTypography.textBase.copyWith(
                          color: isSelected
                              ? bc.accentSoftForeground
                              : bc.foreground,
                          fontWeight: BCTypography.semiBold,
                        ),
                      ),
                    ),
                    Text(
                      '${item.description} / mo',
                      style: BCTypography.textSm.copyWith(color: bc.muted),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const BCSelect<String>(
            placeholder: 'Disabled select',
            isDisabled: true,
            items: [BCSelectItem(value: 'x', label: 'X')],
          ),
        ),
      ],
    );
  }
}

/// Enough zones to make search worth it.
const List<String> _zoneNames = [
  'Africa/Cairo', 'Africa/Lagos', 'Africa/Nairobi', 'America/Bogota',
  'America/Chicago', 'America/Denver', 'America/Los_Angeles',
  'America/Mexico_City', 'America/New_York', 'America/Sao_Paulo',
  'America/Toronto', 'Asia/Dhaka', 'Asia/Dubai', 'Asia/Hong_Kong',
  'Asia/Jakarta', 'Asia/Karachi', 'Asia/Kolkata', 'Asia/Manila',
  'Asia/Seoul', 'Asia/Shanghai', 'Asia/Singapore', 'Asia/Tokyo',
  'Australia/Melbourne', 'Australia/Perth', 'Australia/Sydney',
  'Europe/Amsterdam', 'Europe/Berlin', 'Europe/Dublin', 'Europe/Istanbul',
  'Europe/Lisbon', 'Europe/London', 'Europe/Madrid', 'Europe/Moscow',
  'Europe/Paris', 'Europe/Rome', 'Europe/Stockholm', 'Europe/Warsaw',
  'Europe/Zurich', 'Pacific/Auckland', 'Pacific/Honolulu',
];
