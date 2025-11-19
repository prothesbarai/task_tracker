import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../utils/constant/app_colors.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  /// >>> Some Initialization Start Here =======================================
  bool isLoading = false;
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  /// <<< Some Initialization End Here =========================================


  /// >>> Helper Text & Icon Here ==============================================
  Icon emailIcon = Icon(Icons.email,color: AppColors.appInputFieldUnActiveColor, size: 15,);
  String emailHelperText = "Example : prothes19@gmail.com";
  /// <<< Helper Text & Icon Here ==============================================





  /// >>> Password Reset Function ==============================================
  Future<void> _sendResetLink() async{
    setState(() {isLoading = true;});
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      setState(() {isLoading = false;});
      _showDialogueAndNavigate();
    }catch(e){
      debugPrint("Reset Error $e");
    }
  }
  /// <<< Password Reset Function ==============================================



  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }


  /// >>> Successfully Send Link Show Popup And Navigate Login Page ============
  void _showDialogueAndNavigate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Password reset link sent to your email."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  /// <<< Successfully Send Link Show Popup And Navigate Login Page ============



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,),
      body: Container(
        decoration: BoxDecoration(color: AppColors.bodyBgOverlayColor),
        height: double.infinity,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0,left: 10.0,right: 10.0,bottom: 10.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              SizedBox(height: (MediaQuery.of(context).size.height - kToolbarHeight) * 0.3,),

                              /// >>> Email Field Start Here ===================
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                  fillColor: Colors.white.withValues(alpha: 0.3),
                                  filled: true,
                                  prefixIcon: Icon(Icons.email_outlined),
                                  prefixIconColor: AppColors.appInputFieldActiveColor,
                                  labelStyle: TextStyle(color: AppColors.appInputFieldUnActiveColor),
                                  floatingLabelStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                  border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldUnActiveColor)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldActiveColor)),
                                  helper: Row(children: [emailIcon, SizedBox(width: 5,), Text(emailHelperText,style: TextStyle(color : AppColors.appInputFieldUnActiveColor),)],),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                maxLength: 50,
                                cursorColor: AppColors.appInputFieldActiveColor,
                                controller: emailController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                onChanged: (value){
                                  setState(() {
                                    if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)){
                                      emailHelperText = "Valid Email";
                                      emailIcon = Icon(Icons.verified,color: Colors.green, size: 15,);
                                    }else{
                                      emailHelperText = "";
                                    }
                                  });
                                },
                                validator: (value){
                                  if(value == null || value.trim().isEmpty){
                                    return "Field is Empty";
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)){
                                    return "Invalid Email";
                                  }
                                  return null;
                                },
                              ),
                              /// <<< Email Field End Here =====================


                              /// >>> Registration Button Start Here ===========
                              SizedBox(height: 20,),
                              ElevatedButton(
                                onPressed: isLoading? null :() async{
                                  FocusScope.of(context).unfocus();
                                  if(_formKey.currentState!.validate()){
                                    try{
                                      await _sendResetLink();
                                    }catch(err){
                                      debugPrint("Error $err");
                                    }
                                  }
                                },
                                child: isLoading ? Text("Wait..") : Text("Change Password",),
                              ),
                              /// <<< Registration Button End Here =============

                            ],
                          )
                      ),
                    ),
                  ),
                ),

                if (isLoading)
                  Positioned(
                    top: 200,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12),),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 15),
                            Text("Loading...", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,),),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
