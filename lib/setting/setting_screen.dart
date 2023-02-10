import 'package:coda_wallet/constant/constants.dart';
import 'package:coda_wallet/event_bus/event_bus.dart';
import 'package:coda_wallet/global/global.dart';
import 'package:coda_wallet/route/routes.dart';
import 'package:coda_wallet/widget/dialog/change_password_dialog.dart';
import 'package:coda_wallet/widget/dialog/remove_wallet_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info/package_info.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  var _eventBusOn;

  @override
  void initState() {
    super.initState();
    print('Setting Screen inited');
    _eventBusOn = eventBus.on<SettingChangeEventBus>().listen((event) {
      if(event is RemoveWalletFail) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong password')));
        return;
      }

      if(event is RemoveWalletSucceed) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.of(context).pushNamed(NoWalletRoute);
        });
        return;
      }

      if(event is NetworkChange) {
        setState(() { });
        return;
      }

      if(event is ChangePasswordFail) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong password')));
        return;
      }

      if(event is ChangePasswordSucceed) {
        Navigator.pushNamed(context, EncryptSeedRoute, arguments: {'seed': event.seed, 'init_data': false });
        return;
      }
    });
  }

  @override
  void dispose() {
    _eventBusOn.cancel();
    _eventBusOn = null;
    print('Setting Screen disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: false, scaleByHeight: false);
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: null,
      body: SafeArea(
        child: Container(
          child: _buildSettingItems(context),
          decoration: BoxDecoration(
            color: Colors.white
          ),
        )
      )
    );
  }

  _buildSettingItems(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 40.h),
        Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: Text('ACCOUNTS', textAlign: TextAlign.left,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Color.fromARGB(153, 60, 60, 67))),
        ),
        Container(height: 10.h),
        _buildOuterBorder(),
        InkWell(
          onTap: () => Navigator.of(context).pushNamed(MyAccountsRoute),
          child: _buildSettingItem(context, 'My Accounts')
        ),
        _buildOuterBorder(),
        Container(height: 42.h),
        Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: Text('SECURITY', textAlign: TextAlign.left,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Color.fromARGB(153, 60, 60, 67))),
        ),
        Container(height: 10.h),
        _buildOuterBorder(),
        // _buildSettingItem(context, 'Recovery Phrase'),
        // _buildInnerBorder(),
        // _buildSettingItem(context, 'App Lock'),
        // _buildInnerBorder(),
        InkWell(
          onTap: () => showChangePasswordDialog(context),
          child: _buildSettingItem(context, 'Change Password'),
        ),
        _buildOuterBorder(),
        Container(height: 49.h),
        Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: Text('OTHER', textAlign: TextAlign.left,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Color.fromARGB(153, 60, 60, 67))),
        ),
        Container(height: 10.h),
        _buildOuterBorder(),
        InkWell(
          onTap: () => Navigator.of(context).pushNamed(NetworkSettingRoute),
          child: _buildSettingItem(context, 'Network Connection', currentValue: NETWORK_LIST[getCurrentNetworkId()]),
        ),
 //       _buildInnerBorder(),
//        _buildSettingItem(context, 'Local Fiat Currency'),
        _buildInnerBorder(),
        InkWell(
          onTap: () => showRemoveWalletDialog(context),
          child: _buildSettingItem(context, 'Remove Wallet'),
        ),
        _buildInnerBorder(),
        _buildVersionItem(context),
        _buildOuterBorder(),
      ],
    );
  }

  Future<String> _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    return version;
  }

  _buildVersionItem(BuildContext context) {
    return FutureBuilder(
      future: _getPackageInfo(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          return Container(
            color: Color(0xfff5f5f5),
            padding: EdgeInsets.only(left: 14.w, right: 14.w, top: 11.h, bottom: 11.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child: Text('App Version', textAlign: TextAlign.left, style: TextStyle(fontSize: 16.sp),),
                ),
                Text(snapshot.data!, textAlign: TextAlign.left, style: TextStyle(fontSize: 14.sp, color: Color(0xff2d2d2d)),),
              ],
            ),
          );
        } else {
          return Container();
        }
      }
    );
  }

  _buildSettingItem(BuildContext context, String settingName, {String currentValue = ''}) {
    return Container(
      color: Color(0xfff5f5f5),
      padding: EdgeInsets.only(left: 14.w, right: 14.w, top: 11.h, bottom: 11.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Text(settingName, textAlign: TextAlign.left, style: TextStyle(fontSize: 16.sp),),
          ),
          Text(currentValue, textAlign: TextAlign.left, style: TextStyle(fontSize: 16.sp),),
          Container(width: 4.w,),
          Image.asset('images/arrow_right.png', width: 8.w, height: 13.h,),
        ],
      ),
    );
  }

  _buildOuterBorder() {
    return Container(
      width: double.infinity,
      height: 0.5.h,
      color: Color.fromARGB(74, 60, 60, 67),
    );
  }

  _buildInnerBorder() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(height: 0.5.h, color: Color(0xffc8c7cc))
        )
      ],
    );
  }
}