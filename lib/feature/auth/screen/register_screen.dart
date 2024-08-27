import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:hotel_finde_hotel/core/resource/color_manager.dart';
import 'package:hotel_finde_hotel/core/resource/font_manager.dart';
import 'package:hotel_finde_hotel/core/resource/size_manager.dart';
import 'package:hotel_finde_hotel/core/storage/shared/shared_pref.dart';
import 'package:hotel_finde_hotel/core/widget/button/main_app_button.dart';
import 'package:hotel_finde_hotel/core/widget/form_field/title_app_form_filed.dart';
import 'package:hotel_finde_hotel/core/widget/text/app_text_widget.dart';
import '../../../router/router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationDescController = TextEditingController();

  File? _image;
  String imageStatus = "Choose Image";

  final GlobalKey<FormState> formKey = GlobalKey();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageStatus = "Image Added";
      });
    }
  }

  void onSigninClicked() {
    Navigator.of(context).pushNamed(RouteNamedScreens.login);
  }

  Future<void> fun() async {
    final result = await Navigator.of(context).pushNamed(RouteNamedScreens.map);
    if (result != null && result is String) {
      final latLong = result.split('*');
      if (latLong.length == 2) {
        setState(() {
          locationController.text = latLong[0];
          locationDescController.text = latLong[1];
        });
      }
    }
  }

  Future<void> registerHotel({
    required String name,
    required String email,
    required String password,
    required String location,
    required String locationDesc,
    required String desc,
    required File? image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.62.219:8000/api/hotelRegister'),
      );

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['lat'] = location;
      request.fields['long'] = location;
      request.fields['location_desc'] = locationDesc;
      request.fields['desc'] = desc;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var body = jsonDecode(String.fromCharCodes(responseData));

      if (response.statusCode == 200) {
        AppSharedPreferences.cashUserName(username: body['hotel data']['name']);
        AppSharedPreferences.cashUserid(
            id: body['hotel data']['id'].toString());
        AppSharedPreferences.cashUserToken(token: body['token']);
        print("sssssssssssssssssssssssss");
        print(AppSharedPreferences.cashUserName);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppTextWidget(
              text: "Welcome To Hotel Finder",
              color: AppColorManager.white,
              fontSize: FontSizeManager.fs14,
              fontWeight: FontWeight.w700,
              overflow: TextOverflow.visible,
            ),
          ),
        );

        Navigator.of(context).pushNamed(RouteNamedScreens.bottomAppBar);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppTextWidget(
              text: body['message'] ?? 'Unknown Error',
              color: AppColorManager.white,
              fontSize: FontSizeManager.fs14,
              fontWeight: FontWeight.w700,
              overflow: TextOverflow.visible,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppTextWidget(
            text: 'Failed to connect to server',
            color: AppColorManager.white,
            fontSize: FontSizeManager.fs14,
            fontWeight: FontWeight.w700,
            overflow: TextOverflow.visible,
          ),
        ),
      );
    }
  }

  void onSignUpClicked() async {
    if (formKey.currentState?.validate() ?? false) {
      await registerHotel(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        location: locationController.text,
        locationDesc: locationDescController.text,
        desc: descController.text,
        image: _image,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3.75,
                width: double.infinity,
                decoration: const BoxDecoration(),
                child: SvgPicture.asset("assets/icons/curve.svg"),
              ),
              Padding(
                padding: EdgeInsets.all(AppWidthManager.w3Point8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppHeightManager.h1),
                    AppTextWidget(
                      text: "Create An Account.",
                      color: AppColorManager.black,
                      fontSize: FontSizeManager.fs20,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(height: AppHeightManager.h05),
                    AppTextWidget(
                      text: "Register With Your Valid Email Address.",
                      color: AppColorManager.black,
                      fontSize: FontSizeManager.fs16,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(height: AppHeightManager.h1point8),
                    TitleAppFormFiled(
                      hint: "Hotel Name",
                      title: "Hotel Name",
                      onChanged: (value) {
                        nameController.text = value ?? "";
                        return null;
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Empty Field";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppHeightManager.h1point8),
                    TitleAppFormFiled(
                      hint: "Email Address",
                      title: "Email Address",
                      onChanged: (value) {
                        emailController.text = value ?? "";
                        return null;
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Empty Field";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppHeightManager.h1point8),
                    TitleAppFormFiled(
                      hint: "Password",
                      title: "Password",
                      obscureText: true, //
                      maxLines: 1,
                      onChanged: (value) {
                        passwordController.text = value ?? "";
                        return null;
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Empty Field";
                        }
                        if ((value?.length ?? 0) < 6) {
                          return "Invalid Password";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppHeightManager.h1point8),
                    TitleAppFormFiled(
                      hint: "Location",
                      title: "Location",
                      suffixIcon: 'assets/icons/marker.svg',
                      initValue: locationController.text,
                      readOnly: true,
                      onIconTaped: fun,
                      onChanged: (value) {
                        locationController.text = value ?? "";
                        return null;
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Empty Field";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppHeightManager.h1point8),
                    TitleAppFormFiled(
                      hint: "Location Description",
                      title: "Location Description",
                      onChanged: (value) {
                        locationDescController.text = value ?? "";
                        return null;
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Empty Field";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppHeightManager.h1point8),
                    TitleAppFormFiled(
                      hint: "Description",
                      title: "Description",
                      onChanged: (value) {
                        descController.text = value ?? "";
                        return null;
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Empty Field";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppHeightManager.h1point8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.all(AppWidthManager.w3Point8),
                        decoration: BoxDecoration(
                          color: AppColorManager.white,
                          borderRadius:
                              BorderRadius.circular(AppWidthManager.w1Point5),
                          border: Border.all(
                            color: AppColorManager.grey,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppTextWidget(
                              text: imageStatus,
                              color: AppColorManager.black,
                              fontSize: FontSizeManager.fs14,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.visible,
                            ),
                            Icon(Icons.add_a_photo, color: AppColorManager.grey)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppHeightManager.h8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MainAppButton(
                          onTap: onSignUpClicked,
                          alignment: Alignment.center,
                          width: AppWidthManager.w30,
                          height: AppHeightManager.h5,
                          color: AppColorManager.black,
                          child: AppTextWidget(
                            text: "Sign In",
                            color: AppColorManager.white,
                            fontSize: FontSizeManager.fs14,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        SizedBox(width: AppWidthManager.w5),
                        MainAppButton(
                          onTap: onSigninClicked,
                          outLinedBorde: true,
                          borderColor: AppColorManager.black,
                          alignment: Alignment.center,
                          width: AppWidthManager.w30,
                          height: AppHeightManager.h5,
                          color: AppColorManager.white,
                          child: AppTextWidget(
                            text: "Sign Up",
                            color: AppColorManager.black,
                            fontSize: FontSizeManager.fs14,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.visible,
                          ),
                        )
                      ],
                    )
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
