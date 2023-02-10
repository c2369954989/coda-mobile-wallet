import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:coda_wallet/constant/constants.dart';
import 'package:coda_wallet/event_bus/event_bus.dart';
import 'package:coda_wallet/global/global.dart';
import 'package:coda_wallet/screen_record_detector/screen_record_detector.dart';
import 'package:coda_wallet/types/mina_hd_account_type.dart';
import 'package:coda_wallet/util/account_utils.dart';
import 'package:coda_wallet/widget/app_bar/app_bar.dart';
import 'package:coda_wallet/widget/dialog/loading_dialog.dart';
import 'package:coda_wallet/widget/dialog/screen_record_detect_dialog.dart';
import 'package:coda_wallet/widget/ui/custom_box_shadow.dart';
import 'package:ffi_mina_signer/sdk/mina_signer_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:password_strength/password_strength.dart';

enum PasswordStrength {
  WEAK,
  MEDIUM,
  STRONG
}

class EncryptSeedScreen extends StatefulWidget {
  EncryptSeedScreen({Key? key}) : super(key: key);

  @override
  _EncryptSeedScreenState createState() => _EncryptSeedScreenState();
}

class _EncryptSeedScreenState extends State<EncryptSeedScreen> with ScreenRecordDetector {
  late FocusNode _focusNodeOrigin;
  late FocusNode _focusNodeConfirm;
  late TextEditingController _controllerOrigin;
  late TextEditingController _controllerConfirm;
  bool _showOrigin = false;
  bool _showConfirm = false;
  bool _alertChecked = false;
  late Uint8List _seed;
  late bool _initData;
  bool _buttonEnabled = false;
  bool _clearSecureFlag = false;
  PasswordStrength _passwordStrength = PasswordStrength.WEAK;

  _checkPasswordStrength(String password) {
    if(password.isEmpty) {
      _passwordStrength = PasswordStrength.WEAK;
    }

    double strength = estimatePasswordStrength(password);
    if(strength < 0.3) {
      _passwordStrength = PasswordStrength.WEAK;
    } else if(strength < 0.7) {
      _passwordStrength = PasswordStrength.MEDIUM;
    } else {
      _passwordStrength = PasswordStrength.STRONG;
    }
  }

  _checkPassword(BuildContext context) {
    if(_controllerOrigin.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid password!')));
      return;
    }

    if(_controllerConfirm.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid password')));
      return;
    }

    if(_controllerConfirm.text != _controllerOrigin.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords are inconsistent!')));
      return;
    }

    _generateAccounts(context);
  }

  _checkInput(BuildContext context) {
    if(_alertChecked &&
      _controllerConfirm.text.isNotEmpty &&
      _controllerOrigin.text.isNotEmpty) {
      _buttonEnabled = true;
    } else {
      _buttonEnabled = false;
    }
    _checkPasswordStrength(_controllerOrigin.text);
    setState(() {

    });
  }

  _generateAccounts(BuildContext context) async {
    print('[import wallet]: start convert mnemonic words to seed');
    ProgressDialog.showProgress(context);
    print('[import wallet]: start to encrypted seed');
    globalEncryptedSeed = await encryptSeed(_seed, _controllerConfirm.text, sodium: true);
    print('[import wallet]: save seed String');
    //globalPreferences.setString(ENCRYPTED_SEED_KEY, globalEncryptedSeed!);
    await globalSecureStorage.write(key: ENCRYPTED_SEED_KEY, value: globalEncryptedSeed);

    if(_initData) {
      print('[import wallet]: start to derive account');
      List<AccountBean> accounts = await deriveDefaultAccount(_seed);
      globalHDAccounts.accounts = accounts;
      Map accountsJson = globalHDAccounts.toJson();
      // globalPreferences.setString(
      //   GLOBAL_ACCOUNTS_KEY, json.encode(accountsJson));
      await globalSecureStorage.write(key: GLOBAL_ACCOUNTS_KEY, value: json.encode(accountsJson));
      eventBus.fire(UpdateAccounts());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password changed!'),
      ));
    }

    ProgressDialog.dismiss(context);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void initState() {
    super.initState();
    super.initDetector();
    _focusNodeOrigin = FocusNode();
    _focusNodeConfirm = FocusNode();
    _controllerOrigin = TextEditingController();
    _controllerConfirm = TextEditingController();
  }

  @override
  void dispose() {
    _focusNodeOrigin.dispose();
    _focusNodeConfirm.dispose();
    _controllerOrigin.dispose();
    _controllerConfirm.dispose();
    if(_clearSecureFlag) {
      super.dismissDetector();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: false, scaleByHeight: false);

    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _seed = arguments['seed'];
    _initData = arguments['init_data'];

    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: buildNoTitleAppBar(context, actions: false, backgroundColor: Color(0xfff5f5f5)),
      body: Padding(
        padding: EdgeInsets.only(left: 30.w, right: 30.w),
        child: KeyboardActions(
          tapOutsideToDismiss: true,
          autoScroll: true,
          config: KeyboardActionsConfig(
            keyboardSeparatorColor: Colors.grey,
            nextFocus: false,
            actions: [
              KeyboardActionsItem(focusNode: _focusNodeOrigin),
              KeyboardActionsItem(focusNode: _focusNodeConfirm)
            ]),
            child: SingleChildScrollView(
              child: _buildCreatePasswordBody(context)
            )
          )
        )
    );
  }

  _buildCreatePasswordBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(height: 37.h,),
        Text('Create Password', textAlign: TextAlign.left, style: TextStyle(fontSize: 28.sp, color: Color(0xff2d2d2d)),),
        Container(height: 26.h,),
        Container(
        padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 15.h, bottom: 15.h),
        child: Row(children: [
          Container(width: 8,),
          Expanded(
            flex: 1,
            child: TextField(
              enableInteractiveSelection: true,
              focusNode: _focusNodeOrigin,
              controller: _controllerOrigin,
              onChanged: (text) {
                _checkInput(context);
              },
              maxLines: 1,
              obscureText: _showOrigin ? false : true,
              keyboardType: TextInputType.text,
              autofocus: false,
              decoration: InputDecoration.collapsed(
                hintText: 'Password',
                hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: Color(0xffbdbdbd)))
            )
          ),
          Container(width: 4.w,),
          InkWell(
            onTap: () {
              setState(() {
                _showOrigin = !_showOrigin;
              });
            },
            child: _showOrigin ? Image.asset('images/pwd_hide.png', width: 20.w, height: 20.w,)
              : Image.asset('images/pwd_show.png', width: 20.w, height: 20.w,),
          ),
          Container(width: 8.w,)]),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(2.w)),
            border: Border.all(width: 1.w, color: Color(0xff757575))
          )
        ),
        Container(height: 12.h,),
        Row(children: [
          Container(
            padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
            child: Center(
              child: Text('Weak', maxLines: 1, style: TextStyle(fontSize: 16.sp),)
            ),
            width: 80.w,
            decoration: BoxDecoration(
              color: _passwordStrength == PasswordStrength.WEAK ? Colors.red : Color(0xfff5f5f5),
              borderRadius: BorderRadius.all(Radius.circular(0.w)),
              border: Border.all(width: 1.w, color: Color(0xff757575))
            )
          ),
          Container(
            padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
            child: Center(
              child: Text('Medium', maxLines: 1, style: TextStyle(fontSize: 16.sp),)
            ),
            width: 80.w,
            decoration: BoxDecoration(
              color: _passwordStrength == PasswordStrength.MEDIUM ? Colors.yellow : Color(0xfff5f5f5),
              borderRadius: BorderRadius.all(Radius.circular(0.w)),
              border: Border.all(width: 1.w, color: Color(0xff757575))
            )
          ),
          Container(
            padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
            child: Center(
              child: Text('Strong', maxLines: 1, style: TextStyle(fontSize: 16.sp),)
            ),
            width: 80.w,
            decoration: BoxDecoration(
              color: _passwordStrength == PasswordStrength.STRONG ? Colors.green : Color(0xfff5f5f5),
              borderRadius: BorderRadius.all(Radius.circular(0.w)),
              border: Border.all(width: 1.w, color: Color(0xff757575))
            )
          )
        ],),
        Container(height: 12.h,),
        Container(
          padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 15.h, bottom: 15.h),
          child: Row(children: [
            Container(width: 8,),
            Expanded(
              flex: 1,
              child: TextField(
                enableInteractiveSelection: true,
                focusNode: _focusNodeConfirm,
                controller: _controllerConfirm,
                onChanged: (text) {
                  _checkInput(context);
                },
                maxLines: 1,
                obscureText: _showConfirm ? false : true,
                keyboardType: TextInputType.text,
                autofocus: false,
                decoration: InputDecoration.collapsed(
                  hintText: 'Confirm Password',
                  hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: Color(0xffbdbdbd)))
                )
              ),
              Container(width: 4.w,),
              InkWell(
                onTap: () {
                  setState(() {
                    _showConfirm = !_showConfirm;
                  });
                },
                child: _showConfirm ? Image.asset('images/pwd_hide.png', width: 20.w, height: 20.w,)
                  : Image.asset('images/pwd_show.png', width: 20.w, height: 20.w,),
              ),
              Container(width: 8.w,),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(2.w)),
            border: Border.all(width: 1.w, color: Color(0xff757575))
          ),
        ),
        Container(height: 28.h,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            InkWell(
              onTap: () {
                _alertChecked = !_alertChecked;
                _checkInput(context);
              },
              child: Image.asset(_alertChecked ? 'images/security_alert_gold.png' : 'images/security_alert_gray.png', width: 28.w, height: 28.w,),
            ),
            Container(width: 14.w,),
            Flexible(
              child: Text('I understand that if I lose my password, I will not be able to access my funds.',
                textAlign: TextAlign.left, maxLines: 3, style: TextStyle(fontSize: 16.sp),)
            )
          ],
        ),
        Container(height: 34.h,),
        Builder(builder: (context) =>
          Center(child:
            InkWell(
              onTap: _buttonEnabled ? () {
                _clearSecureFlag = true;
                _checkPassword(context);
              } : null,
              child: Container(
                padding: EdgeInsets.only(top: 14.h, bottom: 14.h, left: 100.w, right: 100.w),
                decoration: getMinaButtonDecoration(topColor: Color(_buttonEnabled ? 0xffe0e0e0 : 0x4deeeeee)),
                child: Text('CONTINUE',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Color(_buttonEnabled ? 0xff2d2d2d : 0x4d2d2d2d))),
              )
            ),
          )
        )
      ],
    );
  }

  @override
  void showWarningAlert() {
    showScreenRecordDectectedDialog(context);
  }
}