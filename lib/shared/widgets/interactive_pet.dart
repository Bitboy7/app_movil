import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/pet/presentation/widgets/pet_widget.dart';

class InteractivePet extends StatefulWidget {
  final double size;
  const InteractivePet({super.key, this.size = 220});

  @override
  State<InteractivePet> createState() => _InteractivePetState();
}

class _InteractivePetState extends State<InteractivePet>
    with SingleTickerProviderStateMixin {
  final List<_FloatingHeart> _hearts = [];
  late final AnimationController _spinController;
  late final Animation<double> _spinAnimation;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _spinAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );
    _spinController.addListener(() {
      setState(() {
        _currentRotation = _spinAnimation.value - pi;
      });
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _addHeart() {
    setState(() {
      _hearts.add(_FloatingHeart(
        id: DateTime.now().microsecondsSinceEpoch,
        startOffset: Offset(
          (Random().nextDouble() - 0.5) * 80,
          -20,
        ),
      ));
      if (_hearts.length > 8) _hearts.removeAt(0);
    });
  }

  void _spin() {
    HapticFeedback.selectionClick();
    _spinController.reset();
    _spinController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _addHeart();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _spin();
      },
      onHorizontalDragEnd: (_) {
        _spin();
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: _currentRotation,
              child: const PetWidget(size: 220),
            ),
            ..._hearts.map((heart) => _HeartWidget(heart: heart)),
          ],
        ),
      ),
    );
  }
}

class _FloatingHeart {
  final int id;
  final Offset startOffset;
  _FloatingHeart({required this.id, required this.startOffset});
}

class _HeartWidget extends StatefulWidget {
  final _FloatingHeart heart;
  const _HeartWidget({required this.heart});

  @override
  State<_HeartWidget> createState() => _HeartWidgetState();
}

class _HeartWidgetState extends State<_HeartWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _translate = Tween<double>(begin: 0, end: -120).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward().then((_) {
      _controller.dispose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final size = 28.0 + (1 - _opacity.value) * 16;
        return Transform.translate(
          offset: Offset(
            widget.heart.startOffset.dx,
            widget.heart.startOffset.dy + _translate.value,
          ),
          child: Opacity(
            opacity: _opacity.value,
            child: Text(
              '❤️',
              style: TextStyle(fontSize: size),
            ),
          ),
        );
      },
    );
  }
}
