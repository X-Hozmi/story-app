import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int initialLines;

  const ExpandableText({
    required this.text,
    this.initialLines = 4,
    super.key,
  });

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  late int _maxLines;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _maxLines = widget.initialLines;
    _isExpanded = false;
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      _maxLines = _isExpanded ? 255 : widget.initialLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpand,
      child: Text(
        widget.text,
        maxLines: _maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
