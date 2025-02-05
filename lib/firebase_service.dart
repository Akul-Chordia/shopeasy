import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream that listens to real-time updates from Firestore
  Stream<List<CartItem>> getCartItems() {
    return _db.collection('Items')
        .snapshots() 
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItem.fromFirestore(doc.data()))
            .toList());
  }
}

class CartItem {
  final String name;
  final int quantity;
  final double price;

  CartItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  // Factory method to create a CartItem from Firestore document
  factory CartItem.fromFirestore(Map<String, dynamic> firestoreData) {
    return CartItem(
      name: firestoreData['item_name'],
      quantity: firestoreData['quantity'],
      price: firestoreData['price'].toDouble(),
    );
  }
}
