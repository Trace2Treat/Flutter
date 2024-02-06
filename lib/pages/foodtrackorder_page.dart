import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../themes/app_colors.dart';
import '../services/transaction_service.dart';
import '../services/restaurant_service.dart';

class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({Key? key}) : super(key: key);

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  final TransactionService controller = TransactionService();
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> restaurant = [];

  int restaurantId = 0;

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} "
        "[${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}]";
    return formattedDate;
  }

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      await fetchTransactionData();
      await fetchRestaurantData();
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchTransactionData() async {
    try {      
      transactions = await controller.getTransaction();
      if (mounted) {
        setState(() {
          transactions = transactions;
          restaurantId = transactions[0]['restaurant_id'];
        });
      }
    } catch (e) {
      print('Error fetching transaction data: $e');
    }
  }

  Future<void> fetchRestaurantData() async {
    try {
      print('resto id $restaurantId');
      restaurant = await RestaurantService().getRestaurant(restaurantId);
      if (mounted) {
        setState(() {
          restaurant = restaurant;
        });
      }
    } catch (e) {
      print('Error fetching restaurant data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order'),
        centerTitle: true,
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : DraggableScrollableSheet(
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, -5),
                  ),
                ],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 26),
                child: ListView(
                controller: scrollController,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      restaurant[0]['logo'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restaurant[0]['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        'Dipesan pada ${formatDateTime(transactions[0]['created_at'])}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        transactions[0]['transaction_code'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                  SizedBox(height: 50),
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '20 Min',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            'Estimasi',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey
                            ),
                          ),
                        ],
                  ),
                  SizedBox(height: 50),
                  // tambahkan list pesanan detail disini
                  TimelineTile(
                    alignment: TimelineAlign.start,
                    lineXY: 0.3,
                    indicatorStyle: IndicatorStyle(
                      iconStyle: IconStyle(
                        color: Colors.white,
                        iconData: Icons.done,
                      ),
                      width: 20,
                      color: AppColors.secondary,
                      indicatorXY: 0.3,
                    ),
                    endChild: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Order telah diterima oleh Restoran', // default jika status pending
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  TimelineTile(
                    alignment: TimelineAlign.start,
                    lineXY: 0.3,
                    indicatorStyle: IndicatorStyle(
                      iconStyle: IconStyle(
                        color: Colors.white,
                        iconData: Icons.circle_outlined,
                      ),
                      width: 20,
                      color: AppColors.secondary,
                      indicatorXY: 0.3,
                    ),
                    endChild: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Restoran sedang menyiapkan pesanan', // jika status=preparing maka warna menjadi secondary
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  TimelineTile(
                    alignment: TimelineAlign.start,
                    lineXY: 0.3,
                    indicatorStyle: IndicatorStyle(
                      iconStyle: IconStyle(
                        color: Colors.white,
                        iconData: Icons.done,
                      ),
                      width: 20,
                      color: Colors.grey,
                      indicatorXY: 0.3,
                    ),
                    endChild: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Pesanan Anda telah jadi !', // jika status prepared  maka AppColors.secondary
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  TimelineTile(
                    alignment: TimelineAlign.start,
                    lineXY: 0.3,
                    indicatorStyle: IndicatorStyle(
                      iconStyle: IconStyle(
                        color: Colors.white,
                        iconData: Icons.done,
                      ),
                      width: 20,
                      color: Colors.grey,
                      indicatorXY: 0.3,
                    ),
                    endChild: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Koin berhasil ditukar !', // jika status success  maka AppColors.secondary
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.secondary,
                                backgroundImage:
                                    AssetImage('assets/avatar.jpg'),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(restaurant[0]['name']),
                          Text('Admin'),
                          //Text(transactions[0]['transaction_code'])
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          // Call admin
                        },
                        icon: Icon(Icons.phone, color: AppColors.secondary),
                      ),
                      IconButton(
                        onPressed: () {
                          // Chat with admin
                        },
                        icon: Icon(Icons.chat, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ],
              ),
            )
          );
        },
      ),
    );
  }
}