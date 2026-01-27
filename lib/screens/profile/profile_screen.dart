import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userRepo = UserRepository();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userRepo.getUserStream(),
      builder: (context, snapshot) {
        // Default values
        String userName = _auth.currentUser?.displayName ?? "User";
        String userEmail = _auth.currentUser?.email ?? "email@example.com";
        String? photoUrl = _auth.currentUser?.photoURL;
        
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          if (data != null) {
            userName = data['name'] ?? userName;
            userEmail = data['email'] ?? userEmail;
            photoUrl = data['photoUrl'] ?? photoUrl;
          }
        }

        final body = _buildBody(context, userName, userEmail, photoUrl);
        
        if (widget.embedded) {
          return Container(
            color: Colors.grey[50],
            child: Column(
              children: [
                _buildEmbeddedHeader(),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'My Profile',
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
          body: body,
        );
      },
    );
  }

  Widget _buildEmbeddedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'My Profile',
          style: GoogleFonts.lobster(
            color: const Color(0xFF1E3A5F),
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String userName, String userEmail, String? photoUrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 1. Profile Header
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE67E22), // Orange border
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : const AssetImage('assets/icons/bolukacang.jpg') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
                Text(
                  userEmail,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2. Menu Options
          _buildProfileMenu(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.pushNamed(
                context,
                '/edit_profile',
                arguments: {
                  'name': userName,
                  'email': userEmail,
                  'photoUrl': photoUrl,
                },
              );
            },
          ),
          _buildProfileMenu(
            icon: Icons.history,
            title: 'Order History',
            onTap: () => Navigator.pushNamed(context, '/order_history'),
          ),

          const SizedBox(height: 20),

          // 3. Logout Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              onPressed: () {
                // Tampilkan dialog konfirmasi logout
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Tutup dialog
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          }
                        },
                        child: Text('Logout', style: GoogleFonts.poppins(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
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
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1E3A5F), size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E3A5F),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
