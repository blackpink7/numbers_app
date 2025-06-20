import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedFactsPage extends StatelessWidget {
  const SavedFactsPage({super.key});

  Future<List<String>> _getSavedFacts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('saved_facts') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getSavedFacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final facts = snapshot.data ?? [];
        if (facts.isEmpty) {
          return Center(child: Text('No saved facts yet.'));
        }
        return ListView.separated(
          padding: EdgeInsets.all(12),
          itemCount: facts.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (context, index) => ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(facts[index]),
          ),
        );
      },
    );
  }
}