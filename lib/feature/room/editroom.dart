import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/resource/color_manager.dart';
import '../../../core/resource/font_manager.dart';
import '../../../core/resource/size_manager.dart';
import '../../../core/widget/form_field/title_app_form_filed.dart';
import '../../../core/widget/text/app_text_widget.dart';

class EditRoomScreen extends StatefulWidget {
  final dynamic room;

  const EditRoomScreen({super.key, required this.room});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.room['name'];
    _priceController.text = widget.room['price'].toString();
    _descController.text = widget.room['desc'];
    _capacityController.text = widget.room['capacity'].toString();
  }

  Future<void> updateRoom() async {
    final String apiUrl = 'http://192.168.62.219:8000/api/updateRoom';
    final String roomId = widget.room['id'].toString();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': roomId,
          'name': _nameController.text,
          'price': _priceController.text,
          'desc': _descController.text,
          'capacity': _capacityController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Room updated successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop({
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
          'desc': _descController.text,
          'capacity': int.parse(_capacityController.text),
        });
      } else {
        print('Failed to update room: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update room: ${response.body}'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error occurred: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTextWidget(
          text: 'Edit Room',
          fontSize: 20,
          color: AppColorManager.black,
          fontWeight: FontWeight.w800,
        ),
        backgroundColor: AppColorManager.background,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppWidthManager.w3Point8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleAppFormFiled(
              hint: "Room Name",
              title: "Name",
              onChanged: (value) {
                _nameController.text = value ?? '';
              },
              validator: (value) =>
                  value!.isEmpty ? "Please enter the room name" : null,
              initValue: _nameController.text,
            ),
            SizedBox(height: AppHeightManager.h2),
            TitleAppFormFiled(
              hint: "Room Price",
              title: "Price",
              onChanged: (value) {
                _priceController.text = value ?? '';
              },
              validator: (value) =>
                  value!.isEmpty ? "Please enter the room price" : null,
              initValue: _priceController.text,
            ),
            SizedBox(height: AppHeightManager.h2),
            TitleAppFormFiled(
              hint: "Room Description",
              title: "Description",
              onChanged: (value) {
                _descController.text = value ?? '';
              },
              validator: (value) =>
                  value!.isEmpty ? "Please enter the room description" : null,
              initValue: _descController.text,
            ),
            SizedBox(height: AppHeightManager.h2),
            TitleAppFormFiled(
              hint: "Room Capacity",
              title: "Capacity",
              onChanged: (value) {
                _capacityController.text = value ?? '';
              },
              validator: (value) =>
                  value!.isEmpty ? "Please enter the room capacity" : null,
              initValue: _capacityController.text,
            ),
            SizedBox(height: AppHeightManager.h2),
            ElevatedButton(
              onPressed: updateRoom,
              child: AppTextWidget(
                text: 'Update Room',
                color: AppColorManager.white,
                fontWeight: FontWeight.w400,
                fontSize: FontSizeManager.fs16,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorManager.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
