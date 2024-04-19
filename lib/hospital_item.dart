import 'package:flutter/material.dart';
import 'package:zuri/hospital_item_modal.dart';

class Hospital extends StatelessWidget {
  final ItemModal hospital;
  const Hospital({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.purple,
                    child: Icon(Icons.local_hospital_outlined,
                    size: 50,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30,),
            Text(hospital.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.location_pin),
                  ),
                  Flexible(
                    child: Text(hospital.address,
                    softWrap: true,
                    maxLines: null,),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text("Services",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                  Text(hospital.services),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
