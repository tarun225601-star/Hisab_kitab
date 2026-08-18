import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const HisabKitabApp());
}

class HisabKitabApp extends StatelessWidget {
  const HisabKitabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hisab Kitab',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const CustomerListScreen(),
    );
  }
}

// 1. पहला पेज: ग्राहकों की लिस्ट (पहचान/पता और मोबाइल नंबर के साथ)
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  // ग्राहकों की लिस्ट जिसमें नाम के आगे पहचान/इलाका जोड़ा गया है ताकि गड़बड़ न हो
  final List<Map<String, dynamic>> _customers = [
    {
      "name": "राजू (अलीगढ़ वाला)",
      "phone": "987654xxxx",
      "totalBalance": 500,
      "entries": [
        {"date": "18 Aug 2026", "desc": "2 पेटी सेब लिया", "type": "उधार", "amount": 500},
      ]
    },
    {
      "name": "राजू (झांसी वाला)",
      "phone": "912345xxxx",
      "totalBalance": 1200,
      "entries": [
        {"date": "17 Aug 2026", "desc": "केले का क्रेट", "type": "उधार", "amount": 1200},
      ]
    },
    {
      "name": "सोहन गुप्ता",
      "phone": "998877xxxx",
      "totalBalance": -300,
      "entries": [
        {"date": "16 Aug 2026", "desc": "नकद एडवांस जमा", "type": "जमा", "amount": 300},
      ]
    },
  ];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "माइक दबाकर बोलिए (जैसे: राजू अलीगढ़ को 200 दिए)";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      if (_spokenText.isNotEmpty) {
        _customers.add({
          "name": _spokenText,
          "phone": "नया नंबर",
          "totalBalance": 100,
          "entries": [
            {"date": "आज", "desc": "वॉयस एंट्री", "type": "उधार", "amount": 100}
          ]
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('खाता बुक (पक्की पहचान)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.indigo.shade50,
            width: double.infinity,
            child: Text(
              "वॉयस कमांड: $_spokenText",
              style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                int balance = customer['totalBalance'];
                bool isUdhar = balance >= 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(customer['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ),
                    // यहाँ नाम के साथ उसकी पहचान (जैसे शहर या दुकान का नाम) साफ़ दिखेगा
                    title: Text(customer['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text("मोबाइल/पहचान: ${customer['phone']}"),
                    trailing: Text(
                      isUdhar ? "लेने हैं ₹$balance" : "देने हैं ₹${balance.abs()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUdhar ? Colors.red : Colors.green,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDetailScreen(customerData: customer),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isListening ? _stopListening : _startListening,
        backgroundColor: _isListening ? Colors.red : Colors.indigo,
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
        label: Text(_isListening ? "सुन रहे हैं... रुकें" : "बोलकर नाम जोड़ें", style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

// 2. दूसरा पेज: ग्राहक का पूरा अंदर का बहीखाता
class CustomerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> customerData;

  const CustomerDetailScreen({super.key, required this.customerData});

  @override
  Widget build(BuildContext context) {
    List entries = customerData['entries'];

    return Scaffold(
      appBar: AppBar(
        title: Text(customerData['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.indigo.shade50,
            width: double.infinity,
            child: Column(
              children: [
                const Text("कुल बकाया हिसाब", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(
                  "₹${customerData['totalBalance']}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("लेन-देन का इतिहास:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                var entry = entries[index];
                bool isJama = entry['type'] == 'जमा';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      isJama ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isJama ? Colors.green : Colors.red,
                    ),
                    title: Text(entry['desc'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("तारीख: ${entry['date']}"),
                    trailing: Text(
                      "₹${entry['amount']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isJama ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
