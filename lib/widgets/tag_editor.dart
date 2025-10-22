import 'package:flutter/material.dart';

class _TagEditorDialog extends StatefulWidget {
  final List<String> currentTags;
  final List<String> availableTags;

  const _TagEditorDialog({
    required this.currentTags,
    required this.availableTags,
  });

  @override
  State<_TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<_TagEditorDialog> {
  late List<String> _selectedTags;
  final TextEditingController _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.currentTags);
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _addNewTag() {
    final tag = _newTagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
      _newTagController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDisplayTags =
        {
          ...widget.availableTags.map((t) => t.toLowerCase()),
          ..._selectedTags,
        }.toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                "Tags",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(_selectedTags),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              ),
            ],
          ),
          const Divider(),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                allDisplayTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return ActionChip(
                    label: Text("#$tag"),
                    backgroundColor:
                        isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surface,
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => _toggleTag(tag),
                  );
                }).toList(),
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller: _newTagController,
            decoration: InputDecoration(
              hintText: "New tag",
              prefixText: "# ",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value) => _addNewTag(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class TagEditor extends StatefulWidget {
  final TextEditingController controller;
  final List<String> availableTags;

  const TagEditor({
    super.key,
    required this.controller,
    this.availableTags = const [],
  });

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  List<String> _currentTags = [];

  @override
  void initState() {
    super.initState();
    _initializeTags(widget.controller.text);
    widget.controller.addListener(_syncTagsFormController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncTagsFormController);
    super.dispose();
  }

  void _initializeTags(String text) {
    if (text.isNotEmpty) {
      _currentTags =
          text
              .split(",")
              .map((tag) => tag.trim().toLowerCase())
              .where((tag) => tag.isNotEmpty)
              .toList();
    } else {
      _currentTags = [];
    }
  }

  void _syncTagsFormController() {
    setState(() {
      _initializeTags(widget.controller.text);
    });
  }

  void _openTagEditorDialog() async {
    final newTags = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _TagEditorDialog(
          currentTags: _currentTags,
          availableTags: widget.availableTags,
        );
      },
    );

    if (newTags != null && mounted) {
      final newText = newTags.join(", ");
      widget.controller.text = newText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: _openTagEditorDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.label_outline, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Tags",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  _currentTags.isEmpty
                      ? const Icon(Icons.add)
                      : const Icon(Icons.edit),
                ],
              ),
              if (_currentTags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children:
                        _currentTags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                          );
                        }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
