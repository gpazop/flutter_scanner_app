import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class CartItemSwipe extends StatefulWidget {
  const CartItemSwipe({super.key, required this.onRemove, required this.child});

  final VoidCallback onRemove;
  final Widget child;

  @override
  State<CartItemSwipe> createState() => _CartItemSwipeState();
}

class _CartItemSwipeState extends State<CartItemSwipe>
    with SingleTickerProviderStateMixin {
  static const _actionWidth = 72.0;
  static const _flingSpeed = 350.0;

  late final AnimationController _reveal = AnimationController(vsync: this);

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  void _settle(bool open) {
    _reveal.animateTo(
      open ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Eliminar producto'): widget.onRemove,
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onHorizontalDragStart: (_) => _reveal.stop(),
          onHorizontalDragUpdate: (details) {
            _reveal.value = (_reveal.value - details.delta.dx / _actionWidth)
                .clamp(0.0, 1.0);
          },
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            _settle(
              velocity.abs() > _flingSpeed
                  ? velocity < 0
                  : _reveal.value >= 0.5,
            );
          },
          onHorizontalDragCancel: () => _settle(_reveal.value >= 0.5),
          child: AnimatedBuilder(
            animation: _reveal,
            child: widget.child,
            builder: (context, child) {
              final open = _reveal.value == 1;
              return Stack(
                children: [
                  if (_reveal.value > 0)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      width: _actionWidth,
                      child: ExcludeSemantics(
                        excluding: !open,
                        child: Material(
                          color: colors.error,
                          child: InkWell(
                            canRequestFocus: open,
                            onTap: open ? widget.onRemove : null,
                            child: Tooltip(
                              message: 'Eliminar producto',
                              child: Transform.translate(
                                offset: Offset(
                                  (1 - _reveal.value) * _actionWidth / 2,
                                  0,
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: colors.onError,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Transform.translate(
                    offset: Offset(-_reveal.value * _actionWidth, 0),
                    child: child,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
