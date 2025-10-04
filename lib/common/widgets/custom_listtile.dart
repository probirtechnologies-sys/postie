import 'package:flutter/material.dart';

class TwitterStyleListTile extends StatelessWidget {
  final String userName;
  final String tweetText;
  final String time;
  final VoidCallback onTap;

  const TwitterStyleListTile({
    super.key,
    required this.userName,
    required this.tweetText,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text(tweetText),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
      trailing: IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
      onTap: onTap,
    );
  }
}
