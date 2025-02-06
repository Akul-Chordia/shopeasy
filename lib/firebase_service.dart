import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final DocumentReference billCounterRef =
      FirebaseFirestore.instance.collection('Counters').doc('bill_counter');

  // Stream that listens to real-time updates from Firestore
  Stream<List<CartItem>> getCartItems() {
    return _db.collection('Items')
        .snapshots() 
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItem.fromFirestore(doc.data()))
            .toList());
  }

  Stream<List<GroceryList>> getGroceryList() {
    return _db.collection('GroceryList')
        .snapshots() 
        .map((snapshot) => snapshot.docs
            .map((doc) => GroceryList.fromFirestore(doc.data()))
            .toList());
  }

  Future<int> getNextBillNo() async {
    return _db.runTransaction((transaction) async {
      DocumentSnapshot billCounterSnap = await transaction.get(billCounterRef);

      int currentBillNo = (billCounterSnap['bill_no'] as int) + 1;

      // Update the bill number
      transaction.update(billCounterRef, {'bill_no': currentBillNo});

      return currentBillNo;
    });
  }


  Future<void> markItemsAsPaid(String userId) async {
  int newBillNo = await getNextBillNo(); // Get next bill number

  QuerySnapshot snapshot = await _db
      .collection('Items')
      .where('UID', isEqualTo: userId)
      .where('isPaid', isEqualTo: false)
      .get();

  if (snapshot.docs.isEmpty) return; // No items to mark as paid

  WriteBatch batch = _db.batch(); // Use batch for efficiency

  for (var doc in snapshot.docs) {
    batch.update(doc.reference, {
      'isPaid': true,
      'bill_no': newBillNo,
    });
  }

  await batch.commit(); // Commit batch write to Firestore
}

}

class CartItem {
  final String name;
  final int quantity;
  final double price;
  final bool isPaid;
  final int bill_no;
  final String UID;

  CartItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.isPaid,
    required this.bill_no,
    required this.UID,
  });

  // Factory method to create a CartItem from Firestore document
  factory CartItem.fromFirestore(Map<String, dynamic> firestoreData) {
    return CartItem(
      name: firestoreData['item_name'],
      quantity: firestoreData['quantity'],
      price: firestoreData['price'].toDouble(),
      isPaid: firestoreData['isPaid'],
      bill_no: firestoreData['bill_no'],
      UID: firestoreData['UID'],
    );
  }
}

class GroceryList {
  final String UID;
  final String item;

  GroceryList({
    required this.UID,
    required this.item
  });

  factory GroceryList.fromFirestore(Map<String, dynamic> firestoreData) {
    return GroceryList(
      UID: firestoreData['UID'],
      item: firestoreData['item']
    );
  }
}
