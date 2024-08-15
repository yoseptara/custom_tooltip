import 'package:flutter/material.dart';
import 'dart:async';

class TooltipArrowPainter extends CustomPainter {
  final Size size;
  final Color color;
  final bool isInverted;

  TooltipArrowPainter({
    required this.size,
    required this.color,
    required this.isInverted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isInverted) {
      path.moveTo(0.0, size.height);
      path.lineTo(size.width / 2, 0.0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0.0, 0.0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0.0);
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TooltipArrow extends StatelessWidget {
  final Size size;
  final Color color;
  final bool isInverted;

  const TooltipArrow({
    super.key,
    this.size = const Size(10.49, 5.24),
    this.color = Colors.white,
    this.isInverted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-size.width / 2, 0),
      child: CustomPaint(
        size: size,
        painter: TooltipArrowPainter(
          size: size,
          color: color,
          isInverted: isInverted,
        ),
      ),
    );
  }
}

// A tooltip with text, action buttons, and an arrow pointing to the target.
class CustomTooltip extends StatefulWidget {
  final Widget content;
  final GlobalKey? targetGlobalKey;
  final Duration? delay;
  final Widget? child;
  final Color backgroundColor;

  const CustomTooltip({
    super.key,
    required this.content,
    this.targetGlobalKey,
    this.delay,
    this.child,
    this.backgroundColor = Colors.white,
  }) : assert(child != null || targetGlobalKey != null);

  @override
  State<StatefulWidget> createState() => CustomTooltipState();
}

const double targetToArrowGapHeight = 7.75;

class CustomTooltipState extends State<CustomTooltip>
    with SingleTickerProviderStateMixin {
  late double? _tooltipTop;
  late double? _tooltipBottom;
  late Alignment _tooltipAlignment;
  late Alignment _arrowAlignment;
  bool _isInverted = false;
  Timer? _delayTimer;

  final _arrowSize = const Size(10.49, 5.24);
  final _tooltipMinimumHeight = 140;

  final _overlayController = OverlayPortalController();

  void _toggle() {
    _delayTimer?.cancel();
    if (_overlayController.isShowing) {
      _overlayController.hide();
    } else {
      _updatePosition();
      _overlayController.show();
    }
  }

  void _updatePosition() {
    final Size contextSize = MediaQuery.of(context).size;
    final BuildContext? targetContext = widget.targetGlobalKey != null
        ? widget.targetGlobalKey!.currentContext
        : context;
    final targetRenderBox = targetContext?.findRenderObject() as RenderBox;
    final targetOffset = targetRenderBox.localToGlobal(Offset.zero);
    final targetSize = targetRenderBox.size;
    // Try to position the tooltip above the target,
    // otherwise try to position it below or in the center of the target.
    final tooltipFitsAboveTarget = targetOffset.dy - _tooltipMinimumHeight >= 0;
    final tooltipFitsBelowTarget =
        targetOffset.dy + targetSize.height + _tooltipMinimumHeight <=
            contextSize.height;
    _tooltipTop = tooltipFitsAboveTarget
        ? null
        : tooltipFitsBelowTarget
        ? targetOffset.dy + targetSize.height + targetToArrowGapHeight
        : null;
    _tooltipBottom = tooltipFitsAboveTarget
        ? contextSize.height - targetOffset.dy + targetToArrowGapHeight
        : tooltipFitsBelowTarget
        ? null
        : targetOffset.dy + targetSize.height / 2 + targetToArrowGapHeight;
    // If the tooltip is below the target, invert the arrow.
    _isInverted = _tooltipTop != null;
    // Align the tooltip horizontally relative to the target.
    _tooltipAlignment = Alignment(
      (targetOffset.dx) / (contextSize.width - targetSize.width) * 2 - 1.0,
      _isInverted ? 1.0 : -1.0,
    );

    // Center the arrow horizontally on the target.
    _arrowAlignment = Alignment(
      (targetOffset.dx + targetSize.width / 2) /
          (contextSize.width - _arrowSize.width) *
          2 -
          1.0,
      _isInverted ? 1.0 : -1.0,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If the tooltip is delayed, start a timer to show it.
      if (widget.delay != null) {
        _delayTimer = Timer(widget.delay!, _toggle);
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return OverlayPortal.targetsRootOverlay(
      controller: _overlayController,
      child: widget.child != null
          ? GestureDetector(onTap: _toggle, child: widget.child)
          : null,
      overlayChildBuilder: (context) {
        return Positioned(
          top: _tooltipTop,
          bottom: _tooltipBottom,
          // Provide a transition alignment to make the tooltip appear from the target.
          child: TapRegion(
            onTapOutside: (PointerDownEvent event) {
              _toggle();
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isInverted)
                    Align(
                      alignment: _arrowAlignment,
                      child: TooltipArrow(
                        size: _arrowSize,
                        isInverted: true,
                        color: widget.backgroundColor,
                      ),
                    ),
                  Align(
                    alignment: _tooltipAlignment,
                    child: IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.backgroundColor,
                          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                        ),
                        child: widget.content,
                      ),
                    ),
                  ),
                  if (!_isInverted)
                    Align(
                      alignment: _arrowAlignment,
                      child: TooltipArrow(
                        size: _arrowSize,
                        isInverted: false,
                        color: widget.backgroundColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
