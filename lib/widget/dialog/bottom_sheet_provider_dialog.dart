import 'package:coda_wallet/stake_provider/blocs/stake_providers_entity.dart';
import 'package:coda_wallet/widget/dialog/url_open_warning_dialog.dart';
import 'package:coda_wallet/widget/dialog/customer_bottom_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_unescape/html_unescape_small.dart';

const TITLE_COLUMN_RATIO = 2;
const CONTENT_COLUMN_RATIO = 3;
double columnSpacing = 12.w;
double rowSpacing = 16.h;

void showProviderBottomDialog(BuildContext context, Staking_providersBean? provider) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16.w), topRight: Radius.circular(16.w))),
    isScrollControlled: true,
    useRootNavigator: false,
    isDismissible: true,
    enableDrag: false,
    builder: (context) => CustomerBottomDialogWidget(
      title: 'Know Your Provider',
      customView: _buildProvider(context, provider),
      isShowCloseButton: false,
      isShowTopIcon: true,
    )
  );
}

_buildProvider(BuildContext context, Staking_providersBean? provider) {
  return Padding(
    padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Text("Provider Info", textAlign: TextAlign.left, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xff9397a2))),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 0.5.w),
            borderRadius: BorderRadius.all(Radius.circular(5.w)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, offset: Offset(0, 0), blurRadius: 5, spreadRadius: 2.0)
            ]
          ),
          child: Column(
            children: [
              _buildMultiLineTexts('Provider Name', provider?.providerTitle, 2),
              _buildVerification(provider?.addressVerification),
              _buildHyperlink(context, 'Provider Site', provider?.website, 3),
              _buildHyperlink(context, 'Provider Github', provider?.github, 3),
              _buildMultiLineTexts('Provider Address', provider?.providerAddress, 3),
              _buildTermsWidget(provider?.payoutTerms, needBottomLine: false),
            ]
          )
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Text("Pool Info", textAlign: TextAlign.left, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xff9397a2))),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 0.5.w),
            borderRadius: BorderRadius.all(Radius.circular(5.w)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, offset: Offset(0, 0), blurRadius: 5, spreadRadius: 2.0)
            ]
          ),
          child: Column(
            children: [
              _buildMultiLineTexts('Delegators', '${provider?.delegatorsNum ?? ''}', 2),
              _buildMultiLineTexts('Staked Amount', provider?.stakedSum?.toString(), 2),
              _buildMultiLineTexts('Pool Percent', '${provider?.stakePercent?.toString() ?? ''}%', 2),
              _buildMultiLineTexts('Pool Fee', '${provider?.providerFee ?? ''}%', 2, needBottomLine: false)
            ]
          )
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Text("Provider Contacts", textAlign: TextAlign.left, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xff9397a2))),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 0.5.w),
            borderRadius: BorderRadius.all(Radius.circular(5.w)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, offset: Offset(0, 0), blurRadius: 5, spreadRadius: 2.0)
            ]
          ),
          child: Column(
            children: [
              _buildContacts(provider, needBottomLine: false)
            ]
          )
        ),
        Container(height: 10.h),
      ]
    )
  );
}

_buildRowSpacing(){
  return Container(height: rowSpacing);
}

_buildBottomLine(){
  return Divider(height: 16.h, color: Colors.black12);
}

_buildVerification(int? verification, {bool needTopSpacing = false, bool needBottomLine = true}){
  if (1 == verification) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        needTopSpacing ? _buildRowSpacing() : SizedBox.shrink(),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: TITLE_COLUMN_RATIO,
              child: Text(
                'Verification',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xff9397a2))
              ),
            ),
            Container(width: columnSpacing),
            Expanded(
              flex: CONTENT_COLUMN_RATIO,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  1 == verification ? Image.asset('images/verified_long.png', height: 16.h) : SizedBox.shrink(),
                ]
              )
            )
          ]
        ),
        needBottomLine ? _buildBottomLine() : SizedBox.shrink()
      ]
    );
  }else{
    return SizedBox.shrink();
  }
}

_buildMultiLineTexts(String title, String? text, int maxLines, {bool decodeHtml = false, bool needTopSpacing = false, bool needBottomLine = true}){
  if(null == text || text.isEmpty || text.trim().isEmpty || "%" == text.trim()) {
    return SizedBox.shrink();
  }

  if(decodeHtml){
    text = HtmlUnescape().convert(text);
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      needTopSpacing ? _buildRowSpacing() : SizedBox.shrink(),
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: TITLE_COLUMN_RATIO,
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xff9397a2))
            )
          ),
          Container(width: columnSpacing),
          Expanded(
            flex: CONTENT_COLUMN_RATIO,
            child: Text(text, textAlign: TextAlign.left, maxLines: maxLines, style: TextStyle(fontSize: 13.sp, color: Color(0xff616161)))
          )
        ]
      ),
      needBottomLine ? _buildBottomLine() : SizedBox.shrink()
    ]
  );
}

_buildHyperlink(BuildContext context, String title, String? url, int maxLines, {bool needTopSpacing = false, bool needBottomLine = true}){
  if(null == url || url.isEmpty || url.trim().isEmpty) {
    return SizedBox.shrink();
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      needTopSpacing ? _buildRowSpacing() : SizedBox.shrink(),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: TITLE_COLUMN_RATIO,
            child: Text(title, textAlign: TextAlign.right, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xff9397a2)))
          ),
          Container(width: columnSpacing),
          Expanded(
            flex: CONTENT_COLUMN_RATIO,
            child: InkWell(
              onTap: () => showUrlWarningDialog(context, url),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.normal, color: Color(0xff616161)),
                  children: [
                    TextSpan(text: url),
                    WidgetSpan(child: Container(width: 5.w)),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Image.asset('images/link.png', width: 8.w)
                    )
                  ]
                ),
                maxLines: maxLines,
              )
            )
          )
        ]
      ),
      needBottomLine ? _buildBottomLine() : SizedBox.shrink()
    ]
  );
}

_buildTermsWidget(String? payoutTerms, {bool needTopSpacing = false, bool needBottomLine = true}){
  if(null == payoutTerms || payoutTerms.isEmpty || payoutTerms.trim().isEmpty) {
    return SizedBox.shrink();
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      needTopSpacing ? _buildRowSpacing() : SizedBox.shrink(),
      Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: TITLE_COLUMN_RATIO,
            child: Text(
              'Payout Terms',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xff9397a2))
            )
          ),
          Container(width: columnSpacing),
          Expanded(
            flex: CONTENT_COLUMN_RATIO,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildTerms(payoutTerms)
            )
          )
        ]
      ),
      needBottomLine ? _buildBottomLine() : SizedBox.shrink()
    ]
  );
}

_buildContacts(Staking_providersBean? provider, {bool needTopSpacing = false, bool needBottomLine = true}){
  if(null == provider || (null == provider.discordUsername && null == provider.telegram && null == provider.twitter && null == provider.email)) {
    return SizedBox.shrink();
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      needTopSpacing ? _buildRowSpacing() : SizedBox.shrink(),
      Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: TITLE_COLUMN_RATIO,
            child: Text(
              'Applications',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xff9397a2))
            )
          ),
          Container(width: columnSpacing),
          Expanded(
            flex: CONTENT_COLUMN_RATIO,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (provider?.discordUsername ?? '').isNotEmpty
                  ? Builder(
                  builder: (context) => InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: provider?.discordUsername ?? ''));
                      Fluttertoast.showToast(
                        msg: 'Discord user name copied into clipboard!!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1
                      );
                    },
                    child: Image.asset('images/discord.png', height: 26.h, width: 26.w,)
                  )
                ) : Container(),
                (provider?.telegram ?? '').isNotEmpty
                  ? Builder(
                  builder: (context) => InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: provider?.telegram ?? ''));
                      Fluttertoast.showToast(
                        msg: 'Telegram handle copied into clipboard!!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1
                      );
                    },
                    child: Image.asset('images/telegram.png', height: 26.h, width: 26.w)
                  )
                ) : Container(),
                (provider?.twitter ?? '').isNotEmpty
                  ? Builder(
                  builder: (context) => InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: provider?.twitter ?? ''));
                      Fluttertoast.showToast(
                        msg: 'Twitter account copied into clipboard!!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1
                      );
                    },
                    child: Image.asset('images/twitter.png', height: 26.h, width: 26.w)
                  )
                ) : Container(),
                (provider?.email ?? '').isNotEmpty
                  ? Builder(
                  builder: (context) => InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: provider?.email ?? ''));
                      Fluttertoast.showToast(
                        msg: 'Email copied into clipboard!!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                      );
                    },
                    child: Image.asset('images/mail.png', height: 26.h, width: 26.w)
                  )
                ) : Container()
              ]
            )
          )
        ]
      ),
      needBottomLine ? _buildBottomLine() : SizedBox.shrink()
    ]
  );
}

_buildTerms(String termSrc) {
  List<Widget> termWidgets = [];

  List<String> terms = termSrc.split(',');
  terms.forEach((element) {
    termWidgets.add(Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffd0d0d0), width: 0.5.w),
        borderRadius: BorderRadius.all(Radius.circular(2.w)),
        color: Colors.white24
      ),
      child: Text(
        element.trim(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Color(0xff2d2d2d)))
    ));
    termWidgets.add(Container(width: 3.w));
  });

  return termWidgets;
}