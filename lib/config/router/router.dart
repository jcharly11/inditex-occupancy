import 'package:go_router/go_router.dart';
import 'package:inditex_occupancy/presentation/screens/details/zone_detail_screen.dart';
import 'package:inditex_occupancy/presentation/screens/gift/gift_screen.dart';
import 'package:inditex_occupancy/presentation/screens/home/home2.dart';
import 'package:inditex_occupancy/presentation/screens/home/home_screen.dart';
import 'package:inditex_occupancy/presentation/screens/home/test.dart';
import 'package:inditex_occupancy/presentation/screens/search/search_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home2',
  // navigatorKey: navKey,
  // redirect: (context, state) async {
    
  //   if (token == null && state.matchedLocation != '/login') {
  //     return '/login';
  //   }
  //   if (token != null && state.matchedLocation == '/login') {
  //     if(client==null){
  //       return '/settings';
  //     }
  //     else{
  //       return '/events';
  //     }
  //   }
  //   return null;
  // },
  routes: [
    GoRoute(
      path: '/test',
      //name: HomeScreen().name,
      builder: (context,state) => Test()
    ),

    GoRoute(
      path: '/home2',
      //name: HomeScreen().name,
      builder: (context,state) => Home2()
    ),
    GoRoute(
      path: '/home',
      //name: HomeScreen().name,
      builder: (context,state) => HomeScreen()
    ),
    GoRoute(
      path: '/gift',
      //name: HomeScreen().name,
      builder: (context,state) => ScreenGift()
    ),
    GoRoute(
      path: '/search',
      //name: HomeScreen().name,
      builder: (context,state) => SearchScreen()
    ),
    GoRoute(
      path: '/details/:peopleInside/:zone/:maxOccupancy',
      builder: (context, state) {
        final peopleInside = state.pathParameters['peopleInside'];
        final zone = state.pathParameters['zone'];
        final maxOccupancy = state.pathParameters['maxOccupancy'];
        return ZoneDetailScreen(peopleInside: peopleInside, zone: zone, maxOccupancy: maxOccupancy);
      },
    ),
  ]
);