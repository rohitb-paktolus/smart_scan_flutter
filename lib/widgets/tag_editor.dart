import 'package:flutter/material.dart';

class TagEditor extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const TagEditor({
    super.key,
    required this.controller,
    this.labelText = "Tags",
  });

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final TextEditingController _inputController = TextEditingController();
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _initializeTags();
    widget.controller.addListener(_syncTagsFormController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncTagsFormController);
    _inputController.dispose();
    super.dispose();
  }

  void _initializeTags() {
    final String text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tags =
            text
                .split(",")
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList();
      });
    }
  }

  void _syncTagsFormController() {
    _initializeTags();
  }

  void _updateController() {
    final String newText = _tags.join(", ");
    if (widget.controller.text != newText) {
      widget.controller.text = newText;
    }
  }

  void _addTag(String tag) {
    String cleanTag = tag.trim().toLowerCase();

    if (cleanTag.isNotEmpty && !_tags.contains(cleanTag)) {
      setState(() {
        _tags.add(cleanTag);
        _updateController();
      });
      _inputController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _updateController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: "Type tag and press Enter/Done",
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.label_outline),
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {
            _addTag(value);
          },
          onEditingComplete: () {
            _addTag(_inputController.text);
          },
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              _tags.map((tag) {
                return InputChip(
                  label: Text(tag),
                  deleteIcon: Icon(Icons.close, size: 18),
                  onDeleted: () => _removeTag(tag),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                );
              }).toList(),
        ),

        if (_tags.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              "No tags added yet.",
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
      ],
    );
  }
}
