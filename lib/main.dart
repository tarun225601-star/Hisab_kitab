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
      title: 'Hisab Kitab - Dark UI',
      // पूरा ऐप डार्क और बोल्ड थीम पर चलेगा
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.amber,
        useMaterial3: true,
      ),
      home: const CustomerListScreen(),
    );
  }
}

// 1. पहला पेज: डार्क और बोल्ड ग्राहकों की लिस्ट
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final List<Map<String, dynamic>> _customers = [
    {
      "name": "राजू (जट्टारी वाला)",
      "phone": "987654xxxx",
      "totalBalance": 700,
      "entries": [
        {"date": "18 Aug 2026", "desc": "2 किलो चीनी लिया", "type": "उधार", "amount": 500},
        {"date": "15 Aug 2026", "desc": "1 लीटर तेल लिया", "type": "उधार", "amount": 200},
      ]
    },
    {
      "name": "राजू (अलीगढ़ वाला)",
      "phone": "912345xxxx",
      "totalBalance": 1200,
      "entries": [
        {"date": "17 Aug 2026", "desc": "केले का क्रेट", "type": "उधार", "amount": 1200},
      ]
    },
  ];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "माइक दबाकर बोलिए...";

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
          "phone": "नया",
          "totalBalance": 500,
          "entries": [
            {"date": "आज", "desc": _spokenText, "type": "उधार", "amount": 500}
          ]
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HISAB KITAB (बहीखाता)', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 22)),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Column(
        children: [
          // वॉयस स्टेटस बॉक्स (चमकता हुआ)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber, width: 1.5),
            ),
            width: double.infinity,
            child: Column(
              children: [
                const Text("🎙️ वॉयस कमांड स्टेटस", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  _spokenText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("ग्राहकों के नाम (रजिस्टर):", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          // ग्राहकों की लिस्ट - मोटे और साफ़ अक्षरों में
          Expanded(
            child: ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                int balance = customer['totalBalance'];
                bool isUdhar = balance >= 0;

                return Card(
                  color: Colors.grey.shade900,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Text(customer['name'][0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                    // ग्राहक का नाम एकदम मोटा और बड़ा
                    title: Text(
                      customer['name'],
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      "पहचान: ${customer['phone']}",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    // अमाउंट मोटे अक्षरों में लाल या हरे रंग में
                    trailing: Text(
                      "₹$balance",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isUdhar ? Colors.redAccent : Colors.greenAccent,
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
      
      // नीचे बड़ा और चमकीला माइक बटन
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isListening ? _stopListening : _startListening,
        backgroundColor: _isListening ? Colors.red : Colors.amber,
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.black),
        label: Text(
          _isListening ? "सुन रहे हैं... रुकें" : "बोलकर नाम जोड़ें",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}

// 2. दूसरा पेज: अंदर का बहीखाता (डार्क और बोल्ड)
class CustomerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> customerData;

  const CustomerDetailScreen({super.key, required this.customerData});

  @override
  Widget build(BuildContext context) {
    List entries = customerData['entries'];

    return Scaffold(
      appBar: AppBar(
        title: Text(customerData['name'], style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Column(
        children: [
          // टोटल बैलेंस बॉक्स
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey.shade900,
            width: double.infinity,
            child: Column(
              children: [
                const Text("कुल बकाया हिसाब", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  "₹${customerData['totalBalance']}",
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.redAccent),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(14.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("लेन-देन का ब्योरा:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          
          // अंदर की एंट्रीज
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                var entry = entries[index];
                bool isJama = entry['type'] == 'जमा';

                return Card(
                  color: Colors.grey.shade900,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      isJama ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isJama ? Colors.greenAccent : Colors.redAccent,
                      size: 28,
                    ),
                    title: Text(
                      entry['desc'],
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      "तारीख: ${entry['date']}",
                      style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      "₹${entry['amount']}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isJama ? Colors.greenAccent : Colors.redAccent,
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
