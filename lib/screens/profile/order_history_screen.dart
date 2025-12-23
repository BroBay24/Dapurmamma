import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final List<Map<String, dynamic>> orders = [
      {
        'id': '#ORD-8821',
        'date': '24 Dec 2025',
        'items': 'Bolu Kacang, Lapis Legit',
        'total': 'Rp 185.000',
        'status': 'Processing',
        'image': 'assets/icons/bolukacang.jpg',
      },
      {
        'id': '#ORD-8820',
        'date': '20 Dec 2025',
        'items': 'Brownies Kukus',
        'total': 'Rp 45.000',
        'status': 'Completed',
        'image': 'assets/icons/bolukacang.jpg',
      },
      {
        'id': '#ORD-8819',
        'date': '15 Dec 2025',
        'items': 'Bika Ambon',
        'total': 'Rp 65.000',
        'status': 'Cancelled',
        'image': 'assets/icons/bolukacang.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Order History',
          style: GoogleFonts.lobster(
            color: const Color(0xFF1E3A5F),
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    Color statusColor;
    Color statusBgColor;

    switch (order['status']) {
      case 'Processing':
        statusColor = const Color(0xFFE67E22);
        statusBgColor = const Color(0xFFE67E22).withOpacity(0.1);
        break;
      case 'Completed':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.1);
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.1);
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to Order Detail
             Navigator.pushNamed(context, '/order_detail');
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header: ID & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['id'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                    Text(
                      order['date'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                
                // Content: Image & Details
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage(order['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['items'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E3A5F),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['total'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE67E22),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Footer: Status & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                    if (order['status'] == 'Completed')
                      SizedBox(
                        height: 32,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE67E22)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            'Buy Again',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFE67E22),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
