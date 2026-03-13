import 'package:flutter/material.dart';
import 'package:satusehat_isdk_example/send_csr_page.dart';
import 'package:satusehat_isdk_example/sign_provisioning.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RSWS TTE')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SendCsrPage()),
              ),
              backgroundColor: Colors.blue,
              label: 'Kirim CSR',
            ),
            SizedBox(height: 32),
            CustomButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SignProvisioning()),
              ),
              backgroundColor: Colors.green,
              label: 'Sign Provisioning',
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.label,
    this.minimumSize,
  });

  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final String? label;
  final Size? minimumSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: minimumSize ?? Size(double.infinity, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(32),
        ),
      ),
      child: Text('$label'),
    );
  }
}
