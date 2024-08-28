import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hotel_finde_hotel/core/storage/shared/shared_pref.dart';
import 'package:hotel_finde_hotel/feature/room/addroom.dart';
import 'package:hotel_finde_hotel/feature/room/editroom.dart';
import 'package:http/http.dart' as http;

class MyRoomScreen extends StatefulWidget {
  const MyRoomScreen({super.key});

  @override
  State<MyRoomScreen> createState() => _MyRoomScreenState();
}

class _MyRoomScreenState extends State<MyRoomScreen> {
  List<dynamic>? rooms;
  int status = 0;

  String imageUrl = 'http://192.168.62.219:8000/storage/';

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final String? hotelId = AppSharedPreferences.getUserId();
    try {
      final response = await http.get(
        Uri.parse('http://192.168.62.219:8000/api/getRoomByHotelId/$hotelId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print(hotelId);
      if (response.statusCode == 200) {
        setState(() {
          rooms = jsonDecode(response.body);
          status = 1;
        });
      } else {
        setState(() {
          status = 2;
        });
      }
    } catch (e) {
      setState(() {
        status = 2;
      });
    }
  }

  void onRoomClicked(dynamic room) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditRoomScreen(room: room),
      ),
    );
  }

  void onAddRoomClicked() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AddRoomScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                onAddRoomClicked();
              },
              icon: Icon(Icons.add))
        ],
        title: Text("My Rooms"),
      ),
      body: status == 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : status == 2
              ? Center(
                  child: Text(
                    "Failed to load rooms",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: rooms?.length ?? 0,
                  itemBuilder: (context, index) {
                    final room = rooms![index]['room'];
                    final images = rooms![index]['image'] ?? [];
                    final views = rooms![index]['vnames'] ?? [];
                    final tools = rooms![index]['tnames'] ?? [];
                    final rate = rooms![index]['rate'] ?? "No rating";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: InkWell(
                        onTap: () => onRoomClicked(room),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (images.isNotEmpty)
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          '$imageUrl${images[0]['image']}'),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              SizedBox(height: 12),
                              Text(
                                room['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                room['desc'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Capacity: ${room['capacity']} people",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    "\$${room['price']}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/star.svg',
                                    height: 16,
                                    width: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    rate.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // عرض الإطلالات
                              Wrap(
                                children: views.map<Widget>((view) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 4),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${view['name']} view",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                children: tools.map<Widget>((tool) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 4),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tool['name'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
