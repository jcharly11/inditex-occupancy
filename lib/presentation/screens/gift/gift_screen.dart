import 'package:flutter/material.dart';
import 'package:inditex_occupancy/config/theme/app_theme.dart';
import 'package:inditex_occupancy/db/db_sembast_helper.dart';
import 'package:inditex_occupancy/presentation/widgets/custom_appbar.dart';
import 'package:inditex_occupancy/presentation/widgets/side_menu.dart';
import 'package:inditex_occupancy/services/firebase_service.dart';
import 'package:oktoast/oktoast.dart';

class ScreenGift extends StatefulWidget {
  const ScreenGift({super.key});

  @override
  State<ScreenGift> createState() => _ScreenGift();
}

class _ScreenGift extends State<ScreenGift> { 
  
  final TextEditingController _controller = TextEditingController(); 
  final FocusNode _focusNode = FocusNode();
  

  String? result; 
  bool? saveGift=false;
  String? currentID; 
  bool? searchingGift= false;
  
  @override
  void initState() {
    super.initState();
    saveGift= false;
    DbSembastHelper.instance.insertInitialData(); 
  }

  @override
void dispose() {
  _controller.dispose();
  _focusNode.dispose();
  super.dispose();
}

Future<void> searchGift(String value) async {
  setState(() { searchingGift= true;});
  if (!validation(value)) {
    setState(() {
      _controller.clear();
      _focusNode.requestFocus();
      result = 'ID Invalido, escanea nuevamente tu pulsera';
      saveGift=false;
      searchingGift=false;
    });
    return;
  }
  
  //final mensaje = await DbSembastHelper.instance.consultarYActualizarRegalo(value);
  final mensaje = await FirebaseService.instance.getStatusGift(value);

  setState(() {
    _controller.clear();
    _focusNode.requestFocus();
    result = mensaje["message"];
    saveGift = mensaje["result"];
    if(value.length==24){
      currentID= value.substring(1,7);
    }
    else{
      currentID= value;
    }
    searchingGift= false;
  });
}


Future<void> saveGifts(Size sizeScreen) async {
  setState(() { searchingGift= true;});
  //await DbSembastHelper.instance.saveGifts(currentID.toString());
  var docs= await FirebaseService.peopleExists(currentID!);
  await FirebaseService.updatePeopleGift(docs);
  
  
  
  showToast("Regalos Entregados al ID $currentID",
    margin: EdgeInsetsGeometry.fromLTRB(sizeScreen.width >=500 ? 75 : 30, 0, 0, 0),
    position: ToastPosition.bottom,
    backgroundColor: AppTheme.primaryColor,
    textStyle: TextStyle(fontSize: sizeScreen.width>=500 ? 25 : 20, color: Colors.white)
  );
  setState(() { searchingGift= false;});
}

Future<void> restoreGifts(Size sizeScreen) async {
  setState(() { searchingGift= true;});
  //await DbSembastHelper.instance.refreshGifts();
  await FirebaseService.instance.restoreGifts();
  showToast("Regalos Restablecidos",
    margin: EdgeInsetsGeometry.fromLTRB(sizeScreen.width >=500 ? 75 :30 , 0, 0, 0),
    position: ToastPosition.bottom,
    backgroundColor: AppTheme.primaryColor,
    textStyle: TextStyle(fontSize: sizeScreen.width>=500 ? 25 : 20, color: Colors.white)
  );
  setState(() { searchingGift= false; saveGift= false; result="";});
}

bool validation(String input) {
  // final regex = RegExp(r'^[A-Z0-9]{24}$');
  final regex = RegExp(r'^[a-zA-Z0-9]{6}$|^[a-zA-Z0-9]{24}$');
  return regex.hasMatch(input);
}


  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppbar(sizeScreen: sizeScreen),
        body: 
        Row(
        children:[ 
          SideMenu(principalActive: false, detailActive: false, giftActive: true, searchActive: false,
          sizeScreen: sizeScreen),
          Padding(
          padding: EdgeInsets.fromLTRB(0,16,16,16),
          child:
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
              child: Container(
              width: sizeScreen.width>=500 ? sizeScreen.width-120 : sizeScreen.width-90,
              height: double.infinity,
              color: AppTheme.greyColor,
              child: Center(
                child: SingleChildScrollView(child:
                SizedBox(
                  child: Card(
                    elevation: 10,
                    color: AppTheme.colorGeneral,
                    child: Container(
                      width: sizeScreen.width>=500 ? 400 : 250,
                      //prod 
                      //height: sizeScreen.width>=500 ? 380 :320,

                      //test button restore gift
                      height: sizeScreen.width>=500 ? 460 :400,

                      padding: sizeScreen.width>=500 ? EdgeInsets.all(24) : 
                      EdgeInsetsGeometry.fromLTRB(5, 20, 5, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Validación de Regalo', style: TextStyle(
                              fontSize: sizeScreen.width>=500 ? 27 : 20,
                              fontWeight: FontWeight.w500
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: sizeScreen.width>=500 ? 24 : 5),
                          Container(
                            padding: sizeScreen.width>=500 ? EdgeInsets.all(24)
                            : EdgeInsetsGeometry.fromLTRB(15, 10, 15, 10),
                            child: Column(
                              children: [
                                Text(
                                  'Escanea Pulsera o escribe Id',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: sizeScreen.width>=500 ? 18 : 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(height: sizeScreen.width>=500 ? 24: 10),
                              
                                TextField(
                                  controller: _controller,
                                  onSubmitted: searchGift,
                                  focusNode: _focusNode,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar...',
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: AppTheme.greyColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                if (result != null)
                                  Text(
                                    result!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sizeScreen.width>=500 ? 16 : 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                SizedBox(height: 20),
                                
                                if(searchingGift!)
                                  CircularProgressIndicator(),
                                if(saveGift!)
                                  SizedBox(
                                    height: 50,
                                    width: 200,
                                    child: FilledButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all(AppTheme.primaryColor)
                                      ),
                                      icon: Icon(Icons.card_giftcard, size: 20),label: Text('Recibir Regalos'),
                                      onPressed: (){
                                        showDialog(
                                          // barrierDismissible: false,
                                          context: context, 
                                          builder: (BuildContext context) => AlertDialog(
                                            actionsPadding: EdgeInsetsGeometry.all(60),
                                            actionsAlignment: MainAxisAlignment.center,
                                            icon: Icon(Icons.card_giftcard_rounded, size: 60),
                                            
                                            title: Text('Entrega de regalos',
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.w600
                                              )
                                            ),
                                            content: Text('¿Confirmas la entrega de regalos al ID: $currentID?', 
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 20
                                              ),
                                            ),
                                            actionsOverflowAlignment: OverflowBarAlignment.center,
                                            actionsOverflowDirection: VerticalDirection.down,
                                            actionsOverflowButtonSpacing: 10,
                                            actions: 

                                            [
                                              
                                              SizedBox(
                                                width: sizeScreen.width>=500 ? 200 : 160,
                                                height: sizeScreen.width>=500 ? 60 : 45,
                                                child: ElevatedButton.icon(
                                                  label: Text('Confirmar', style: TextStyle(color: Colors.white, fontSize:sizeScreen.width>=500 ? 18 : 14)),
                                                  icon: Icon(Icons.check_circle_outline_outlined, size: sizeScreen.width>=500 ? 35 :25),
                                                  onPressed: ()async {
                                                    saveGifts(sizeScreen);
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      result= null;
                                                      saveGift=false;
                                                    });

                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                                    backgroundColor: AppTheme.primaryColor,
                                                    iconColor: Colors.white
                                                  )
                                                ),
                                              ),

                                              SizedBox(
                                                width: sizeScreen.width>=500 ? 200 : 160,
                                                height: sizeScreen.width>=500 ? 60 : 45,
                                                child: ElevatedButton.icon(
                                                  label: Text('Cancelar', style: TextStyle(color: Colors.white, fontSize:sizeScreen.width>=500 ? 18 : 14),),
                                                  icon: Icon(Icons.cancel_outlined, size: sizeScreen.width>=500 ? 35 :25),
                                                  onPressed: (){
                                                    Navigator.of(context).pop();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                                    backgroundColor: AppTheme.secondaryColor,
                                                    iconColor: Colors.white
                                                  )
                                                ),
                                              )
                                            ],
                                          )
                                        );
                                      }
                                    ),
                                  ),

                                  SizedBox(height: 30),
                                  if(!searchingGift!)
                                    SizedBox(
                                      height: 50,
                                      width: 200,
                                      child: FilledButton.icon(
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStateProperty.all(AppTheme.secondaryColor)
                                        ),
                                        icon: Icon(Icons.change_circle_outlined, size: 20),label: Text('Restablecer Regalos'),
                                        onPressed: (){
                                          restoreGifts(sizeScreen);
                                        }
                                      )
                                    )
                              ],
                            ),
                          ),
                        ],
                      ),
                              
                              ),
                  ),
                ),
                  
                      ),
              )
        )
          )
          )
        ]
        )
    );
  }
}