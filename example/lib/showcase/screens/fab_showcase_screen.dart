import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class FabShowcaseScreen extends StatelessWidget {
  const FabShowcaseScreen({super.key});

  /// A mini "screen" canvas so the FAB has a realistic surface to float over.
  Widget _canvas(BuildContext context,
      {required AlignmentGeometry alignment, required Widget fab}) {
    return BCSurface(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 420,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: BCText('Canvas',
                    type: BCTextType.bodySm, color: BCTextColor.muted),
              ),
              Align(alignment: alignment, child: fab),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'FAB',
      variants: [
        UsageVariant(
          title: 'Simple',
          builder: (context) => _canvas(
            context,
            alignment: Alignment.bottomRight,
            fab: BCFab(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {},
            ),
          ),
        ),
        UsageVariant(
          title: 'Inbox compose',
          builder: (context) => _canvas(
            context,
            alignment: Alignment.bottomRight,
            fab: BCSpeedDial(
              icon: const Icon(Icons.edit_outlined),
              items: [
                BCSpeedDialItem(label: 'New message', onPressed: () {}),
                BCSpeedDialItem(label: 'New label', onPressed: () {}),
                BCSpeedDialItem(label: 'New folder', onPressed: () {}),
              ],
            ),
          ),
        ),
        UsageVariant(
          title: 'Map controls (left)',
          builder: (context) => _canvas(
            context,
            alignment: Alignment.bottomLeft,
            fab: BCSpeedDial(
              alignment: BCFabAlignment.left,
              items: [
                BCSpeedDialItem(
                  label: 'Map layers',
                  icon: const Icon(Icons.layers_outlined),
                  onPressed: () {},
                ),
                BCSpeedDialItem(
                  label: 'Drop a pin',
                  icon: const Icon(Icons.location_on_outlined),
                  onPressed: () {},
                ),
                BCSpeedDialItem(
                  label: 'Saved places',
                  icon: const Icon(Icons.star_outline),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        UsageVariant(
          title: 'Blur backdrop',
          builder: (context) => _canvas(
            context,
            alignment: Alignment.bottomRight,
            fab: BCSpeedDial(
              backdrop: BCFabBackdrop.blur,
              items: [
                BCSpeedDialItem(
                  label: 'Share selection',
                  icon: const Icon(Icons.ios_share),
                  onPressed: () {},
                ),
                BCSpeedDialItem(
                  label: 'Download all',
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () {},
                ),
                BCSpeedDialItem(
                  label: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  isDanger: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
