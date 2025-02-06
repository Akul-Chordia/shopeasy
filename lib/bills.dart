import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'auth_service.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();
    String? userId = AuthService().getCurrentUserId();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bills', style: const TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: _firebaseService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bills available.'));
          }

          // Group items by bill_no
          final items = snapshot.data!;
          final groupedBills = <int, List<CartItem>>{};

          for (var item in items) {
            if (item.isPaid && item.UID == userId) {
              groupedBills.putIfAbsent(item.bill_no, () => []).add(item);
            }
          }

          return ListView.builder(
            itemCount: groupedBills.keys.length,
            itemBuilder: (context, index) {
              final billNo = groupedBills.keys.elementAt(index);
              final billItems = groupedBills[billNo]!;

              // Calculate total for the bill
              final totalCost = billItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
              final totalCostwithtax = totalCost*1.18;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #$billNo', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8.0),
                      ...billItems.map((item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity} x ${item.name}', style: const TextStyle(color: Colors.white)),
                          Text('Rs ${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                        ],
                      )),
                      const SizedBox(height: 8.0),
                      Divider(color: Colors.white),
                      Text('Total: Rs ${totalCostwithtax.toStringAsFixed(2)} (inc tax)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 20), 
              child: Icon(Icons.home, size: 22, color: Colors.grey),
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
              child: Icon(Icons.receipt, size: 22, color: Colors.white),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/bills');
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