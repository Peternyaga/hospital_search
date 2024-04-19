import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:zuri/hospital_item_modal.dart';

import 'constants.dart';
import 'list_builder.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String search = "";
  late LocationData myLocation;
  double myLat = 0.0;
  double myLong = 0.0;
  Map requestBody = {};
  int radius = 1000;
  bool apiHasError = false;
  String apiError = "";

  BuildContext getContext(){
    return context;
  }

  /*function to fetch location*/
  Future<void> fetchLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        locationDialog(getContext(), "Turn on location.");
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        locationDialog(getContext(), "");
        return;
      }
    }else if(permissionGranted == PermissionStatus.deniedForever){
      locationDialog(getContext(), "Go to settings and grant Zuri location permission");
      return;
    }
    myLocation = await location.getLocation();
    myLat = myLocation.latitude!;
    myLong = myLocation.longitude!;
  }

  @override
   initState() {
    fetchLocation();
    setState(() {

    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    /*request body sent to Google Places API*/
    requestBody = {
      "includedTypes": ["hospital"],
      "maxResultCount": 20,
      "locationRestriction": {
        "circle": {
          "center": {"latitude": myLat, "longitude": myLong},
          "radius": radius
        }
      }
    };
    List<ItemModal> list = [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.title)),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                child: Row(
                  children: [
                    Text(
                        "Radius: ${radius >= 1000 ? "${radius / 1000}km" : "${radius}m"}"),
                    PopupMenuButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (String value) {
                        setState(() {
                          radius = int.parse(value);
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        List<PopupMenuEntry<String>> items = [];
                        for (int i = 100; i <= 5000; i += 500) {
                          items.add(
                            PopupMenuItem<String>(
                              value: (i-100==0? 100: i-100).toString(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("${i-100==0? 100: i-100} m"),
                                ],
                              ),
                            ),
                          );
                        }
                        return items;
                      },
                    )
                  ],
                ),
              ),
              Card(
                child: Row(
                  children: [
                    Text(
                      search.isEmpty ? "Service" : search,
                      overflow: TextOverflow.ellipsis,
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.filter_alt_outlined),
                      onSelected: (String value) {
                        setState(() {
                          search = value;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        List<PopupMenuEntry<String>> items = [];

                        for (int i = 0; i < services.length; i++) {
                          items.add(
                            PopupMenuItem<String>(
                              value: services[i],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.local_hospital_outlined),
                                  Text(services[i]),
                                ],
                              ),
                            ),
                          );
                        }
                        return items;
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          FutureBuilder(
              future: getPlaces(requestBody),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                      child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  toast("connection error!");
                  return Center(child: Text(snapshot.error.toString()));
                } else if(hospitals.isEmpty){
                  return Expanded(child: Center(child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          const Expanded(child: Text("There are no hospitals within your search range. Try expanding your search radius",style: TextStyle(color: Colors.pink),)),
                          IconButton(onPressed: (){
                            setState(() {
                    
                          });
                            }, icon: const Icon(Icons.refresh))
                        ],
                      ),
                    ),
                  ),));
                }else{
                  String name = "";
                  String address = "";
                  String image = "";

                  /*This loop creates a itemModal for each hospital by extracting specific fields from the data received from Google Places API*/
                  List places;
                  try{
                   places = hospitals["places"];
                  }catch(e){
                    places =[];
                  }
                  for (int i = 0; i < places.length; i++) {
                    try {
                      name = hospitals["places"][i]["displayName"]['text'];
                      address = hospitals["places"][i]["shortFormattedAddress"];
                      image =
                          "https${hospitals["places"][i]["photos"][0]['authorAttributions'][0]['photoUri']}";
                    } catch (e) {
                      if (kDebugMode) {
                        print(e.toString());
                      }
                    }

                    /*generating a list of services randomly for each hospital*/
                    int noOfServices;
                    do {
                      noOfServices = Random().nextInt(services.length);
                    } while (noOfServices < 2);

                    String availableServices = "";
                    List<int> selectedServices = [];
                    for (int i = 0; i < noOfServices; i++) {
                      int selectedService = Random().nextInt(services.length);
                      if (!selectedServices.contains(selectedService)) {
                        availableServices += services[selectedService] + "\n";
                        selectedServices.add(selectedService);
                      }
                    }
                    if (availableServices.contains(search)) {
                      ItemModal item =
                          ItemModal(name, address, availableServices, image);
                      list.add(item);
                    }
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HospitalListBuilder(list, search),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}

/*
* function to fetch data from Google Places
* make sure that the apiKey variable in constants is set to a valid Google Places API key*/
Future<String> getPlaces(Map request) async {
  print(request);
  var url = Uri.https(
      'places.googleapis.com', 'v1/places:searchNearby', {'fields': "*",'key':apiKey});
  String queryString = jsonEncode(request);
  try {
    var response = await http.post(url,
        headers: <String, String>{
          "Accept": 'application/json',
          'Content-Type': 'application/json'
        },
        body: queryString);
    if (kDebugMode) {
      print("===================>>>>>${response.body}");
    }

    if (response.statusCode == 200) {
        hospitals = jsonDecode(response.body);
    } else {
     toast("Google Places API responded with an error. This data is not live");
    }
    return "${response.statusCode}";
  } catch (e) {
    print(e.toString());
    toast(e.toString());
    toast(e.toString());
    toast(e.toString());
    toast(e.toString());
    return "300";
  }
}


/*
* function to show a toast*/

void toast(String message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.yellow,
      textColor: Colors.pink,
      fontSize: 16.0);
}

void locationDialog(BuildContext context, String message){
  showDialog(context: context, builder: (BuildContext context){
    return AlertDialog(
      title: const Text("Location Alert"),
      content: const Text("Zuri requires your location to fetch nearby hospitals. \nMake sure that location is turned on and that Zuri has location permission."),
      actions: [TextButton(onPressed: (){
        Navigator.pop(context);
      }, child: const Text("Ok"))],
    );
  });
}