import 'package:flutter/material.dart';
import 'firebase_service.dart';  // Import the service
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_page.dart'; 
import 'bills.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService(); // Create Firebase service instance

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'SHOPEASY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Current Cart',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CartItem>>(
              stream: _firebaseService.getCartItems(),  // Fetch items from Firebase in real-time
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No items in the cart.'));
                }

                // Data has arrived, build the list
                final cartItems = snapshot.data!;
                final totalCost = cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
                final tax = totalCost * 0.18; // 18% tax
                final totalWithTax = totalCost + tax;

                return Column(
                  children: [
                    // List of cart items
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                item.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Quantity: ${item.quantity}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 16.0, left: 16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Now tax and totalWithTax are defined in the builder method
                            Text('Tax: \$${tax.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                            Text('Total: \$${totalWithTax.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle payment action
                        },
                        child: const Text('PAY NOW'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 20), 
              child: Icon(Icons.home, size: 22, color: Colors.white),
            ),
            backgroundColor: Colors.black,
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Icon(Icons.shopping_cart, size: 22, color: Colors.grey),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Icon(Icons.receipt, size: 22, color: Colors.grey),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Icon(Icons.person, size: 22, color: Colors.grey),
            ),
            label: '',
          ),
        ],
        onTap: (index) {
          // Handle navigation based on the selected index
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BillsPage()),
              );
              break;
            case 3:
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => const Profile_page()),
              // );
              break;
          }
        },
      ),
    );
  }
}

