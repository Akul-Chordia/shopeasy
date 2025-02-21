import 'package:flutter/material.dart';
import 'firebase_service.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'cart_page.dart'; 
import 'bills.dart';
import 'profile_page.dart';
import 'payments.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService(); // Create Firebase service instance

    String? userId = AuthService().getCurrentUserId();

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
                style: TextStyle(fontSize: 24, color: Colors.white),
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

                final unpaidCartItems = cartItems.where((item) => !item.isPaid).toList();

                final filteredCartItems = unpaidCartItems.where((item) => item.UID == userId).toList();


                final totalCost = filteredCartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
                final tax = totalCost * 0.18; // 18% tax
                final totalWithTax = totalCost + tax;

                

                return Column(
                  children: [
                    // List of cart items
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCartItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredCartItems[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 3.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 170,
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      '${item.quantity} x ${item.price}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 30),
                                  Text(
                                    'Rs ${(item.price*item.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, right: 16.0, left: 16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Now tax and totalWithTax are defined in the builder method
                            Text('Total:            Rs ${totalCost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 15)),
                            Text('Tax:                  Rs ${tax.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                            Text('----------------------------', style: const TextStyle(color: Colors.white, fontSize: 13)),
                            Text('Total: Rs ${totalWithTax.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Payments(totalWithTax: totalWithTax)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'PAY NOW',
                          style: TextStyle(color: Colors.white),
                        ),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }
}

