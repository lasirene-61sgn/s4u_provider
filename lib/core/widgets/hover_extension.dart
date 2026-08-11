
import 'package:flutter/material.dart';

extension HoverExtension on Widget {
  Widget get hoverScale => _HoverScaleWrapper(child: this);
  Widget get hoverShadow => _HoverShadowWrapper(child: this);
}

class _HoverScaleWrapper extends StatefulWidget {
  final Widget child;
  const _HoverScaleWrapper({required this.child});
  @override
  State<_HoverScaleWrapper> createState() => _HoverScaleWrapperState();
}

class _HoverScaleWrapperState extends State<_HoverScaleWrapper> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.diagonal3Values(1.02, 1.02, 1.0) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

class _HoverShadowWrapper extends StatefulWidget {
  final Widget child;
  const _HoverShadowWrapper({required this.child});
  @override
  State<_HoverShadowWrapper> createState() => _HoverShadowWrapperState();
}

class _HoverShadowWrapperState extends State<_HoverShadowWrapper> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.translationValues(0.0, -5.0, 0.0) : Matrix4.identity(),
        decoration: BoxDecoration(
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              )
          ],
          borderRadius: BorderRadius.circular(24),
        ),
        child: widget.child,
      ),
    );
  }
}
