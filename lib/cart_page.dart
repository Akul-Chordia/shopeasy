import 'package:flutter/material.dart';
import 'package:shopeasy/home_page.dart';
import 'bills.dart';
import 'profile_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<String> _groceryList = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _groceryList.add(_controller.text);
        _controller.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _groceryList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Grocery List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter grocery item',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addItem,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _groceryList.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[800],
                    child: ListTile(
                      title: Text(
                        _groceryList[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
              child: Icon(Icons.shopping_cart, size: 22, color: Colors.white),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/cart');
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
