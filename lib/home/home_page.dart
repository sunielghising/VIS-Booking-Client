import 'package:flutter/material.dart';
import 'package:visbooking_app/home/bookings/bookings_page.dart';
import 'package:visbooking_app/home/cupertino_home_scaffold.dart';
import 'package:visbooking_app/home/tab_item.dart';
import 'package:visbooking_app/screens/meeting_screen.dart';
import 'package:visbooking_app/src/pages/index.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.bookings;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.bookings: GlobalKey<NavigatorState>(),
    TabItem.meetings: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.bookings: (_) => BookingsPage(),
      TabItem.meetings: (_) => MeetingScreen(),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      //pop to first route
      navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab].currentState.maybePop(),
      child: CupertinoHomeScaffold(
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: navigatorKeys,
      ),
    );
  }
}
