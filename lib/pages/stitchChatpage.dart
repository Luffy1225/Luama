import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      messages.add({
        "name": "Ethan",
        "message": _controller.text.trim(),
        "isSender": false,
        "avatar":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuBBehSQ0BVxalXC-LnXRvM5RR04nO3Tl_cRDhzcB-ztru249Q0leN-J6DI6YmtUbzkJXC1BGOwIQtD7RVynp5vIl12Zzv1nIPo_daLRK8z-mn4CPwqSQof6GGOnjkvZ2q0TtqLV08aiFr60ONed0eV2tp2cHycCh8ePXswML0XOB6Cr8goTGBpjI9A6W1gq40rd5CRwYHmbNxI8-za19NUVvq1xYng0fKSWicfHMgGgnmbCRBAKxxaA-O2604Q4ESpvy_agfysjVjwE",
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 頂部導覽列
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: Color(0xFF121714)),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Ethan',
                        style: TextStyle(
                          color: Color(0xFF121714),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.videocam, color: Color(0xFF121714)),
                ],
              ),
            ),

            const Text(
              'Today 10:30 AM',
              style: TextStyle(
                color: Color(0xFF688272),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 聊天訊息列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _chatBubble(
                    name: "Sophia",
                    message:
                        "Hey Ethan, are you still up for the movie tonight?",
                    isSender: true,
                    avatarUrl:
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuB0NDoh9uyWemrItrMIqmxBpLwT2RqSv2NtjYhF4D9iDX1J75gULkNDMYjV6JJ-dR7s0xtmnUfPAR1wyWBiaqI2-NyALX6d_Owu5fV45R7gk8X13WZIi58Sv1Yc7LTODGKkbeoUkRNZIYFmaDSKhbqr56TLLtMRLZ8cNoRSxGT9lGeG_FAbKhinM6plhfiuJKqztkSskWeNFBoQbLJQ22wRvdsa3T8kwXpD6gjIOzPzZIbSkxixfBNAo1W7Dr5TsnZ8EJxIOb34Bxzi",
                  ),
                  _chatBubble(
                    name: "Ethan",
                    message: "Absolutely, Sophia! What time are we thinking?",
                    isSender: false,
                    avatarUrl:
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuBBehSQ0BVxalXC-LnXRvM5RR04nO3Tl_cRDhzcB-ztru249Q0leN-J6DI6YmtUbzkJXC1BGOwIQtD7RVynp5vIl12Zzv1nIPo_daLRK8z-mn4CPwqSQof6GGOnjkvZ2q0TtqLV08aiFr60ONed0eV2tp2cHycCh8ePXswML0XOB6Cr8goTGBpjI9A6W1gq40rd5CRwYHmbNxI8-za19NUVvq1xYng0fKSWicfHMgGgnmbCRBAKxxaA-O2604Q4ESpvy_agfysjVjwE",
                  ),
                  _chatBubble(
                    name: "Sophia",
                    message: "How about 7 PM? We can grab dinner beforehand.",
                    isSender: true,
                    avatarUrl:
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuCiV-AzpUtLjW9WGQW1PTrtj9fU_GB_HFPQrSfmdYx61rUF1_FDsu2zDUtBHGyygjC309I17vm1WjiEndszrtkuyTKqusNeKFzGA21zekm3rDHOby0ouHWxOpG38oO7zFVvFlL8R9a494A8vSmOBa6rpBFjPOWne-LVDPuaMz_QkE_ZegmVpoK5fVQjcaCk_f5lc7LOz1ev5jigm9x1gMCnmBOpwd7tY4xxK_ljWwZMeBFNw3pAn83rrCskOLVCU-RlvLqVsZ7sY4fy",
                  ),
                  for (var msg in messages)
                    _chatBubble(
                      name: msg['name'],
                      message: msg['message'],
                      isSender: msg['isSender'],
                      avatarUrl: msg['avatar'],
                    ),
                ],
              ),
            ),

            // 輸入框區域
            Container(
              color: const Color(0xFFF1F4F2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF121714),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble({
    required String name,
    required String message,
    required bool isSender,
    required String avatarUrl,
  }) {
    final alignment =
        isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor =
        isSender ? const Color(0xFF94e0b1) : const Color(0xFFF1F4F2);
    final textColor = const Color(0xFF121714);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSender)
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: alignment,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 13, color: Color(0xFF688272)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(message, style: TextStyle(color: textColor)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (isSender)
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
        ],
      ),
    );
  }
}
