import 'package:flutter/material.dart';
import 'package:inditex_occupancy/config/router/router.dart';
import 'package:inditex_occupancy/config/theme/app_theme.dart';

class SideMenu extends StatelessWidget {
  final bool principalActive;
  final bool detailActive;
  final bool giftActive;
  final bool searchActive;
  final Size sizeScreen;

  const SideMenu({super.key, required this.principalActive, required this.detailActive, required this.giftActive, required this.searchActive, required this.sizeScreen});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
    width: sizeScreen.width>=700 ? 100 : 60,
    
      height: double.infinity,
      child: 
        Column(
          children: [
            //principal
            SizedBox(
              width: sizeScreen.width>=500 ? 
              principalActive ? 60 : 50 :
              principalActive ? 50 : 45 ,
              height: sizeScreen.width>=500 ? 
              principalActive ? 60 : 50 :
              principalActive ? 50 : 45 ,
              child: FittedBox(
                child: FloatingActionButton(
                  mini: true,
                  shape: const CircleBorder(),
                  elevation: 10,
                  splashColor: AppTheme.buttonsColor,
                  backgroundColor: principalActive ? AppTheme.primaryColor : AppTheme.greyColor,
                  onPressed: (){
                    principalActive ? () : appRouter.go('/home2');
                  },
                  child: 
                  Icon(Icons.home, color: principalActive ? AppTheme.cardColor : AppTheme.primaryColor, 
                    size: 25
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('Principal'),
            SizedBox(height: 30),

            SizedBox(
              width: sizeScreen.width>=500 ? 
              giftActive ? 60 : 50 :
              giftActive ? 50 : 45 ,
              height: sizeScreen.width>=500 ? 
              giftActive ? 60 : 50 :
              giftActive ? 50 : 45 ,
              child: FittedBox(
                child: FloatingActionButton(
                  mini: true,
                  shape: const CircleBorder(),
                  elevation: 10,
                  splashColor: AppTheme.buttonsColor,
                  backgroundColor: giftActive ? AppTheme.primaryColor : AppTheme.greyColor,
                  onPressed: (){
                    giftActive ? () : appRouter.go('/gift');
                  },
                  child: Icon(Icons.card_giftcard, color: giftActive ? AppTheme.cardColor : AppTheme.primaryColor, 
                  size: giftActive ? 25 : 18),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('Regalo'),
            SizedBox(height: 30),
            
            SizedBox(
              width: sizeScreen.width>=500 ? 
              searchActive ? 60 : 50 :
              searchActive ? 50 : 45 ,
              height: sizeScreen.width>=500 ? 
              searchActive ? 60 : 50 :
              searchActive ? 50 : 45 ,
              child: FittedBox(
                child: FloatingActionButton(
                  mini: true,
                  shape: const CircleBorder(),
                  elevation: 10,
                  splashColor: AppTheme.buttonsColor,
                  backgroundColor: searchActive ? AppTheme.primaryColor : AppTheme.greyColor,
                  onPressed: (){
                    searchActive ? () : appRouter.go('/search');
                  },
                  child: Icon(Icons.search, color: searchActive ? AppTheme.cardColor : AppTheme.primaryColor, 
                  size: searchActive ? 25 : 18),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('Buscar'),
          ],
        ),
      );
  }
}