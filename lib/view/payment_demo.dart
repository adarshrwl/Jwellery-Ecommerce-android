import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'PaymentSuccess.dart';

class PaymentDemoPage extends StatefulWidget {
  const PaymentDemoPage({Key? key}) : super(key: key);

  @override
  _PaymentDemoPageState createState() => _PaymentDemoPageState();
}

class _PaymentDemoPageState extends State<PaymentDemoPage> {
  String? clientSecret;
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePaymentSheet();
  }

  Future<void> _initializePaymentSheet() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        setState(() {
          errorMessage = 'Please log in to proceed with payment.';
          isLoading = false;
        });
        return;
      }

      // Fetch cart total (example: assume total is stored or fetched from /api/cart)
      final cartResponse = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (cartResponse.statusCode == 200) {
        final cartData = jsonDecode(cartResponse.body);
        final total = (cartData['items'] as List).fold(
            0.0,
            (sum, item) =>
                sum + (item['price'] as num) * (item['quantity'] as num));
        final paymentAmount =
            (total * 100).toInt(); // Convert to smallest unit (paise)

        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/create-payment-intent'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'amount': paymentAmount}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            clientSecret = data['clientSecret'];
            isLoading = false;
          });
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret!,
              merchantDisplayName: 'Your Store',
              customerId:
                  'customer_id', // Optional: Fetch from backend if needed
              customerEphemeralKeySecret:
                  'ephemeral_key', // Optional: Fetch from backend
            ),
          );
        } else {
          setState(() {
            errorMessage = 'Failed to initialize payment.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch cart details.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _openPaymentSheet() async {
    try {
      setState(() => isLoading = true);
      await Stripe.instance.presentPaymentSheet();
      setState(() {
        errorMessage = 'Payment succeeded! Redirecting...';
        isLoading = false;
      });
      // Navigate to PaymentSuccess page after a delay
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaymentSuccessPage()),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Payment failed: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Demo'),
        backgroundColor: Colors.brown,
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (errorMessage!.contains('succeeded'))
                          ElevatedButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PaymentSuccessPage()),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Go to Success Page',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Demo Payment Checkout',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 16),
                        if (clientSecret == null)
                          const CircularProgressIndicator()
                        else
                          ElevatedButton(
                            onPressed: _openPaymentSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Pay Now',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
