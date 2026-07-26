import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/avatar_theme.dart';
import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

export 'package:bc_ui/src/theme/component_themes/avatar_theme.dart'
    show BCAvatarColor, BCAvatarSize, BCAvatarStatus, BCAvatarVariant;

class BCAvatar extends StatefulWidget {
  const BCAvatar({
    super.key,
    required this.children,
    this.size = BCAvatarSize.medium,
    this.variant = BCAvatarVariant.defaultVariant,
    this.color = BCAvatarColor.accent,
  });

  BCAvatar.withInitials(
    String initials, {
    super.key,
    this.size = BCAvatarSize.medium,
    this.variant = BCAvatarVariant.defaultVariant,
    this.color = BCAvatarColor.accent,
    int delayMs = 0,
  }) : children = [BCAvatarFallback(initials: initials, delayMs: delayMs)];

  final List<Widget> children;
  final BCAvatarSize size;
  final BCAvatarVariant variant;
  final BCAvatarColor color;

  @override
  State<BCAvatar> createState() => _BCAvatarState();
}

class _BCAvatarState extends State<BCAvatar> {
  BCAvatarStatus _status = BCAvatarStatus.loading;

  void _onStatusChanged(BCAvatarStatus status) {
    if (_status == status) return;
    setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    final diameter = BCAvatarTheme.diameter(widget.size);

    return _BCAvatarScope(
      size: widget.size,
      variant: widget.variant,
      color: widget.color,
      status: _status,
      onStatusChanged: _onStatusChanged,
      child: Container(
        width: diameter,
        height: diameter,
        clipBehavior: Clip.antiAlias,
        decoration: BCAvatarTheme.decoration(
          variant: widget.variant,
          color: widget.color,
          bc: context.bcTheme,
        ),
        child: Stack(fit: StackFit.expand, children: widget.children),
      ),
    );
  }
}

class BCAvatarImage extends StatefulWidget {
  const BCAvatarImage({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
  });

  BCAvatarImage.network(String url, {Key? key, BoxFit fit = BoxFit.cover})
    : this(key: key, image: NetworkImage(url), fit: fit);

  BCAvatarImage.asset(String asset, {Key? key, BoxFit fit = BoxFit.cover})
    : this(key: key, image: AssetImage(asset), fit: fit);

  final ImageProvider image;
  final BoxFit fit;

  @override
  State<BCAvatarImage> createState() => _BCAvatarImageState();
}

class _BCAvatarImageState extends State<BCAvatarImage> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listenToStream();
  }

  @override
  void didUpdateWidget(BCAvatarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _listenToStream();
    }
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  void _listenToStream() {
    final stream = widget.image.resolve(createLocalImageConfiguration(context));
    if (stream.key == _imageStream?.key) return;

    _stopListening();
    _imageStream = stream;
    _reportStatus(BCAvatarStatus.loading);

    _imageStreamListener = ImageStreamListener(
      (image, synchronousCall) {
        _reportStatus(BCAvatarStatus.loaded);
      },
      onError: (error, stackTrace) {
        _reportStatus(BCAvatarStatus.error);
      },
    );

    stream.addListener(_imageStreamListener!);
  }

  void _stopListening() {
    if (_imageStreamListener != null && _imageStream != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStreamListener = null;
    _imageStream = null;
  }

  void _reportStatus(BCAvatarStatus status) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _BCAvatarScope.of(context)?.onStatusChanged(status);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.image,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null && !wasSynchronouslyLoaded) {
          return const SizedBox.shrink();
        }

        return AnimatedOpacity(
          opacity: 1,
          duration: BCDuration.fast,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }
}

class BCAvatarFallback extends StatefulWidget {
  const BCAvatarFallback({
    super.key,
    this.child,
    this.initials,
    this.delayMs = 0,
  });

  final Widget? child;
  final String? initials;
  final int delayMs;

  @override
  State<BCAvatarFallback> createState() => _BCAvatarFallbackState();
}

class _BCAvatarFallbackState extends State<BCAvatarFallback> {
  bool _delayElapsed = false;

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  @override
  void didUpdateWidget(BCAvatarFallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delayMs != widget.delayMs) {
      _startDelay();
    }
  }

  void _startDelay() {
    _delayElapsed = widget.delayMs <= 0;
    if (widget.delayMs > 0) {
      Future<void>.delayed(Duration(milliseconds: widget.delayMs)).then((_) {
        if (mounted) setState(() => _delayElapsed = true);
      });
    }
  }

  bool _shouldShow(BCAvatarStatus status) {
    return switch (status) {
      BCAvatarStatus.loaded => false,
      BCAvatarStatus.error => true,
      BCAvatarStatus.loading => _delayElapsed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scope = _BCAvatarScope.of(context);
    if (scope == null || !_shouldShow(scope.status)) {
      return const SizedBox.shrink();
    }

    final foreground = BCAvatarTheme.foregroundColor(
      color: scope.color,
      bc: context.bcTheme,
    );

    if (widget.child != null) {
      return Center(child: widget.child);
    }

    if (widget.initials != null && widget.initials!.isNotEmpty) {
      return Center(
        child: Text(
          widget.initials!,
          style: BCAvatarTheme.fallbackTextStyle(scope.size, foreground),
        ),
      );
    }

    return Center(
      child: Icon(
        Icons.person,
        size: BCAvatarTheme.iconSize(scope.size),
        color: foreground,
      ),
    );
  }
}

class _BCAvatarScope extends InheritedWidget {
  const _BCAvatarScope({
    required this.size,
    required this.variant,
    required this.color,
    required this.status,
    required this.onStatusChanged,
    required super.child,
  });

  final BCAvatarSize size;
  final BCAvatarVariant variant;
  final BCAvatarColor color;
  final BCAvatarStatus status;
  final ValueChanged<BCAvatarStatus> onStatusChanged;

  static _BCAvatarScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_BCAvatarScope>();
  }

  @override
  bool updateShouldNotify(_BCAvatarScope oldWidget) {
    return size != oldWidget.size ||
        variant != oldWidget.variant ||
        color != oldWidget.color ||
        status != oldWidget.status;
  }
}
