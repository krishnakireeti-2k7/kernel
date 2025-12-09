// features/routines/routine_picker_page.dart
import 'package:flutter/material.dart';

class CreateRoutineDialog extends StatefulWidget {
  final Function(String) onCreated;
  const CreateRoutineDialog({required this.onCreated, super.key});

  @override
  State<CreateRoutineDialog> createState() => _CreateRoutineDialogState();
}

class _CreateRoutineDialogState extends State<CreateRoutineDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("New Routine", style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "e.g. PPL",
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              widget.onCreated(name);
              Navigator.pop(context);
            }
          },
          child: const Text("Create", style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
