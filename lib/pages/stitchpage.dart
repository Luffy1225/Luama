import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF122118),
      appBar: AppBar(
        backgroundColor: const Color(0xFF122118),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA1pxMsTlQZGXqvPKc2d9vBmf3MrnLXQV_wA_imhzxIZS9Pmxy81JTjZqjWiPSzY2aKesfsVvigGo7zWCqqloiKQK9UDdD5kMQ9hTCL1MRujva8df_xlN5GKmeuFlc3upt3TEVcmz-3bNnPlnHRHq5ii6zTJZ4JSyi90PN7lAVVlfAgYLPr8K4cj09dBez5GpJXwGHAuP3qggStGyyURjYfdGE4CWw_8UxwmgZuleho5RmJ0IlgTaFKi4HSLCdj2webq6CfDzi5Ic4N',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ethan Carter',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Edit profile',
                style: TextStyle(fontSize: 16, color: Color(0xFF96c5a9)),
              ),
              const SizedBox(height: 24),
              _buildInputField(label: 'Name', controller: nameController),
              _buildInputField(label: 'Email', controller: emailController),
              _buildInputField(label: 'IP', controller: ipController),
              _buildInputField(label: 'Port', controller: portController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38E07B),
                    foregroundColor: const Color(0xFF122118),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    // 儲存處理邏輯
                  },
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: const Color(0xFF264532),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Color(0xFF96c5a9)),
            ),
          ),
        ],
      ),
    );
  }
}
