import 'package:flutter/material.dart';
import 'package:food_express/components/glass_surface.dart';

class IconGlassButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Widget? badge;

  const IconGlassButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GlassSurface(
              padding: EdgeInsets.zero,
              radius: 16,
              onTap: onPressed,
              child: SizedBox(
                width: 46,
                height: 46,
                child: Icon(icon),
              ),
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: badge!,
              ),
          ],
        ),
      ),
    );
  }
}
