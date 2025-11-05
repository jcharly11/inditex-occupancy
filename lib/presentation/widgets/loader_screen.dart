import 'package:flutter/material.dart';
import 'package:inditex_occupancy/config/theme/app_theme.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children:[ 
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.cloud_download_outlined, size: 50,color: AppTheme.buttonsColor,),
                SizedBox(
                  height: 150,
                  width: 150,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.buttonsColor),
                    strokeWidth: 6
                  ),
                ),
              ],
            ),
          ),
          Text('Cargando Asistencia de Personas', style: 
            TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500
            ),
          )
        ]
      ),
    );
  }
}