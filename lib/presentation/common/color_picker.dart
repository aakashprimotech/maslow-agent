import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../utils/colors.dart';

class WorkspaceColor extends StatefulWidget {
  final ValueChanged<Color> onColorChanged;
  final Color? defaultColor;

  const WorkspaceColor({super.key, required this.onColorChanged, this.defaultColor});

  @override
  State<WorkspaceColor> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<WorkspaceColor> {
  // create some values
  Color pickerColor = const Color(0xffffffff);
  Color currentColor = const Color(0xffffffff);

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void initState() {
    if(widget.defaultColor != null){
      setState(() {
        currentColor = widget.defaultColor!;
        pickerColor = widget.defaultColor!;
      });
    }
    super.initState();
  }
  void _changeColor(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() {
                  currentColor = pickerColor;
                  widget.onColorChanged(currentColor);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _changeColor(context);
      },
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.messageBgColor,
            // border: Border.all(color: Colors.black.withAlpha(50)),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 20.0,
              width: 20.0,
              decoration: BoxDecoration(
                color: currentColor,
                border: Border.all(color: Colors.black.withAlpha(50)),
              ),
            ),
            const SizedBox(width: 10.0),
            // Space between the container and the text
            const Text(
              'Pick color',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}