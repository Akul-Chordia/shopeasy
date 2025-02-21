import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'auth_service.dart';
import 'firebase_service.dart';

class Payments extends StatefulWidget {
  final double totalWithTax;

  const Payments({Key? key, required this.totalWithTax}) : super(key: key);

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment() async {
  try {

    String? userId = AuthService().getCurrentUserId();

    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
      return;
    }

    FirebaseService firebaseService = FirebaseService();



    paymentIntent = await createPaymentIntent('${widget.totalWithTax.toStringAsFixed(2)}', 'USD');

    // Initialize Payment Sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!['client_secret'],
        merchantDisplayName: 'ShopEasy',
      ),
    );

    // Present Payment Sheet
    await Stripe.instance.presentPaymentSheet();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful!")),
    );

    await firebaseService.markItemsAsPaid(userId);

    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  } catch (e) {
    print("Payment failed: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Failed")),
    );
  }
}


  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_XXXXXXXX-YOU-API-KEY',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (double.parse(amount) * 100).toInt().toString(), // Convert to cents
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      print("Error creating payment intent: $e");
      throw Exception(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Payments',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: makePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'PAY WITH STRIPE',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

