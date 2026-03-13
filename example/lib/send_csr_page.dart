import 'package:flutter/material.dart';
import 'package:satusehat_isdk/satusehat_isdk.dart';

class SendCsrPage extends StatefulWidget {
  const SendCsrPage({super.key});

  @override
  State<SendCsrPage> createState() => _SendCsrPageState();
}

class _SendCsrPageState extends State<SendCsrPage> {
  final _generateCsr = GenerateCsr();
  bool _isLoading = true;
  String? _csr;

  Future<void> _getCsr() async {
    final csr = await _generateCsr.generateCsr(cnId: 'P1234567890');
    setState(() {
      _csr = csr;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCsr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kirim CSR')),
      body: Column(
        children: [
          if (_isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Text(
                    '$_csr',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
              ),
              child: Text('Submit CSR'),
            ),
          ),
        ],
      ),
    );
  }
}
