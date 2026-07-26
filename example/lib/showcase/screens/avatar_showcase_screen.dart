import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class AvatarShowcaseScreen extends StatelessWidget {
  const AvatarShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Avatar',
      variants: [
        UsageVariant(
          title: 'Sizes',
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              for (final size in BCAvatarSize.values)
                BCAvatar.withInitials('BC', size: size),
            ],
          ),
        ),
        UsageVariant(
          title: 'Soft colors',
          builder: (context) => Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final color in BCAvatarColor.values)
                BCAvatar.withInitials(
                  'BC',
                  variant: BCAvatarVariant.soft,
                  color: color,
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Image & fallback',
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              const BCAvatar(
                children: [
                  BCAvatarImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                  ),
                  BCAvatarFallback(initials: 'JD'),
                ],
              ),
              const BCAvatar(
                children: [
                  BCAvatarImage(
                    image: NetworkImage('https://invalid.example/x.png'),
                  ),
                  BCAvatarFallback(initials: 'FB'),
                ],
              ),
              const BCAvatar(children: [BCAvatarFallback()]),
            ],
          ),
        ),
      ],
    );
  }
}
