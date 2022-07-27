import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_park/key.dart';
import 'package:go_park/models/address.dart';
import 'package:go_park/models/placePridictions.dart';
import 'package:go_park/widgets/progressDialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressDataProvider extends ChangeNotifier {
  Address currentLocation;
  Address destinationLocation;
  PlacePredictions currentPlacePredicted;
  List<PlacePredictions> placePredictionList = [];

//updating the predicted place after clicking on the prediction tile  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  void updateThePredictedPlaceAfterItIsPicked(PlacePredictions predictedPlace) {
    currentPlacePredicted = predictedPlace;
    notifyListeners();
  }

//updating current user Location  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  void updateCurrentLocationAddress(Address pickUpAddress) {
    currentLocation = pickUpAddress;
    notifyListeners();
  }

//Sending to this method any url to handle it and return the result  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  Future<dynamic> getRequest(String url) async {
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        String jSonData = response.body;
        var decodeData = jsonDecode(jSonData);
        return decodeData;
      } else {
        return "failed";
      }
    } catch (exp) {
      return "failed";
    }
  }

//Finding Nearby places after starting entering a text in the 'whereTo' textField in search screen  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  Future<List<PlacePredictions>> findNearByPlaces(String placeName) async {
    if (placeName.length > 1) {
      //this url link is for bringing nearby places according to the input coming from search
      String autoCompleteUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$key&sessiontoken=1234567890&components=country:eg';

      var res = await getRequest(autoCompleteUrl);

      if (res['status'] == 'OK') {
        var predictions = res['predictions'];

//to convert the json file which contain list of maps to normal list
        var placesList = (predictions as List)
            .map((index) => PlacePredictions.fromjson(index))
            .toList();

        placePredictionList = placesList;
      }
    }

    return placePredictionList;
  }

// Converting My Current address which contains of latitude and longitude to readable address I can understand  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  Future<String> convertToReadableAddress(Position position) async {
    String placeAddress = "";

    String placeAddress1;
    String placeAddress2;
    String placeAddress3;
    String placeAddress4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$key";

    var response = await getRequest(url);

    print('hi');

    print(response);

    if (response != "failed") {
      // placeAddress = response["results"][0][
      //     "formatted_address"]; //since the formatted address displays the specific address of the current location and this is risky regarding the security
      placeAddress1 =
          response["results"][0]["address_components"][0]["long_name"];
      placeAddress2 =
          response["results"][0]["address_components"][2]["long_name"];
      placeAddress4 =
          response["results"][0]["address_components"][3]["long_name"];

      placeAddress =
          placeAddress1 + ", " + placeAddress2 + ", " + placeAddress4;

      print('Adress' + placeAddress);

      Address userCurrentAddress = new Address();
      userCurrentAddress.longitude = position.longitude;
      userCurrentAddress.latitude = position.latitude;
      userCurrentAddress.placeName = placeAddress;

      updateCurrentLocationAddress(userCurrentAddress);
    }
    return placeAddress;
  }

  //Getting Information of the destination address which is specifically latitude and longitude after choosing it >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  Future<String> getParkingAreaDetails(
      String placeId, BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: 'Viewing parking slots, PLease wait...',
            ));

//this url returns the lat and lng of the clicked nearby place that was viewed in the listview by passing to it this place id
    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var res = await getRequest(placeDetailsUrl);
    Navigator.pop(context);
    if (res == 'failed') {
      return 'failed';
    }

    if (res['status'] == 'OK') {
      Address address = Address();
      address.placeName = res['result']['name'];
      address.placeId = placeId;
      address.latitude = res['result']['geometry']['location']['lat'];
      address.longitude = res['result']['geometry']['location']['lng'];

      return address.placeName;
    }
  }
}
