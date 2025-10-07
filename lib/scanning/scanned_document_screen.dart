import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_scan_flutter/scanning/document_state.dart';

import '../utils/route.dart';

class ScannedDocumentScreen extends StatefulWidget {
  // final Uint8List scannedImageBytes;
  final DocumentState document;

  const ScannedDocumentScreen({super.key, required this.document});

  @override
  State<ScannedDocumentScreen> createState() => _ScannedDocumentScreenState();
}

class _ScannedDocumentScreenState extends State<ScannedDocumentScreen> {
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    _titleController.text = widget.document.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.document,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Consumer<DocumentState>(
            builder: (context, value, child) {
              return GestureDetector(
                child: Text(value.title, style: TextStyle(color: Colors.white)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Document Title"),
                        content: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: "Enter document title",
                          ),
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.document.setTitle(_titleController.text);
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<DocumentState>(
          builder: (context, value, child) {
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child:
                          widget.document.currentPage != null
                              ? Image.memory(
                                widget.document.currentPage!,
                                fit: BoxFit.contain,
                              )
                              : SizedBox(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed:
                            value.currentPageIndex == 0
                                ? null
                                : value.goToPreviousPage,
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color:
                              value.currentPageIndex == 0
                                  ? Colors.grey
                                  : Colors.white,
                        ),
                      ),
                      Text(
                        value.pageNumberText,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed:
                            value.currentPageIndex == value.pageCount - 1
                                ? null
                                : value.goToNextPage,
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color:
                              value.currentPageIndex == value.pageCount - 1
                                  ? Colors.grey
                                  : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            ROUTE_SCAN,
                            arguments: {"isFirstPage": false},
                          ).then((result) {
                            if (result is Uint8List) {
                              value.addPage(result);
                            }
                          });
                        },
                        child: Text("Keep Scanning"),
                      ),
                      ElevatedButton(onPressed: () {}, child: Text("Done")),
                    ],
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
