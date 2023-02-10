import 'package:coda_wallet/global/global.dart';
import 'package:coda_wallet/route/routes.dart';
import 'package:coda_wallet/types/send_data.dart';
import 'package:coda_wallet/widget/app_bar/app_bar.dart';
import 'package:coda_wallet/widget/ui/custom_box_shadow.dart';
import 'package:coda_wallet/widget/ui/custom_gradient.dart';
import 'package:ffi_mina_signer/util/mina_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

_gotoSendFee(BuildContext context, SendData sendData) {
  Navigator.pushReplacementNamed(context, SendFeeRoute, arguments: sendData);
}

class SendAmountScreen extends StatefulWidget {
  SendAmountScreen({Key? key}) : super(key: key);

  @override
  _SendAmountScreenState createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen> {
  List<String> _keyString = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '< Clear'];
  late List<Widget> _keys;
  late List<String> _inputAmount;
  late StringBuffer _amountBuffer;
  late String _amountStr;
  late SendData _sendData;
  bool _validInput = false;
  BigInt? _balance = BigInt.from(0);

  @override
  void initState() {
    super.initState();
    _keys = [];
    _inputAmount = [];
    _inputAmount.add('0');
    _amountBuffer = StringBuffer();
    _amountBuffer.writeAll(_inputAmount);
  }

  @override
  void dispose() {
    _amountBuffer.clear();
    _inputAmount.clear();
    super.dispose();
  }

  String _getInputFiatPrice() {
    if(_amountBuffer.isEmpty) {
      return '0.0';
    }

    // Confirm this is a valid double
    double? temp = double.tryParse(_amountBuffer.toString());
    if(null == temp) {
      return '0.0';
    }
    String nanoMinaStr = MinaHelper.getNanoStrByMinaStr(_amountBuffer.toString());
    return getTokenFiatPrice(nanoMinaStr);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: false, scaleByHeight: false);
    _sendData = ModalRoute.of(context)!.settings.arguments as SendData;
    _balance = BigInt.tryParse(globalHDAccounts.accounts![_sendData.from]!.balance!);
    _keys = List.generate(_keyString.length, (index) => _buildKey(index));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildNoTitleAppBar(context),
      body: Container(
        child: _buildSendToBody(context),
        decoration: BoxDecoration(
          gradient: backgroundGradient
        ),
      )
    );
  }

  _buildSendToBody(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 50.w, right: 50.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(height: 29.h),
              Text('BALANCE', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Color(0xff2d2d2d))),
              RichText(
                textAlign: TextAlign.right,
                text: TextSpan(children: <TextSpan>[
                  TextSpan(
                    text: '${MinaHelper.getMinaStrByNanoStr(globalHDAccounts.accounts![_sendData.from]!.balance ?? '')} ',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black)
                  ),
                  TextSpan(
                    text: 'MINA',
                      style: TextStyle(color: Color(0xff616161), fontWeight: FontWeight.normal, fontSize: 12.sp)
                  ),
                ]),
              ),
              Container(height: 20.h),
              Container(
                height: 54.h,
                child: Center(
                  child: Text(_amountBuffer.toString(), textAlign: TextAlign.left, maxLines: 2, overflow: TextOverflow.visible,
                    style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.normal, color: Colors.black))
                )
              ),
              Container(height: 6.h,),
              Text('\$${_getInputFiatPrice()}', textAlign: TextAlign.left, maxLines: 1,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.normal, color: Color(0xff979797))),
              Container(height: 20.h),
              _buildDecimalKeyboard(),
            ],)
          ),
          Builder(builder: (context) =>
          Positioned(
            bottom: 60.h,
            child: InkWell(
              onTap: _validInput ? () {
                BigInt? nanoAmount = MinaHelper.getNanoNumByMinaStr(_amountStr);
                if(nanoAmount! > _balance!) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not enough balance')));
                } else {
                  _sendData.amount = MinaHelper.getNanoStrByMinaStr(_amountStr);
                  _gotoSendFee(context, _sendData);
                }
              } : () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid input amount!!')));
              },
              child: Container(
                padding: EdgeInsets.only(top: 14.h, bottom: 14.h, left: 94.w, right: 94.w),
                decoration: getMinaButtonDecoration(topColor: Colors.white),
                child: Text('CONTINUE',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Color(0xff2d2d2d))),
              ),
            )
          )),
          Positioned(
            top: 29.h,
            right: 47.w,
            child: InkWell(
              child: Text('SEND ALL', textAlign: TextAlign.right,
                style: TextStyle(color: Color(0xff2d2d2d), fontWeight: FontWeight.w600, fontSize: 13.sp)),
              onTap: _fillAllInput,
            )
          )
        ]
    );
  }

  _checkInputAmount(String amountString) {
    // First, use double to confirm if the input is a valid number
    double? sendAmount = double.tryParse(amountString);
    if(null == sendAmount) {
      // Invalid user input
      _validInput = false;
      setState(() {

      });
      return;
    } else {
      // User input is valid number
      _amountStr = _amountBuffer.toString();
      if (sendAmount == 0.0) {
        _validInput = false;
      } else {
        _validInput = true;
      }
      setState(() {

      });
      return;
    }
  }

  _fillAllInput() {
    _amountBuffer.clear();
    _inputAmount.clear();
    _inputAmount.add(MinaHelper.getMinaStrByNanoNum(_balance));
    _amountBuffer.writeAll(_inputAmount);
    _checkInputAmount(_amountBuffer.toString());
  }

  _fillInput() {
    _amountBuffer.clear();
    _amountBuffer.writeAll(_inputAmount);
    _checkInputAmount(_amountBuffer.toString());
  }

  _tapOnKeyCallback(int index) {
    if(index == _keyString.length - 1) {
      if(_inputAmount.length == 1) {
        if(_inputAmount[0] == '0') {
          return;
        } else {
          _inputAmount[0] = '0';
          _fillInput();
          return;
        }
      }
      _inputAmount.removeLast();
      _fillInput();
    } else {
      if(_keyString[index] == '.') {
        _inputAmount.add(_keyString[index]);
        _fillInput();
        return;
      }

      if(_inputAmount.length == 1 && _inputAmount[0] == '0') {
        _inputAmount[0] = _keyString[index];
      } else {
        _inputAmount.add(_keyString[index]);
      }
      _fillInput();
    }
  }

  _buildKey(int index) {
    return InkWell(
      onTap: () => _tapOnKeyCallback(index),
      child: index == _keyString.length - 1
        ? _buildDeleteKey(index)
        : _buildNumericKey(index),
    );
  }

  _buildNumericKey(int index) {
    return
      Center(
        child: Text(_keyString[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.normal)),
    );
  }
  
  _buildDeleteKey(int index) {
    return
      Center(
        child: Text(_keyString[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.normal)),
    );
  }

  _buildDecimalKeyboard() {
    return Flexible(child: GridView.count(
      shrinkWrap: true,
      childAspectRatio: 1,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      padding: EdgeInsets.symmetric(vertical: 0),
      children: _keys,
    ));
  }
}
