import 'package:flutter/cupertino.dart';
import 'package:zuri/hospital_item.dart';
import 'package:zuri/hospital_item_modal.dart';



class HospitalListBuilder extends StatelessWidget {
  final List<ItemModal> list;
  final String search;
  const HospitalListBuilder(this.list,this.search,{super.key});

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index){
        return Hospital(hospital: list[index]);
      },
    );
  }
}
