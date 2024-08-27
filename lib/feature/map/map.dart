import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hotel_finde_hotel/core/resource/color_manager.dart';
import 'package:hotel_finde_hotel/core/resource/font_manager.dart';
import 'package:hotel_finde_hotel/core/resource/size_manager.dart';
import 'package:hotel_finde_hotel/core/widget/button/main_app_button.dart';
import 'package:hotel_finde_hotel/core/widget/text/app_text_widget.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class Map extends StatefulWidget {
  String? lat;
  String? long;
  Map({this.lat, this.long});
  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController? mapController;
  Position? cl;
  var lat;
  var long;
  CameraPosition? _kGooglePlex;
  late Set<Marker> mymarker;

  @override
  getlocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status == PermissionStatus.denied) {
      await Geolocator.requestPermission();
    }
    if (status == PermissionStatus.granted) {
      await getLatLong();
    }
  }

  getLatLong() async {
    cl = await Geolocator.getCurrentPosition().then((value) => (value));
    if (widget.lat != null) {
      lat = double.parse(widget.lat!);
      long = double.parse(widget.long!);
    } else {
      lat = cl?.latitude;
      long = cl?.longitude;
    }
    _kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 10.4746,
    );
    setState(() {
      mymarker = {
        Marker(markerId: MarkerId("1"), position: LatLng(lat, long)),
        Marker(
            onDragEnd: ((LatLng) => {print(LatLng)}),
            markerId: MarkerId("1"),
            position: LatLng(lat, long))
      };
    });
  }

  void initState() {
    getlocation();

    super.initState();
  }

  Done() async {
    // print(lat);
    // print(long);
    String latlong = '$lat' + '*' + '$long';
    // print(latlong);
    Navigator.of(context).pop(latlong);
// List<Placemark> newPlace = await GeocodingPlatform.instance
//         .placemarkFromCoordinates(lat, long,
//             localeIdentifier: "en");

    // String? placeName = newPlace[0].name;
    // print(placeName);
    // List<Placemark> newPlace =
    //     await GeocodingPlatform.instance.placemarkFromCoordinates(
    //   lat,
    //   long,
    //   localeIdentifier: "en", // Set the locale to Arabic
    // );

// Access the place name from the first placemark
    // String? placeName = newPlace[0].name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _kGooglePlex != null
            ? Stack(
                children: [
                  GoogleMap(
                    onTap: (LatLng) {
                      setState(() {
                        mymarker.add(
                            Marker(markerId: MarkerId("1"), position: LatLng));
                        lat = LatLng.latitude;
                        long = LatLng.longitude;
                      });
                    },
                    markers: mymarker,
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex!,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: MainAppButton(
                      outLinedBorde: true,
                      borderColor: AppColorManager.black,
                      alignment: Alignment.center,
                      width: AppWidthManager.w30,
                      height: AppHeightManager.h5,
                      color: AppColorManager.white,
                      child: AppTextWidget(
                        text: "Done",
                        color: AppColorManager.black,
                        fontSize: FontSizeManager.fs14,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.visible,
                      ),
                      onTap: Done,
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
