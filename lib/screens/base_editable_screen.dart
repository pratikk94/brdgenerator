import 'package:flutter/material.dart';

class BaseEditableScreen extends StatefulWidget {
  final String title;
  final Map<String, dynamic> initialData;
  final String heroTag;

  const BaseEditableScreen({
    Key? key,
    required this.title,
    required this.initialData,
    required this.heroTag,
  }) : super(key: key);

  @override
  _BaseEditableScreenState createState() => _BaseEditableScreenState();
}

class _BaseEditableScreenState extends State<BaseEditableScreen> {
  late Map<String, dynamic> _data;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _data = Map.from(widget.initialData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Changes saved!')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Hero(
        tag: widget.heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.withOpacity(0.1), Colors.white],
                stops: [0.0, 0.2],
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _isEditing
                    ? _buildEditableContent()
                    : _buildReadOnlyContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _data.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 6, top: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade100, Colors.indigo.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildContentWidget(entry.value),
            SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEditableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _data.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            _buildEditableField(entry.key, entry.value),
            SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildContentWidget(dynamic content) {
    if (content is String) {
      return Padding(
        padding: EdgeInsets.only(left: 12),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    } else if (content is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.map((item) {
          return Padding(
            padding: EdgeInsets.only(left: 12, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: 8,
                  margin: EdgeInsets.only(top: 8, right: 8),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (content is Map) {
      return Padding(
        padding: EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content.entries.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.key,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.value.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildEditableField(String key, dynamic value) {
    if (value is String) {
      return TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          hintText: 'Enter $key',
        ),
        maxLines: value.length > 100 ? 5 : 1,
        onChanged: (newValue) {
          setState(() {
            _data[key] = newValue;
          });
        },
      );
    } else if (value is List) {
      return Column(
        children: [
          ...List.generate(value.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: value[index],
                      decoration: InputDecoration(
                        hintText: 'Item ${index + 1}',
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          value[index] = newValue;
                          _data[key] = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        value.removeAt(index);
                        _data[key] = value;
                      });
                    },
                  ),
                ],
              ),
            );
          }),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add Item'),
            onPressed: () {
              setState(() {
                value.add('New item');
                _data[key] = value;
              });
            },
          ),
        ],
      );
    } else if (value is Map) {
      return Column(
        children: [
          ...value.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  TextFormField(
                    initialValue: entry.value.toString(),
                    decoration: InputDecoration(
                      hintText: 'Enter value',
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        value[entry.key] = newValue;
                        _data[key] = value;
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }
    return SizedBox.shrink();
  }
} 