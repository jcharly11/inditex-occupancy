import 'package:go_router/go_router.dart';
import 'package:inditex_occupancy/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
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
      path: '/home',
      //name: HomeScreen().name,
      builder: (context,state) => HomeScreen()
    ),
  ]
);