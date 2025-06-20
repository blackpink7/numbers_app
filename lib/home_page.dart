import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedType = 'trivia';
  final TextEditingController _numberController = TextEditingController();
  bool _isRandom = false;
  String _result = '';

  Future<void> _fetchFact() async {
    final number = _isRandom ? 'random' : _numberController.text;
    final type = _selectedType;

    if (!_isRandom && number.isEmpty) {
      _showError('Number must not be empty.');
      return;
    }

    if (!_isRandom && int.tryParse(number) == null) {
      _showError('Only digits are allowed.');
      return;
    }

    try {
      debugPrint('Fetching fact for number: $number, type: $type');
      final url = Uri.parse('http://numbersapi.com/$number/$type');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        debugPrint('Response received: ${response.body}');
        setState(() {
          _result = response.body;
        });
        _showResultDialog(response.body);
      } else {
        _showError('Error fetching data.');
      }
    } catch (e) {
      _showError('No internet connection.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Result'),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () => _saveFact(result),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFact(String fact) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_facts') ?? [];
    saved.add(fact);
    await prefs.setStringList('saved_facts', saved);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fact type:', style: TextStyle(fontSize: 16)),
          DropdownButton<String>(
            value: _selectedType,
            onChanged: (value) => setState(() => _selectedType = value!),
            items: ['trivia', 'math', 'date', 'year']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
          Row(
            children: [
              Checkbox(
                value: _isRandom,
                onChanged: (val) => setState(() => _isRandom = val!),
              ),
              Text('Random number')
            ],
          ),
          if (!_isRandom)
            TextField(
              controller: _numberController,
              decoration: InputDecoration(labelText: 'Enter a number'),
              keyboardType: TextInputType.number,
            ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _fetchFact,
              icon: Icon(Icons.search),
              label: Text('Get Fact'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }
}