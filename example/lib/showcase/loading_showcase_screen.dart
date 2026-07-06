import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:flutter/material.dart';

class LoadingShowcaseScreen extends StatefulWidget {
  const LoadingShowcaseScreen({super.key});

  @override
  State<LoadingShowcaseScreen> createState() => _LoadingShowcaseScreenState();
}

class _LoadingShowcaseScreenState extends State<LoadingShowcaseScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading')),
      body: ListView(
        padding: const EdgeInsets.all(ShowcaseSpacing.lg),
        children: [
          const ShowcaseSectionTitle('Sizes'),
          const BCCard(
            child: Row(
              children: [
                BCLoading(size: BCLoadingSize.small),
                SizedBox(width: ShowcaseSpacing.lg),
                BCLoading(size: BCLoadingSize.medium),
                SizedBox(width: ShowcaseSpacing.lg),
                BCLoading(size: BCLoadingSize.large),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Colors'),
          const BCCard(
            child: Row(
              children: [
                BCLoading(color: BCLoadingColor.defaultColor),
                SizedBox(width: ShowcaseSpacing.lg),
                BCLoading(color: BCLoadingColor.success),
                SizedBox(width: ShowcaseSpacing.lg),
                BCLoading(color: BCLoadingColor.warning),
                SizedBox(width: ShowcaseSpacing.lg),
                BCLoading(color: BCLoadingColor.danger),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Custom Color'),
          BCCard(
            child: BCLoading(
              customColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Loading Toggle'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('isLoading'),
                    const Spacer(),
                    Switch(
                      value: _isLoading,
                      onChanged: (value) => setState(() => _isLoading = value),
                    ),
                  ],
                ),
                const SizedBox(height: ShowcaseSpacing.md),
                Center(
                  child: BCLoading(
                    isLoading: _isLoading,
                    size: BCLoadingSize.large,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Custom Indicator'),
          const BCCard(
            child: Center(
              child: BCLoading(
                child: BCLoadingIndicator(
                  child: Icon(Icons.refresh, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
