import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:visbooking_app/screens/bookings_finish.dart';
import 'package:visbooking_app/screens/existing_cards.dart';
import 'package:visbooking_app/services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  static const String id = 'payment_screen';
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  onItemPress(BuildContext context, int index) async {
    switch (index) {
      case 0:
        payViaNewCard(context);
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ExistingCardsPage();
        }));
        break;
    }
  }

  payViaNewCard(BuildContext context) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var response =
        await StripeService.payWithNewCard(amount: '50000', currency: 'AUD');
    await dialog.hide();
    Scaffold.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(response.message),
            duration: new Duration(
                milliseconds: response.success == true ? 1200 : 3000),
          ),
        )
        .closed
        .then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingsFinish(),
          fullscreenDialog: true,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF089083),
        title: Text('Payment'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            Icon icon;
            Text text;

            switch (index) {
              case 0:
                icon = Icon(
                  Icons.add_circle,
                  color: Color(0xFF089083),
                );
                text = Text('Pay via new card');
                break;
              case 1:
                icon = Icon(
                  Icons.credit_card,
                  color: Color(0xFF089083),
                );
                text = Text('Pay via existing card');
                break;
            }
            return InkWell(
              child: ListTile(
                onTap: () {
                  onItemPress(context, index);
                },
                title: text,
                leading: icon,
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(
            color: Color(0xFF089083),
          ),
          itemCount: 2,
        ),
      ),
    );
  }
}
