import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hotel_finde_hotel/core/storage/shared/shared_pref.dart';
import 'package:http/http.dart' as http;

import '../../../core/resource/color_manager.dart';
import '../../../core/resource/font_manager.dart';
import '../../../core/resource/size_manager.dart';
import '../../../core/widget/button/main_app_button.dart';
import '../../../core/widget/form_field/title_app_form_filed.dart';
import '../../../core/widget/text/app_text_widget.dart';

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  List<File> images = [];
  final ImagePicker picker = ImagePicker();

  List<String> selectedTools = [];
  List<String> selectedViews = [];

  final List<Map<String, dynamic>> tools = [
    {'id': 1, 'name': 'TV'},
    {'id': 2, 'name': 'Hair Dryer'},
    {'id': 3, 'name': 'Fan'},
    {'id': 4, 'name': 'Dish Washer'},
  ];

  final List<Map<String, dynamic>> views = [
    {'id': 1, 'name': 'Sea'},
    {'id': 2, 'name': 'River'},
    {'id': 3, 'name': 'Mountain'},
  ];

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> addRoom() async {
    final String? hotelId = AppSharedPreferences.getUserId();
    if (hotelId == null ||
        images.isEmpty ||
        selectedTools.isEmpty ||
        selectedViews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppTextWidget(
            text: "Please fill all fields and select images, tools, and views",
            color: AppColorManager.white,
            fontSize: FontSizeManager.fs14,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      return;
    }

    final uri = Uri.parse('http://192.168.1.112:8000/api/addRoom');
    final request = http.MultipartRequest('POST', uri)
      ..fields['name'] = nameController.text
      ..fields['desc'] = descController.text
      ..fields['price'] = priceController.text
      ..fields['hotel_id'] = hotelId
      ..fields['capacity'] = capacityController.text;

    for (int i = 0; i < selectedTools.length; i++) {
      request.fields['tool[$i]'] = selectedTools[i];
    }

    for (int i = 0; i < selectedViews.length; i++) {
      request.fields['view[$i]'] = selectedViews[i];
    }

    for (int i = 0; i < images.length; i++) {
      request.files
          .add(await http.MultipartFile.fromPath('image$i', images[i].path));
    }

    final response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppTextWidget(
            text: "Room added successfully!",
            color: AppColorManager.white,
            fontSize: FontSizeManager.fs14,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppTextWidget(
            text: "Failed to add room. Please try again.",
            color: AppColorManager.white,
            fontSize: FontSizeManager.fs14,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTextWidget(
          text: "Add Room",
          fontWeight: FontWeight.w700,
          fontSize: FontSizeManager.fs18,
          color: AppColorManager.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppWidthManager.w3Point8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleAppFormFiled(
              hint: "Room Name",
              title: "Name",
              onChanged: (value) {
                nameController.text = value!;
              },
              validator: (value) =>
                  value!.isEmpty ? "Please enter the room name" : null,
            ),
            SizedBox(height: AppHeightManager.h2),
            TitleAppFormFiled(
              hint: "Room Description",
              title: "Description",
              onChanged: (value) {
                descController.text = value!;
              },
              validator: (value) =>
                  value!.isEmpty ? "Please enter the room description" : null,
            ),
            SizedBox(height: AppHeightManager.h2),
            TitleAppFormFiled(
              hint: "Room Price",
              title: "Price",
              validator: (value) =>
                  value!.isEmpty ? "Please enter the room price" : null,
              onChanged: (value) {
                priceController.text = value!;
              },
            ),
            SizedBox(height: AppHeightManager.h2),
            TitleAppFormFiled(
              hint: "Room Capacity",
              title: "Capacity",
              validator: (value) =>
                  value!.isEmpty ? "Please enter the room capacity" : null,
              onChanged: (value) {
                capacityController.text = value!;
              },
            ),
            SizedBox(height: AppHeightManager.h2),
            AppTextWidget(
              text: "Tools",
              fontWeight: FontWeight.w700,
              fontSize: FontSizeManager.fs16,
              color: AppColorManager.black,
            ),
            Wrap(
              spacing: 10,
              children: tools.map((tool) {
                return FilterChip(
                  label: Text(tool['name']),
                  selected: selectedTools.contains(tool['id'].toString()),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedTools.add(tool['id'].toString());
                      } else {
                        selectedTools.remove(tool['id'].toString());
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppHeightManager.h2),
            AppTextWidget(
              text: "Views",
              fontWeight: FontWeight.w700,
              fontSize: FontSizeManager.fs16,
              color: AppColorManager.black,
            ),
            Wrap(
              spacing: 10,
              children: views.map((view) {
                return FilterChip(
                  label: Text(view['name']),
                  selected: selectedViews.contains(view['id'].toString()),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedViews.add(view['id'].toString());
                      } else {
                        selectedViews.remove(view['id'].toString());
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppHeightManager.h2),
            AppTextWidget(
              text: "Images",
              fontWeight: FontWeight.w700,
              fontSize: FontSizeManager.fs16,
              color: AppColorManager.black,
            ),
            Wrap(
              spacing: 10,
              children: [
                for (int i = 0; i < images.length; i++)
                  Image.file(images[i],
                      width: 100, height: 100, fit: BoxFit.cover),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () => pickImage(ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: AppHeightManager.h5),
            Center(
              child: MainAppButton(
                onTap: addRoom,
                alignment: Alignment.center,
                width: AppWidthManager.w60,
                height: AppHeightManager.h6,
                color: AppColorManager.black,
                child: AppTextWidget(
                  text: "Add Room",
                  color: AppColorManager.white,
                  fontSize: FontSizeManager.fs16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
