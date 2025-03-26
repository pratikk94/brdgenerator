import 'package:flutter/material.dart';
import '../widgets/section_content.dart';

class DocumentDetailScreen extends StatelessWidget {
  final String title;
  final Map<String, dynamic> content;

  const DocumentDetailScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.split('. ')[1]), // Remove the number prefix for cleaner title
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              // TODO: Implement export/download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Export feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SectionContent(title: title, content: content),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          // TODO: Implement edit functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Edit feature coming soon!')),
          );
        },
      ),
    );
  }
} 