import 'package:bc_ui/bc_ui.dart';
import 'package:example/main.dart' show ThemeToggleButton;
import 'package:example/showcase/screens/app_header_showcase_screen.dart';
import 'package:example/showcase/screens/avatar_showcase_screen.dart';
import 'package:example/showcase/screens/bottom_nav_showcase_screen.dart';
import 'package:example/showcase/screens/button_showcase_screen.dart';
import 'package:example/showcase/screens/card_showcase_screen.dart';
import 'package:example/showcase/screens/checkbox_showcase_screen.dart';
import 'package:example/showcase/screens/chip_showcase_screen.dart';
import 'package:example/showcase/screens/control_field_showcase_screen.dart';
import 'package:example/showcase/screens/date_field_showcase_screen.dart';
import 'package:example/showcase/screens/date_time_picker_showcase_screen.dart';
import 'package:example/showcase/screens/demo_app_screen.dart';
import 'package:example/showcase/screens/dialog_showcase_screen.dart';
import 'package:example/showcase/screens/empty_state_showcase_screen.dart';
import 'package:example/showcase/screens/fab_showcase_screen.dart';
import 'package:example/showcase/screens/flip_card_showcase_screen.dart';
import 'package:example/showcase/screens/input_otp_showcase_screen.dart';
import 'package:example/showcase/screens/input_showcase_screen.dart';
import 'package:example/showcase/screens/link_button_showcase_screen.dart';
import 'package:example/showcase/screens/list_group_showcase_screen.dart';
import 'package:example/showcase/screens/menu_showcase_screen.dart';
import 'package:example/showcase/screens/navigation_showcase_screen.dart';
import 'package:example/showcase/screens/popover_showcase_screen.dart';
import 'package:example/showcase/screens/progress_showcase_screen.dart';
import 'package:example/showcase/screens/radio_group_showcase_screen.dart';
import 'package:example/showcase/screens/range_slider_showcase_screen.dart';
import 'package:example/showcase/screens/rating_showcase_screen.dart';
import 'package:example/showcase/screens/scroll_shadow_showcase_screen.dart';
import 'package:example/showcase/screens/search_field_showcase_screen.dart';
import 'package:example/showcase/screens/select_showcase_screen.dart';
import 'package:example/showcase/screens/separator_showcase_screen.dart';
import 'package:example/showcase/screens/skeleton_showcase_screen.dart';
import 'package:example/showcase/screens/slider_showcase_screen.dart';
import 'package:example/showcase/screens/spinner_showcase_screen.dart';
import 'package:example/showcase/screens/surface_showcase_screen.dart';
import 'package:example/showcase/screens/switch_showcase_screen.dart';
import 'package:example/showcase/screens/tabs_showcase_screen.dart';
import 'package:example/showcase/screens/tag_group_showcase_screen.dart';
import 'package:example/showcase/screens/text_area_showcase_screen.dart';
import 'package:example/showcase/screens/text_field_showcase_screen.dart';
import 'package:example/showcase/screens/time_field_showcase_screen.dart';
import 'package:example/showcase/screens/toast_showcase_screen.dart';
import 'package:example/showcase/screens/toggle_button_showcase_screen.dart';
import 'package:example/showcase/screens/toolbar_showcase_screen.dart';
import 'package:example/showcase/screens/typography_showcase_screen.dart';
import 'package:flutter/material.dart';

class ComponentEntry {
  const ComponentEntry(this.title, this.builder);

  final String title;
  final WidgetBuilder builder;
}

/// Component registry — mirrors heroui-native's example
/// `helpers/data/components.ts`, one route per component, alphabetical.
final List<ComponentEntry> componentRegistry = [
  ComponentEntry('★ Demo app screen', (_) => const DemoAppScreen()),
  ComponentEntry('AppHeader', (_) => const AppHeaderShowcaseScreen()),
  ComponentEntry('Avatar', (_) => const AvatarShowcaseScreen()),
  ComponentEntry('BottomNav', (_) => const BottomNavShowcaseScreen()),
  ComponentEntry('Button', (_) => const ButtonShowcaseScreen()),
  ComponentEntry('Card', (_) => const CardShowcaseScreen()),
  ComponentEntry('Checkbox', (_) => const CheckboxShowcaseScreen()),
  ComponentEntry('Chip', (_) => const ChipShowcaseScreen()),
  ComponentEntry('ControlField', (_) => const ControlFieldShowcaseScreen()),
  ComponentEntry('DateField', (_) => const DateFieldShowcaseScreen()),
  ComponentEntry(
    'DateTimePicker',
    (_) => const DateTimePickerShowcaseScreen(),
  ),
  ComponentEntry('Dialog', (_) => const DialogShowcaseScreen()),
  ComponentEntry('EmptyState', (_) => const EmptyStateShowcaseScreen()),
  ComponentEntry('FAB', (_) => const FabShowcaseScreen()),
  ComponentEntry('FlipCard', (_) => const FlipCardShowcaseScreen()),
  ComponentEntry('Input', (_) => const InputShowcaseScreen()),
  ComponentEntry('InputOTP', (_) => const InputOtpShowcaseScreen()),
  ComponentEntry(
    'LinkButton & CloseButton',
    (_) => const LinkButtonShowcaseScreen(),
  ),
  ComponentEntry('ListGroup', (_) => const ListGroupShowcaseScreen()),
  ComponentEntry('Menu', (_) => const MenuShowcaseScreen()),
  ComponentEntry(
    'NavRail & NavDrawer',
    (_) => const NavigationShowcaseScreen(),
  ),
  ComponentEntry('Popover', (_) => const PopoverShowcaseScreen()),
  ComponentEntry('Progress & Loading', (_) => const ProgressShowcaseScreen()),
  ComponentEntry('RadioGroup', (_) => const RadioGroupShowcaseScreen()),
  ComponentEntry('RangeSlider', (_) => const RangeSliderShowcaseScreen()),
  ComponentEntry('Rating', (_) => const RatingShowcaseScreen()),
  ComponentEntry('ScrollShadow', (_) => const ScrollShadowShowcaseScreen()),
  ComponentEntry('SearchField', (_) => const SearchFieldShowcaseScreen()),
  ComponentEntry('Select', (_) => const SelectShowcaseScreen()),
  ComponentEntry('Separator', (_) => const SeparatorShowcaseScreen()),
  ComponentEntry('Skeleton', (_) => const SkeletonShowcaseScreen()),
  ComponentEntry('Slider', (_) => const SliderShowcaseScreen()),
  ComponentEntry('Spinner', (_) => const SpinnerShowcaseScreen()),
  ComponentEntry('Surface', (_) => const SurfaceShowcaseScreen()),
  ComponentEntry('Switch', (_) => const SwitchShowcaseScreen()),
  ComponentEntry('Tabs', (_) => const TabsShowcaseScreen()),
  ComponentEntry('TagGroup', (_) => const TagGroupShowcaseScreen()),
  ComponentEntry('TextArea', (_) => const TextAreaShowcaseScreen()),
  ComponentEntry('TextField', (_) => const TextFieldShowcaseScreen()),
  ComponentEntry('TimeField', (_) => const TimeFieldShowcaseScreen()),
  ComponentEntry('Toast', (_) => const ToastShowcaseScreen()),
  ComponentEntry('ToggleButton', (_) => const ToggleButtonShowcaseScreen()),
  ComponentEntry('Toolbar', (_) => const ToolbarShowcaseScreen()),
  ComponentEntry('Typography', (_) => const TypographyShowcaseScreen()),
];

class ShowcaseHomeScreen extends StatelessWidget {
  const ShowcaseHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BC UI Components'),
        actions: const [ThemeToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BCListGroup(
            children: [
              for (final entry in componentRegistry)
                BCListGroupItem(
                  title: entry.title,
                  suffix: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: context.bcTheme.muted,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: entry.builder),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
