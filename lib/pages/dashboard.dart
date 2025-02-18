import 'package:flutter/material.dart';
import 'package:gover_driver_app/pages/earnings_page.dart';
import 'package:gover_driver_app/pages/home_page.dart';
import 'package:gover_driver_app/pages/profile_page.dart';
import 'package:gover_driver_app/pages/trips_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {

  TabController? controller;
  int indexSelected = 0;

   onBarItemClicked (int i) {
     setState(() {
       indexSelected = i;
       controller!.index = indexSelected;
     });
   }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller!.dispose();
    super.dispose();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          HomePage(),
          EarningsPage(),
          TripsPage(),
          ProfilePage(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(

                icon: Icon(Icons.home),
              label: "Accueil"
            ),

            BottomNavigationBarItem(

                icon: Icon(Icons.credit_card),
                label: "gains"
            ),


            BottomNavigationBarItem(

                icon: Icon(Icons.account_tree),
                label: "trajets"
            ),


            BottomNavigationBarItem(

                icon: Icon(Icons.person),
                label: "Profile"
            ),
          ],
          currentIndex: indexSelected,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.deepPurple,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,


      ),











    );
  }
}
