import 'package:flutter/material.dart';

class KeyValueList extends StatefulWidget {
  final List<MapEntry<String, String>> initialPairs;
  final ValueChanged<List<MapEntry<String, String>>> onChanged;

  const KeyValueList({super.key, required this.initialPairs, required this.onChanged});

  @override
  _KeyValueListState createState() => _KeyValueListState();
}

class _KeyValueListState extends State<KeyValueList> {
  List<MapEntry<TextEditingController, TextEditingController>> keyValuePairs = [];

  @override
  void initState() {
    super.initState();
    for (var pair in widget.initialPairs) {
      keyValuePairs.add(MapEntry(
        TextEditingController(),
        TextEditingController(),
      ));
    }
  }

  @override
  void dispose() {
    for (var pair in keyValuePairs) {
      pair.key.dispose();
      pair.value.dispose();
    }
    super.dispose();
  }

  void _addKeyValuePair() {
    setState(() {
      keyValuePairs.add(MapEntry(TextEditingController(), TextEditingController()));
    });
    _updateParent();
  }

  void _removeKeyValuePair(int index) {
    setState(() {
      keyValuePairs[index].key.dispose();
      keyValuePairs[index].value.dispose();
      keyValuePairs.removeAt(index);
    });
    _updateParent();
  }

  void _updateParent() {
    final pairs = keyValuePairs
        .map((pair) => MapEntry(pair.key.text, pair.value.text))
        .toList();
    widget.onChanged(pairs);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 50,
        maxHeight: 200
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: keyValuePairs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: keyValuePairs[index].key,
                    decoration: const InputDecoration(hintText: 'Key',border: OutlineInputBorder()),
                    onChanged: (value) => _updateParent(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: keyValuePairs[index].value,
                    decoration: const InputDecoration(hintText: 'Value',border: OutlineInputBorder()),
                    onChanged: (value) => _updateParent(),
                  ),
                ),
                const SizedBox(width: 10),
                if(index != keyValuePairs.length - 1)
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      _removeKeyValuePair(index);
                    },
                  ),
                if (index == keyValuePairs.length - 1)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addKeyValuePair,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}