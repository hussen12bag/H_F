import 'package:flutter/material.dart';
import 'package:hotel_finde_hotel/core/resource/color_manager.dart';
import 'package:hotel_finde_hotel/core/resource/font_manager.dart';
import 'package:hotel_finde_hotel/core/resource/size_manager.dart';
import 'package:hotel_finde_hotel/core/storage/shared/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HotelReservationsScreen extends StatefulWidget {
  const HotelReservationsScreen({super.key});

  @override
  State<HotelReservationsScreen> createState() =>
      _HotelReservationsScreenState();
}

class _HotelReservationsScreenState extends State<HotelReservationsScreen> {
  List<Map<String, dynamic>>? reservations;
  String roomName = '';
  int status = 0;

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.62.219:8000/api/getHotelReservations/${AppSharedPreferences.getUserId()}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          if (data.isNotEmpty) {
            var firstItem = data[0];
            roomName = firstItem['room']['name'] ?? '';

            reservations =
                (firstItem['reservations'] as List).map((reservation) {
              return {
                'id': reservation['id'] ?? 0,
                'nights': int.tryParse(reservation['nights'].toString()) ?? 0,
                'date': reservation['date'] ?? '',
                'file': reservation['file'],
                'type': reservation['type'].toString(),
                'room_id': reservation['room_id'] ?? 0,
                'user_id': reservation['user_id'] ?? 0,
              };
            }).toList();
          } else {
            reservations = [];
          }
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

  Future<void> updateReservation(int id, String type, String? file) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.62.219:8000/api/acceptRejectReservation'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'type': type,
          'file': file,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation updated successfully!')),
        );
        fetchReservations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update reservation.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while updating reservation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hotel Reservations",
          style: TextStyle(
            color: AppColorManager.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorManager.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: status == 0
          ? Center(child: CircularProgressIndicator())
          : status == 2
              ? Center(
                  child: Text(
                    "Failed to load reservations",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(AppWidthManager.w3Point8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var reservation in reservations!)
                          Container(
                            margin:
                                EdgeInsets.only(bottom: AppHeightManager.h2),
                            padding: EdgeInsets.all(AppWidthManager.w3Point8),
                            decoration: BoxDecoration(
                              color: AppColorManager.white,
                              borderRadius:
                                  BorderRadius.circular(AppRadiusManager.r30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorManager.shadow,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Room Name: $roomName",
                                  style: TextStyle(
                                    fontSize: FontSizeManager.fs16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorManager.black,
                                  ),
                                ),
                                SizedBox(height: AppHeightManager.h1),
                                Text(
                                  "Date: ${reservation['date']}",
                                  style: TextStyle(
                                    fontSize: FontSizeManager.fs14,
                                    color: AppColorManager.textGrey,
                                  ),
                                ),
                                SizedBox(height: AppHeightManager.h05),
                                Text(
                                  "Nights: ${reservation['nights']}",
                                  style: TextStyle(
                                    fontSize: FontSizeManager.fs14,
                                    color: AppColorManager.textGrey,
                                  ),
                                ),
                                SizedBox(height: AppHeightManager.h05),
                                Text(
                                  "Current Status: ${reservation['type'] == '0' ? 'Pending' : reservation['type'] == '1' ? 'Accepted' : 'Rejected'}",
                                  style: TextStyle(
                                    fontSize: FontSizeManager.fs14,
                                    color: AppColorManager.textGrey,
                                  ),
                                ),
                                SizedBox(height: AppHeightManager.h2),
                                if (reservation['type'] == '0')
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          await updateReservation(
                                              reservation['id'], '1', null);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColorManager.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadiusManager.r50),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: AppHeightManager.h1,
                                              horizontal: AppWidthManager.w8),
                                        ),
                                        child: Text(
                                          'Accept',
                                          style: TextStyle(
                                            color: AppColorManager.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await updateReservation(
                                              reservation['id'], '2', null);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColorManager.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadiusManager.r50),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: AppHeightManager.h1,
                                              horizontal: AppWidthManager.w8),
                                        ),
                                        child: Text(
                                          'Reject',
                                          style: TextStyle(
                                            color: AppColorManager.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
