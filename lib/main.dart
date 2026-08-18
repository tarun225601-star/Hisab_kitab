import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const HisabKitabMasterApp());
}

class HisabKitabMasterApp extends StatelessWidget {
  const HisabKitabMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hisab Kitab Pro',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.amber,
        useMaterial3: true,
      ),
      home: const MasterLedgerScreen(),
    );
  }
}

// मुख्य लेजर स्क्रीन
class MasterLedgerScreen extends StatefulWidget {
  const MasterLedgerScreen({super.key});

  @override
  State<MasterLedgerScreen> createState() => _MasterLedgerScreenState();
}

class _MasterLedgerScreenState extends State<MasterLedgerScreen> {
  // ग्राहकों का पूरा डेटा बेस
  final List<Map<String, dynamic>> _ledgerCustomers = [
    {
      "id": 1,
      "name": "राजू (जट्टारी वाला)",
      "phone": "9876543210",
      "totalBalance": 1500,
      "status": "उधार",
      "entries": [
        {"date": "18 Aug 2026", "desc": "2 किलो चीनी और दाल", "type": "उधार", "amount": 1000},
        {"date": "10 Aug 2026", "desc": "नकद भुगतान मिला", "type": "जमा", "amount": 500},
        {"date": "01 Aug 2026", "desc": "किराना सामान", "type": "उधार", "amount": 1000},
      ]
    },
    {
      "id": 2,
      "name": "अमित कुमार (दुकान वाले)",
      "phone": "9123456789",
      "totalBalance": 3200,
      "status": "उधार",
      "entries": [
        {"date": "17 Aug 2026", "desc": "स्टॉक माल खरीदा", "type": "उधार", "amount": 3200},
      ]
    },
    {
      "id": 3,
      "name": "विकास शर्मा",
      "phone": "9988776655",
      "totalBalance": 0,
      "status": "चुक्ता",
      "entries": [
        {"date": "12 Aug 2026", "desc": "पुराना हिसाब चुकता", "type": "जमा", "amount": 1500},
      ]
    }
  ];

  late stt.SpeechToText _speechEngine;
  bool _isListeningNow = false;
  String _liveSpokenText = "माइक बटन दबाकर ग्राहक का नाम या हिसाब बोलें...";

  @override
  void initState() {
    super.initState();
    _speechEngine = stt.SpeechToText();
  }

  // वॉयस रिकॉर्डिंग शुरू करने के लिए
  void _initializeVoiceRecording() async {
    bool available = await _speechEngine.initialize(
      onStatus: (status) => print('Voice Status: $status'),
      onError: (error) => print('Voice Error: $error'),
    );

    if (available) {
      setState(() => _isListeningNow = true);
      _speechEngine.listen(
        onResult: (result) {
          setState(() {
            _liveSpokenText = result.recognizedWords;
          });
        },
      );
    }
  }

  // वॉयस रिकॉर्डिंग रोकने और नया खाता जोड़ने के लिए
  void _stopVoiceRecordingAndSave() {
    _speechEngine.stop();
    setState(() {
      _isListeningNow = false;
      if (_liveSpokenText.isNotEmpty && _liveSpokenText != "माइक बटन दबाकर ग्राहक का नाम या हिसाब बोलें...") {
        _ledgerCustomers.add({
          "id": _ledgerCustomers.length + 1,
          "name": _liveSpokenText,
          "phone": "वॉइस द्वारा जोड़ा गया",
          "totalBalance": 500,
          "status": "उधार",
          "entries": [
            {"date": "आज", "desc": "वॉयस कमांड एंट्री: $_liveSpokenText", "type": "उधार", "amount": 500}
          ]
        });
        _liveSpokenText = "नया खाता सफलतापूर्वक जुड़ गया!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // कुल लेन-देन का हिसाब लगाना
    int totalMarketUdhar = 0;
    for (var cust in _ledgerCustomers) {
      totalMarketUdhar += (cust['totalBalance'] as int);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HISAB KITAB PRO (बहीखाता)',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1.1),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 4,
      ),
      body: Column(
        children: [
          // डैशबोर्ड समरी कार्ड (मार्केट का कुल बकाया)
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade900, Colors.grey.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade700, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("मार्केट में कुल बकाया", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text("कुल लेन-देन खाता", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
                Text(
                  "₹$totalMarketUdhar",
                  style: const TextStyle(color: Colors.redAccent, fontSize: 26, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),

          // वॉयस स्टेटस लाइव बॉक्स
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey, width: 1),
            ),
            width: double.infinity,
            child: Row(
              children: [
                Icon(Icons.mic, color: _isListeningNow ? Colors.red : Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _liveSpokenText,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("सभी ग्राहकों की सूची (Registers):", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),

          // ग्राहकों की लंबी लिस्ट
          Expanded(
            child: ListView.builder(
              itemCount: _ledgerCustomers.length,
              itemBuilder: (context, index) {
                final customer = _ledgerCustomers[index];
                int balance = customer['totalBalance'];

                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber,
                      radius: 24,
                      child: Text(
                        customer['name'][0],
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ),
                    title: Text(
                      customer['name'],
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "मोबाइल: ${customer['phone']}",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹$balance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: balance > 0 ? Colors.redAccent : Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          balance > 0 ? "बाकी है" : "हिसाब चुकता",
                          style: TextStyle(fontSize: 12, color: balance > 0 ? Colors.red.shade300 : Colors.green.shade300, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedLedgerView(customerInfo: customer),
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

      // नीचे वॉयस कमांड फ्लोटिंग बटन
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isListeningNow ? _stopVoiceRecordingAndSave : _initializeVoiceRecording,
        backgroundColor: _isListeningNow ? Colors.red : Colors.amber,
        icon: Icon(_isListeningNow ? Icons.mic : Icons.mic_none, color: Colors.black, size: 26),
        label: Text(
          _isListeningNow ? "सुन रहे हैं... बंद करें" : "बोलकर नया खाता जोड़ें",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}

// ग्राहक का पूरा खाता और लेन-देन देखने की स्क्रीन
class DetailedLedgerView extends StatelessWidget {
  final Map<String, dynamic> customerInfo;

  const DetailedLedgerView({super.key, required this.customerInfo});

  @override
  Widget build(BuildContext context) {
    List transactionEntries = customerInfo['entries'];

    return Scaffold(
      appBar: AppBar(
        title: Text(customerInfo['name'], style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFF1F1F1F),
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Column(
        children: [
          // टॉप बैलेंस कार्ड
          Container(
            padding: const EdgeInsets.all(22),
            color: const Color(0xFF1E1E1E),
            width: double.infinity,
            child: Column(
              children: [
                const Text("खाते का कुल बकाया बैलेंस", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  "₹${customerInfo['totalBalance']}",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.redAccent),
                ),
                const SizedBox(height: 4),
                Text(
                  "मोबाइल नंबर: ${customerInfo['phone']}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("इस खाते के सभी लेन-देन:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          // लेन-देन की सूची
          Expanded(
            child: ListView.builder(
              itemCount: transactionEntries.length,
              itemBuilder: (context, index) {
                var item = transactionEntries[index];
                bool isDeposit = item['type'] == 'जमा';

                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDeposit ? Colors.green.shade900 : Colors.red.shade900,
                      child: Icon(
                        isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isDeposit ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    title: Text(
                      item['desc'],
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      "तारीख: ${item['date']}",
                      style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    trailing: Text(
                      "₹${item['amount']}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDeposit ? Colors.greenAccent : Colors.redAccent,
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
