import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uber_clone/api/polyline_api.dart';
import 'package:uber_clone/api/search_api.dart';
import 'package:uber_clone/models/driver_model.dart';
import 'dart:math' as Math;
import 'package:polyline/polyline.dart' as poly;

class LocationModel extends ChangeNotifier {
  Location location = new Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData currentLocation;
  Place currentLocationInfo = new Place();
  Place pickUpLocationInfo = new Place();
  Place dropOffLocationInfo = new Place();
  List<Driver> nearbyDrivers = new List();
  Timer timer;
  List<Polyline> overviewLines = new List();
  List<Polyline> navLines = new List();
  List<Step> steps = new List();
//  List<Step> nextThreeSteps = new List();
  MapMode mapMode = MapMode.NearestDriver;

  LocationModel() {
    setLocation();
  }

  void setMapMode(MapMode mode) {
    mapMode = mode;
    notifyListeners();
  }

  Driver getNearestDriver() {
    Driver nearestDriver = nearbyDrivers[0];
    double dist = 0;
    for (int x = 0; x < nearbyDrivers.length; x++) {
      double distance = getDistanceFromLatLonInKm(
          nearbyDrivers[x].liveLocation.latitude,
          nearbyDrivers[x].liveLocation.longitude,
          pickUpLocationInfo.latitude,
          pickUpLocationInfo..longitude);
      if (distance < dist) {
        nearestDriver = nearbyDrivers[x];
        dist = distance;
      }
    }
    return nearestDriver;
  }

  void setPickupLocationInfo(Place location) {
    pickUpLocationInfo = location;
    notifyListeners();
  }

  void setDropOffLocationInfo(Place location) {
    dropOffLocationInfo = location;
    notifyListeners();
  }

  void resetOverviewLine() {
    overviewLines = new List();
    notifyListeners();
  }

  Future<bool> getOverViewPolyLines() async {
    var result = await PolylineApi.getPolyLines(
        LatLng(pickUpLocationInfo.latitude, pickUpLocationInfo.longitude),
        LatLng(dropOffLocationInfo.latitude, dropOffLocationInfo.longitude));
    List<LatLng> coordinates = result['polyline'];
    if (coordinates != null) {
      Polyline line = Polyline(
          polylineId: PolylineId("trip_overview"),
          points: coordinates,
          width: 3);
      Polyline navLine = Polyline(
          polylineId: PolylineId("trip_overview"),
          points: coordinates,
          color: Colors.lightBlueAccent,
          width: 15);
      overviewLines.add(line);
      navLines.add(navLine);
      steps = result['steps'];
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void setLocation() async {
    //checks if location service is enabled and Enable service if disabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    //checks if location permission is granted and requests permission if not granted.
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    //get current user location
    currentLocation = await location.getLocation();
    currentLocationInfo = await SearchApi.convertCoordinatesToAddress(
        LatLng(currentLocation.latitude, currentLocation.longitude));
    nearbyDrivers = DriverModel.getDummyDrivers(
        LatLng(currentLocation.latitude, currentLocation.longitude));
    notifyListeners();

    //update user location as it changes
    timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      print("updating location");
      currentLocation = await location.getLocation();
      currentLocationInfo = await SearchApi.convertCoordinatesToAddress(
          LatLng(currentLocation.latitude, currentLocation.longitude));
      notifyListeners();
    });
  }
}

LatLng calcNorthEastBound(LatLng pos1, LatLng pos2) {
  double lat;
  double lng;
  if (pos1.latitude > pos2.latitude) {
    lat = pos1.latitude;
  } else {
    lat = pos2.latitude;
  }

  if (pos1.longitude > pos2.longitude) {
    lng = pos1.longitude;
  } else {
    lng = pos2.longitude;
  }
  return LatLng(lat, lng);
}

LatLng calcSouthWestBound(LatLng pos1, LatLng pos2) {
  double lat;
  double lng;
  if (pos1.latitude < pos2.latitude) {
    lat = pos1.latitude;
  } else {
    lat = pos2.latitude;
  }

  if (pos1.longitude < pos2.longitude) {
    lng = pos1.longitude;
  } else {
    lng = pos2.longitude;
  }
  return LatLng(lat, lng);
}

double getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2 - lat1); // deg2rad below
  var dLon = deg2rad(lon2 - lon1);
  var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(deg2rad(lat1)) *
          Math.cos(deg2rad(lat2)) *
          Math.sin(dLon / 2) *
          Math.sin(dLon / 2);
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  var d = R * c; // Distance in km
  return d;
}

double deg2rad(deg) {
  return deg * (Math.pi / 180);
}

enum MapMode { NearestDriver, DestinationNavigation }

class Step {
  String distance;
  String duration;
  LatLng startLocation;
  LatLng endLocation;
  String maneuver;
  Polyline polyLine;
  List<LatLng> coords;
  double distanceKm;

  Step(
      {this.distance,
      this.coords,
      this.duration,
      this.endLocation,
      this.distanceKm,
      this.maneuver,
      this.polyLine,
      this.startLocation});

  factory Step.fromJson(Map<String, dynamic> json) {
    List<LatLng> coordinates = PolylineApi.coordinatesConverter(
        poly.Polyline.Decode(
            precision: 5, encodedString: json['polyline']['points']));
    Polyline line = Polyline(
        polylineId: PolylineId("trip_overview"), points: coordinates, width: 3);
    return Step(
        distance: json['distance']['text'],
        coords: coordinates,
        duration: json['duration']['text'],
        startLocation: LatLng(
            json['start_location']['lat'], json['start_location']['lng']),
        endLocation:
            LatLng(json['end_location']['lat'], json['end_location']['lng']),
        polyLine: line,
        distanceKm: getDistanceFromLatLonInKm(
            json['start_location']['lat'],
            json['start_location']['lng'],
            json['end_location']['lat'],
            json['end_location']['lng']),
        maneuver: json['maneuver']);
  }
}
