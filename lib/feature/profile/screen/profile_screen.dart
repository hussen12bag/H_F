import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotel_finde_hotel/core/storage/shared/shared_pref.dart';
import 'package:http/http.dart' as http;

import '../../../core/resource/color_manager.dart';
import '../../../core/resource/font_manager.dart';
import '../../../core/resource/size_manager.dart';
import '../../../core/widget/image/main_image_widget.dart';
import '../../../core/widget/text/app_text_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int status = 0;
  var profileData;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  getProfile() async {
    setState(() {
      status = 0;
    });

    final response = await http.get(Uri.parse(
        'http://192.168.62.219:8000/api/getHotelProfile/${AppSharedPreferences.getUserId()}'));

    if (response.statusCode == 200) {
      setState(() {
        status = 1;
        profileData = jsonDecode(response.body);
      });
    } else {
      setState(() {
        status = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.red,
      onRefresh: () {
        return getProfile();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: status == 0
            ? _buildLoadingState()
            : status == 1
                ? _buildProfileView()
                : _buildErrorState(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(AppWidthManager.w3Point8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppHeightManager.h8),
          _buildShimmerBox(
              AppWidthManager.w25, AppWidthManager.w25, BoxShape.circle),
          SizedBox(height: AppHeightManager.h1point8),
          _buildShimmerBox(AppHeightManager.h6, AppWidthManager.w100),
          SizedBox(height: AppHeightManager.h1point8),
          Row(
            children: [
              Expanded(
                  child: _buildShimmerBox(
                      AppHeightManager.h6, AppWidthManager.w100)),
              SizedBox(width: AppWidthManager.w3Point8),
              Expanded(
                  child: _buildShimmerBox(
                      AppHeightManager.h6, AppWidthManager.w100)),
            ],
          ),
          SizedBox(height: AppHeightManager.h7),
          _buildShimmerBox(AppHeightManager.h6, AppWidthManager.w100),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(double height, double width,
      [BoxShape shape = BoxShape.rectangle]) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColorManager.shimmerBaseColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(AppRadiusManager.r10)
            : null,
      ),
    );
  }

  Widget _buildProfileView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppWidthManager.w3Point8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppHeightManager.h9),
          Center(
            child: Container(
              height: 300,
              width: 500,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: NetworkImage(
                    'http://192.168.62.219:8000/storage/${profileData['image']}'),
              )),
            ),
          ),
          SizedBox(height: AppHeightManager.h2),
          _buildReadOnlyField('Hotel Name', profileData['name']),
          SizedBox(height: AppHeightManager.h2point5),
          _buildReadOnlyField('Email', profileData['email']),
          SizedBox(height: AppHeightManager.h2point5),
          _buildReadOnlyField('Location', profileData['location_desc']),
          SizedBox(height: AppHeightManager.h2point5),
          _buildReadOnlyField('Description', profileData['desc']),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextWidget(
          text: title,
          fontSize: FontSizeManager.fs16,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: AppHeightManager.h1point5),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              vertical: AppHeightManager.h1, horizontal: AppWidthManager.w2),
          decoration: BoxDecoration(
            border: Border.all(color: AppColorManager.greyWithOpacity6),
            borderRadius: BorderRadius.circular(AppRadiusManager.r10),
          ),
          child: AppTextWidget(
            text: value,
            fontSize: FontSizeManager.fs14,
            color: AppColorManager.textAppColor,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Text('Failed to load profile data'),
    );
  }
}
