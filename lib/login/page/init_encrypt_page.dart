import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:allpass/core/param/config.dart';
import 'package:allpass/setting/theme/theme_provider.dart';
import 'package:allpass/common/ui/allpass_ui.dart';
import 'package:allpass/util/encrypt_util.dart';
import 'package:allpass/util/navigation_util.dart';


class InitEncryptPage extends StatefulWidget {

  @override
  State createState() {
    return _InitEncryptPage();
  }
}

class _InitEncryptPage extends State<InitEncryptPage> {

  TextEditingController controller = TextEditingController(text: "生成后的密钥显示在此");
  bool inGen = false;
  bool haveGen = false;
  String _latestKey;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: AllpassEdgeInsets.listInset,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: AllpassEdgeInsets.smallTBPadding,
                  child: Text("请仔细阅读", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ),
                Padding(
                  padding: AllpassEdgeInsets.smallTBPadding,
                  child: Text("Allpass 1.5.0及以后使用了新的密钥存储方式", textAlign: TextAlign.center,),
                ),
                Padding(
                  padding: AllpassEdgeInsets.smallTBPadding,
                  child: Text("Allpass会对每一个用户生成独一无二的密钥并将其存储到系统特定的区域中，"
                      "这意味着即使反编译了Allpass并通过某些方法获取到了数据库中的数据，也无法轻易破解", textAlign: TextAlign.center,),
                ),
                Padding(
                  padding: AllpassEdgeInsets.smallTBPadding,
                  child: Text("密码的加密和解密将依赖此密钥，请妥善保管此密钥", textAlign: TextAlign.center,),
                ),
                Padding(
                  padding: AllpassEdgeInsets.smallTBPadding,
                  child: Text("如果您进行了WebDAV同步，即使卸载了Allpass并且备份文件中密码已加密，仍然可以通过密钥找回数据", textAlign: TextAlign.center,),
                ),
                Padding(
                  padding: AllpassEdgeInsets.smallTBPadding,
                  child: Text("如果因为意外原因导致尚未生成密钥便退出了Allpass，Allpass仍然会生成一个默认密钥，但是建议您重新注册"),
                ),
                Padding(
                  padding: AllpassEdgeInsets.smallTBPadding,
                  child: Text("如果您之前使用过Allpass（即V1.5.0之前版本）进行WebDAV同步过，并且此次使用需要找回之前备份的数据，"
                      "那么请直接点击下面的“默认密钥”按钮，使用WebDAV找回密码后再进行密钥升级（设置-主账号管理-加密密钥更新）。"
                      "一旦点击了“生成”按钮，需要清除Allpass数据后再按此步骤操作！"),
                ),
                Padding(
                  padding: AllpassEdgeInsets.smallTBPadding,
                  child: Text("请点击下面的按钮生成密钥", textAlign: TextAlign.center,),
                ),
                Padding(padding: AllpassEdgeInsets.smallTBPadding,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      color: Provider.of<ThemeProvider>(context).lightTheme.primaryColor,
                      child: haveGen
                          ? Text("重新生成", style: TextStyle(color: Colors.white))
                          : (inGen
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          strokeWidth: 2.3,
                        ),)
                          : Text("点击生成", style: TextStyle(color: Colors.white),)),
                      onPressed: () async {
                        setState(() {
                          inGen = true;
                        });
                        _latestKey = await EncryptUtil.initEncrypt(needFresh: true);
                        setState(() {
                          haveGen = true;
                          inGen = false;
                          controller.text = _latestKey;
                        });
                      },
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10),),
                    FlatButton(
                      color: haveGen
                          ? Provider.of<ThemeProvider>(context).lightTheme.primaryColor
                          : Colors.grey,
                      child: Text("去登录", style: TextStyle(color: Colors.white),),
                      onPressed: () async {
                        if (!haveGen) {
                          Fluttertoast.showToast(msg: "请先生成密钥");
                        } else {
                          EncryptHolder holder = EncryptHolder(EncryptUtil.initialKey);
                          Config.setPassword(EncryptUtil.encrypt(holder.decrypt(Config.password)));
                          NavigationUtil.goLoginPage(context);
                        }
                      },
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10),),
                    FlatButton(
                      color: haveGen
                          ? Colors.grey
                          : Provider.of<ThemeProvider>(context).lightTheme.primaryColor,
                      child: Text("默认密钥", style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        if (haveGen) {
                          Fluttertoast.showToast(msg: "您已点击了生成按钮，若要使用默认密钥，请清除Allpass数据后再进行此操作");
                          return;
                        }
                        Fluttertoast.showToast(msg: "使用默认密钥");
                        NavigationUtil.goLoginPage(context);
                      },
                    )
                  ],
                ),
                TextField(controller: controller, textAlign: TextAlign.center, onChanged: (_) {
                  Fluttertoast.showToast(msg: "此页面编辑密钥无效");
                },)
              ],
            ),
          ),
        )
    );
  }
}