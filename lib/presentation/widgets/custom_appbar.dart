import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget{
  final Size sizeScreen;
  const CustomAppbar({super.key, required this.sizeScreen});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 80,
        title: SizedBox(
          width: double.infinity,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end, 
            children: [
              Expanded(
                flex: 3,
                child: 
                Image.asset(
                  'assets/images/Inditex-logо.png',
                  height: 40,
                ),
              ),
              Expanded(
                flex: sizeScreen.width>=500 ? 4 :1,
                child:
                sizeScreen.width >= 500 ?
                Image.asset(
                  'assets/images/store_operations.png',
                  height: sizeScreen.width>=500 ? 35 : 30,
                )
                : 
                SizedBox(),
              ),
              Expanded(
                flex: sizeScreen.width>=500 ? 3 : 6,
                child:
                Image.asset(
                  sizeScreen.width >= 500 ?
                  'assets/images/checkpoint_logo.png' : 'assets/images/store_operations.png',
                  fit: BoxFit.fitHeight,
                  height: sizeScreen.width>=500 ? 30 : 30,
                )
              ),
          
             
            ],
          ),
        )
      );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}