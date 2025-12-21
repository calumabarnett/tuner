// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class RulerSlider extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const RulerSlider({
    super.key,
    required this.value,
    this.min = 20,
    this.max = 300,
    required this.onChanged,
  });

  @override
  State<RulerSlider> createState() => _RulerSliderState();
}

class _RulerSliderState extends State<RulerSlider> {
  late ScrollController _controller;
  final double _itemWidth = 10.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(
      initialScrollOffset: (widget.value - widget.min) * _itemWidth,
    );
  }

  @override
  void didUpdateWidget(RulerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isDragging) {
       final targetOffset = (widget.value - widget.min) * _itemWidth;
       if (_controller.hasClients && (_controller.offset - targetOffset).abs() > 1.0) {
          _controller.jumpTo(targetOffset);
       }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.max - widget.min + 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth / 2 - _itemWidth / 2;

    return SizedBox(
      height: 60,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
             if (notification.dragDetails != null) {
                _isDragging = true;
             }
          } else if (notification is ScrollEndNotification) {
             _isDragging = false;
             // Snap to nearest?
             final offset = _controller.offset;
             final index = (offset / _itemWidth).round();
             final targetOffset = index * _itemWidth;
             // Animate to snap
             if ((offset - targetOffset).abs() > 0.1) {
                _controller.animateTo(
                  targetOffset,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut
                );
             }
          } else if (notification is ScrollUpdateNotification) {
             if (_isDragging) {
               final offset = _controller.offset;
               final index = (offset / _itemWidth).round();
               final newValue = (widget.min + index).clamp(widget.min, widget.max);
               if (newValue != widget.value) {
                  widget.onChanged(newValue);
               }
             }
          }
          return true;
        },
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: count,
          padding: EdgeInsets.symmetric(horizontal: padding),
          itemBuilder: (context, index) {
             final bpm = widget.min + index;
             final isMajor = bpm % 10 == 0;
             final isMedium = bpm % 5 == 0;

             return Container(
               width: _itemWidth,
               alignment: Alignment.bottomCenter,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   if (isMajor)
                     Text(
                       '$bpm',
                       style: TextStyle(
                         color: Colors.white.withOpacity(0.8),
                         fontSize: 10,
                         fontFamily: 'JetBrains Mono'
                       )
                     ),
                   const SizedBox(height: 4),
                   Container(
                     width: 1.5,
                     height: isMajor ? 20 : (isMedium ? 15 : 8),
                     color: Colors.white.withOpacity(isMajor ? 0.9 : 0.4),
                   ),
                 ],
               ),
             );
          },
        ),
      ),
    );
  }
}
