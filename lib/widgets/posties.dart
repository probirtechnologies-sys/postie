import 'package:flutter/material.dart';

class FeedBody extends StatelessWidget {
  const FeedBody({super.key});

  // Sample user data
  final List<Map<String, dynamic>> stories = const [
    {"name": "Sophia Carter"},
    {"name": "Ethan Bennett"},
    {"name": "Olivia Hayes"},
    {"name": "Noah Thompson"},
  ];

  final List<Map<String, dynamic>> trending = const [
    {
      "title": "#TechConference2024",
      "subtitle": "Trending in Your Country",
      "posts": "12.5k posts",
    },
    {
      "title": "#NewAlbumDrop",
      "subtitle": "Pop Culture · Trending",
      "posts": "45.2k posts",
    },
    {
      "title": "#ChampionsLeagueFinal",
      "subtitle": "Sports · Trending",
      "posts": "88.1k posts",
    },
  ];

  final List<Map<String, dynamic>> feedPosts = const [
    {
      "name": "Liam Carter",
      "username": "@liamcarter",
      "time": "2h",
      "content":
          "Just finished a great workout! Feeling energized and ready to tackle the day. #fitness #healthylifestyle",
      "likes": 12,
      "comments": 2,
      "shares": 5,
    },
    {
      "name": "Olivia Bennett",
      "username": "@oliviab",
      "time": "4h",
      "content":
          "Enjoying a quiet morning with a cup of coffee and a good book. What's your favorite way to relax? #reading #coffeelover",
      "likes": 25,
      "comments": 1,
      "shares": 8,
    },
    {
      "name": "Noah Thompson",
      "username": "@noahthompson",
      "time": "6h",
      "content":
          "Excited to announce that I'll be speaking at the upcoming tech conference! More details to come soon. #tech #conference",
      "likes": 38,
      "comments": 3,
      "shares": 11,
    },
  ];

  // Helper to get initials
  String getInitials(String name) {
    final parts = name.split(" ");
    if (parts.length > 1) {
      return parts[0][0] + parts[1][0];
    } else if (parts.isNotEmpty) {
      return parts[0][0];
    }
    return "?";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const Spacer(),
              const Text(
                "Postie", // Title changed from Feed to Postie
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.settings, color: Colors.black),
            ],
          ),
        ),

        // Stories Row
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: const [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Your Story",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                );
              }
              final story = stories[index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.yellow,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey[800],
                        child: Text(
                          getInitials(story["name"]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story["name"].split(" ")[0],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Feed body scrollable
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // What's Happening
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text(
                    "What's Happening",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...trending.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["subtitle"],
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item["title"],
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item["posts"],
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(color: Colors.black26, thickness: 0.5),

                // Feed Posts
                ...feedPosts.map((post) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[800],
                              child: Text(
                                getInitials(post["name"]),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post["name"],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "${post["username"]} · ${post["time"]}",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post["content"],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _iconWithText(
                              Icons.favorite_border,
                              post["likes"].toString(),
                            ),
                            _iconWithText(
                              Icons.mode_comment_outlined,
                              post["comments"].toString(),
                            ),
                            _iconWithText(
                              Icons.repeat,
                              post["shares"].toString(),
                            ),
                            const Icon(
                              Icons.share_outlined,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.black26, thickness: 0.5),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // helper
  Widget _iconWithText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 20),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }
}
