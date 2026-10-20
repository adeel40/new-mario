import 'package:flutter/material.dart';

import '../game/mario_game.dart';

/// On-screen touch controls for mobile: a left/right D-pad on the bottom-left
/// and jump (A) / run (B) buttons on the bottom-right. Uses raw pointer
/// listeners so multiple buttons can be held at once (e.g. run + jump).
class TouchControls extends StatelessWidget {
  const TouchControls({super.key, required this.game});
  final MarioGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18, left: 18, right: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // D-pad
            Row(
              children: [
                _HoldButton(
                  label: '◀',
                  onDown: () => game.vLeft = true,
                  onUp: () => game.vLeft = false,
                ),
                const SizedBox(width: 14),
                _HoldButton(
                  label: '▶',
                  onDown: () => game.vRight = true,
                  onUp: () => game.vRight = false,
                ),
              ],
            ),
            const Spacer(),
            // Action buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _HoldButton(
                  label: 'B',
                  color: const Color(0xFF2B50C8),
                  size: 60,
                  onDown: () => game.vRun = true,
                  onUp: () => game.vRun = false,
                ),
                const SizedBox(width: 18),
                _HoldButton(
                  label: 'A',
                  color: const Color(0xFFD62828),
                  size: 76,
                  onDown: () => game.vJump = true,
                  onUp: () => game.vJump = false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldButton extends StatefulWidget {
  const _HoldButton({
    required this.label,
    required this.onDown,
    required this.onUp,
    this.color = const Color(0xFF37474F),
    this.size = 64,
  });

  final String label;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final Color color;
  final double size;

  @override
  State<_HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<_HoldButton> {
  bool _pressed = false;

  void _set(bool v) {
    if (v == _pressed) return;
    setState(() => _pressed = v);
    if (v) {
      widget.onDown();
    } else {
      widget.onUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 70),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _pressed ? 0.95 : 0.65),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white54, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.size * 0.4,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
