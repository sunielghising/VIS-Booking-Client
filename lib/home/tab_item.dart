import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum TabItem { bookings, meetings }

class TabItemData {
  const TabItemData({
    @required this.title,
    @required this.icon,
  });

  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.bookings:
        TabItemData(title: 'Bookings', icon: Icons.calendar_today),
    TabItem.meetings: TabItemData(title: 'Meetings', icon: Icons.video_call),
  };
}
