import 'dart:convert';

import 'package:favorite_places_app/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart'as http;

class LocationInput extends StatefulWidget{

  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;
  @override
  State<LocationInput> createState() {
   return _LocationInputState();
  }

}

class _LocationInputState extends State<LocationInput>{

  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locationImage{
    if(_pickedLocation == null ){
      return '';
    }

    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;

    return 'https://maps.gomaps.pro/maps/api/staticmap?center=$lat,$lng,NY&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AlzaSyiKXOMN-ctI7Z0NHjuCLoplFVSMbNiCjLP';
  }

  void _getCurrentLocation() async{
  Location location =  Location();

bool serviceEnabled;
PermissionStatus permissionGranted;
LocationData locationData;

serviceEnabled = await location.serviceEnabled();
if (!serviceEnabled) {
  serviceEnabled = await location.requestService();
  if (!serviceEnabled) {
    return;
  }
}

permissionGranted = await location.hasPermission();
if (permissionGranted == PermissionStatus.denied) {
  permissionGranted = await location.requestPermission();
  if (permissionGranted != PermissionStatus.granted) {
    return;
  }
}

setState(() {
  _isGettingLocation = true;
});

locationData = await location.getLocation();
final lat = locationData.latitude;
final lng = locationData.longitude;

if(lat==null || lng==null){
  return;
}

final url = Uri.parse(
  'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AlzaSyiKXOMN-ctI7Z0NHjuCLoplFVSMbNiCjLP'
);
final response = await http.get(url);
final resData = json.decode(response.body);
final address = resData['results'][0]['formatted_address'];

setState(() {
  _pickedLocation = PlaceLocation(
    latitude: lat, 
    longitude:lng, 
    address: address);
  _isGettingLocation = false;
});

widget.onSelectLocation(_pickedLocation!);

}
  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
        'No location choosen',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          // ignore: deprecated_member_use
          color: Theme.of(context).colorScheme.onBackground,
        ),
      );

      if(_pickedLocation != null){
        previewContent = Image.network(
          locationImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }
      if(_isGettingLocation){
        previewContent = const CircularProgressIndicator();
      }
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          // ignore: deprecated_member_use
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        )
      ),
      child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation, 
              label: const Text('Get Current Location'),
              icon: const Icon(Icons.location_on)
              ),
              TextButton.icon(
              onPressed: (){}, 
              label: const Text('Select on Map'),
              icon: const Icon(Icons.map)
              )
          ],
        )
      ],
    );
  }

}