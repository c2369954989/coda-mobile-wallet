import 'dart:typed_data';

import 'package:coda_wallet/constant/constants.dart';
import 'package:coda_wallet/event_bus/event_bus.dart';
import 'package:coda_wallet/global/global.dart';
import 'package:coda_wallet/widget/ui/custom_box_shadow.dart';
import 'package:ffi_mina_signer/sdk/mina_signer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import 'loading_dialog.dart';

class ChangePasswordWidget extends StatefulWidget {
  ChangePasswordWidget({Key? key}) : super(key: key);

  @override
  _ChangePasswordWidgetState createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  FocusNode _focusNodeChangePassword = FocusNode();
  TextEditingController _controllerChangePassword = TextEditingController();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNodeChangePassword.dispose();
    _controllerChangePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: false, scaleByHeight: false);
    print('ChangePasswordWidget: build(context: $context)');
    return KeyboardActions(
      tapOutsideToDismiss: false,
      autoScroll: false,
      disableScroll: true,
      config: KeyboardActionsConfig(
        keyboardSeparatorColor: Colors.grey,
        nextFocus: false,
        actions: [
          KeyboardActionsItem(focusNode: _focusNodeChangePassword)
        ]
      ),
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.w)),
            color: Colors.white
          ),
          padding: EdgeInsets.only(top: 2.h, bottom: 12.h, left: 12.w, right: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset('images/close.png', width: 18.w, height: 18.w,),
                  )
                ],
              ),
              Image.asset('images/password_unlock_logo.png', width: 60.w, height: 51.h,),
              Container(height: 12.h,),
              Padding(
                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                child: Text('Please input the password you set to encrypt seed',
                  maxLines: 4, textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 16.sp),),
              ),
              Container(height: 16.h,),
              Container(
                padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                child: Row(
                  children: [
                    Container(width: 8,),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        enableInteractiveSelection: true,
                        focusNode: _focusNodeChangePassword,
                        controller: _controllerChangePassword,
                        onChanged: (text) {

                        },
                        maxLines: 1,
                        obscureText: _showPassword ? false : true,
                        keyboardType: TextInputType.text,
                        autofocus: false,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Input seed password',
                          hintStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: Color(0xffbdbdbd))
                        )
                      )
                    ),
                    Container(width: 4.w,),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      child: _showPassword ? Image.asset('images/pwd_hide.png', width: 20.w, height: 20.w,)
                        : Image.asset('images/pwd_show.png', width: 20.w, height: 20.w,),
                    ),
                    Container(width: 8.w,),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color(0xfff5f5f5),
                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                  border: Border.all(width: 1.w, color: Color(0xff22d2d))
                  ),
                ),
                Container(height: 32.h,),
                Builder(builder: (BuildContext context) =>
                  InkWell(
                    onTap: () async {
                      if(_controllerChangePassword.text.isEmpty) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      //String? encryptedSeed = globalPreferences.getString(ENCRYPTED_SEED_KEY);
                      String? encryptedSeed = await globalSecureStorage.read(key: ENCRYPTED_SEED_KEY);
                      print('Change password: start to decrypt seed');
                      ProgressDialog.showProgress(context);
                      try {
                        Uint8List seed = await decryptSeed(encryptedSeed!, _controllerChangePassword.text);
                        // Successfully decrypt, push seed to encryption page.
                        eventBus.fire(ChangePasswordSucceed(seed));
                        Navigator.of(context).pop();
                      } catch (error) {
                        print('password not right');
                        eventBus.fire(ChangePasswordFail());
                        Navigator.of(context).pop();
                      } finally {
                        ProgressDialog.dismiss(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 14.h, bottom: 14.h, left: 50.w, right: 50.w),
                      decoration: getMinaButtonDecoration(topColor: Color(0xfff5f5f5)),
                        child: Text('CONFIRM',
                          textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Color(0xff2d2d2d))),
                        ),
                      )
                    )
                  ],
                )
            )
        )
    );
  }
}
