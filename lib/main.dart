import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const ViziagKhataApp());
}

class ViziagKhataApp extends StatelessWidget {
  const ViziagKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Viziag Khata',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const KhataHomePage(),
    );
  }
}

class KhataHomePage extends StatefulWidget {
  const KhataHomePage({super.key});

  @override
  State<KhataHomePage> createState() => _KhataHomePageState();
}

class _KhataHomePageState extends State<KhataHomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _textSpoken = "माइक दबाकर बोलिए (जैसे: राजू को 200 दिए)";
  
  final List<Map<String, dynamic>> _khataList = [
    {"name": "राजू", "amount": 500, "type": "उधार"},
    {"name": "सोहन", "amount": 200, "type": "जमा"},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('status: $val'),
        onError: (val) => print('error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textSpoken = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _addKhataFromVoice(_textSpoken);
    }
  }

  void _addKhataFromVoice(String speechText) {
    if (speechText.isNotEmpty && speechText != "माइक दबाकर बोलिए (जैसे: राजू को 200 दिए)") {
      setState(() {
        _khataList.add({"name": "वॉयस एंट्री", "amount": 100, "type": speechText});
        _textSpoken = "जोड़ दिया गया: $speechText";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viziag Voice Khata'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.indigo.shade50,
            width: double.infinity,
            child: Text(
              _textSpoken,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _khataList.length,
              itemBuilder: (context, index) {
                final item = _khataList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item['type'] == 'जमा' ? Colors.green : Colors.red,
                      child: Icon(item['type'] == 'जमा' ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
                    ),
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("विवरण: ${item['type']}"),
                    trailing: Text(
                      "₹${item['amount']}",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: item['type'] == 'जमा' ? Colors.green : Colors.red
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _listen,
        backgroundColor: _isListening ? Colors.red : Colors.indigo,
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
        label: Text(_isListening ? "सुन रहे हैं... बोलिए..." : "बोलकर हिसाब जोड़ें"),
      ),
    );
  }
}
