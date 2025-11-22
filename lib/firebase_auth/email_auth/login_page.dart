import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/firebase_auth/email_auth/provider/user_hive_provider.dart';
import 'package:task_tracker/firebase_auth/email_auth/registration_page.dart';
import 'package:task_tracker/pages/home_page/home_page.dart';
import '../../date_time_helper/date_time_helper.dart';
import '../../utils/constant/app_colors.dart';
import '../google_auth/google_auth_service.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  /// >>> Helper Text & Icon Here
  Icon emailIcon = Icon(Icons.email,color: AppColors.appInputFieldUnActiveColor, size: 15,);
  Icon passIcon = Icon(Icons.password,color: AppColors.appInputFieldUnActiveColor, size: 15,);
  Icon otpIcon = Icon(Icons.pin,color: AppColors.appInputFieldUnActiveColor, size: 15,);
  String emailHelperText = "Example : prothes19@gmail.com";
  String passHelperText = "At least 8 chars, Example : Prothes@123";
  String otpHelperText = "Example : 123456";


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }


  /// >>> Show Popup After Login ===============================================
  void showMessage(String message, bool flag){
   showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(flag ? "Successful" : "Failed"),
        content: Text(message),
        actions: [ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text("OK"))],
      ),
    );
  }
  /// <<< Show Popup After Login ===============================================

  /// >>> Navigate Home Page ===================================================
  void _navigateHomePage(){
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,);
  }
  /// <<< Navigate Home Page ===================================================

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
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60.0,left: 10.0,right: 10.0,bottom: 10.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: kToolbarHeight),





                              /// >>> Form Title Start Here ====================
                              Text("Login Form",style:TextStyle(color: AppColors.primaryColor,fontSize: 30,fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                              SizedBox(height: 50,),
                              /// <<< Form Title End Here ======================


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
                              SizedBox(height: 20,),
                              /// <<< Email Field End Here =====================


                              /// >>> Password Field Start Here ================
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                  fillColor: Colors.white.withValues(alpha: 0.3),
                                  filled: true,
                                  prefixIcon: Icon(Icons.password_outlined),
                                  prefixIconColor: AppColors.appInputFieldActiveColor,
                                  labelStyle: TextStyle(color: AppColors.appInputFieldUnActiveColor),
                                  floatingLabelStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                  border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldUnActiveColor)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldActiveColor)),
                                  helper: Row(children: [passIcon, SizedBox(width: 5,), Text(passHelperText,style: TextStyle(color : AppColors.appInputFieldUnActiveColor),)],),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.appInputFieldActiveColor,),
                                    onPressed: () {
                                      setState(() {_obscurePassword = !_obscurePassword;});
                                    },
                                  ),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                maxLength: 22,
                                cursorColor: AppColors.appInputFieldActiveColor,
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                onChanged: (value){
                                  setState(() {
                                    if (value.length >= 8 && RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*{}()\\.+=?/_-]).{8,}$').hasMatch(value)){
                                      passHelperText = "Valid Password";
                                      passIcon = Icon(Icons.verified,color: Colors.green, size: 15,);
                                    }else{
                                      passHelperText = "";
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Field is Empty";
                                  }
                                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                    return "Must contain at least one uppercase letter (A-Z)";
                                  }
                                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                                    return "Must contain at least one lowercase letter (a-z)";
                                  }
                                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                                    return "Must contain at least one number (0-9)";
                                  }
                                  if (!RegExp(r'[!@#$%^&*{}()\\.+=?/_-]').hasMatch(value)) {
                                    return "Must contain at least one Symbol";
                                  }
                                  if (value.length < 8) {
                                    return "Password must be at least 8 characters long";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20,),
                              /// <<< Password Field End Here ==================


                              /// >>> Registration Button Start Here ===========
                              ElevatedButton(
                                  onPressed: isLoading? null :() async{
                                    FocusScope.of(context).unfocus();
                                    if(_formKey.currentState!.validate()){
                                      String email = emailController.text.trim();
                                      String password = passwordController.text.trim();
                                      setState(() {isLoading = true;});
                                      try{
                                        final userProvider = Provider.of<UserHiveProvider>(context, listen: false);

                                        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                                        final uid = userCredential.user!.uid;
                                        final getUserData = await FirebaseFirestore.instance.collection("users").doc(uid).get();
                                        if (getUserData.exists) {
                                          final data = getUserData.data()!;
                                          String name = data["name"] ?? "";
                                          String phone = data["phone"] ?? "";
                                          String emailFromDB = data["email"] ?? email;
                                          Timestamp ts = data['createAt'] ?? "";
                                          String createAt = DateTimeHelper.formatDateTime(ts.toDate());
                                          await userProvider.updateUser(uid: uid, name: name, phone: phone, email: emailFromDB, createAt : createAt,regLoginFlag: true,);
                                        }
                                        if(!mounted) return;
                                        _navigateHomePage();
                                        showMessage("Successfully Login", true);
                                      }on FirebaseAuthException catch(err){
                                        String message = err.message ?? "Login failed!";
                                        if (err.code == 'user-not-found') {
                                          message = "Email not registered!";
                                        } else if (err.code == 'wrong-password' || err.code == 'invalid-credential') {
                                          message = "Incorrect Email or Password!";
                                        }
                                        showMessage(message, false);
                                      }finally{
                                        if (mounted) setState(() { isLoading = false; });
                                      }
                                    }
                                  },
                                  child: isLoading?Padding(padding: EdgeInsets.all(10.0), child: Text("Wait..",style: TextStyle(fontSize: 20,color: Colors.white.withValues(alpha: 0.5)),),):Padding(padding: EdgeInsets.all(10.0), child: Text("Login",style: TextStyle(fontSize: 20),),)
                              ),
                              /// <<< Registration Button End Here =============


                              /// >>> =============== IF You New User So Registration Here =================
                              SizedBox(height: 25,),
                              InkWell(
                                onTap:()=>Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => RegistrationPage()), (Route<dynamic> route) => false,),
                                child: Text("New User? Registration",style: TextStyle(color: AppColors.primaryColor),),
                              ),
                              /// <<< =============== IF You New User So Registration Here =================

                              /// >>> =============== IF You New User So Registration Here =================
                              SizedBox(height: 15,),
                              InkWell(
                                onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage(),)),
                                child: Text("Forgot Password",style: TextStyle(color: AppColors.primaryColor),),
                              ),
                              /// <<< =============== IF You New User So Registration Here =================



                              /// >>> Login With Google ========================
                              ElevatedButton(
                                onPressed: () async {
                                  final userCred = await GoogleLoginService().signInWithGoogleFirebase();
                                  if (userCred != null) {
                                    final user = userCred.user;
                                    debugPrint("\n================ USER FULL DATA ================\n");
                                    // Basic Info
                                    debugPrint("UID: ${user?.uid}");
                                    debugPrint("Display Name: ${user?.displayName}");
                                    debugPrint("Email: ${user?.email}");
                                    debugPrint("Phone Number: ${user?.phoneNumber}");
                                    debugPrint("Photo URL: ${user?.photoURL}");
                                    debugPrint("Is Email Verified: ${user?.emailVerified}");
                                    debugPrint("Is Anonymous: ${user?.isAnonymous}");
                                    // Provider Data (Correct Way)
                                    debugPrint("Provider Count: ${user?.providerData.length}");
                                    if (user!.providerData.isNotEmpty) {
                                      debugPrint("Primary Provider ID: ${user.providerData.first.providerId}");
                                    }
                                    // Metadata
                                    debugPrint("Creation Time: ${user.metadata.creationTime}");
                                    debugPrint("Last Sign-In Time: ${user.metadata.lastSignInTime}");
                                    // Multi-Provider Details
                                    debugPrint("\n------ Provider Data List ------");
                                    for (var info in user.providerData) {
                                      debugPrint("Provider: ${info.providerId}");
                                      debugPrint("UID: ${info.uid}");
                                      debugPrint("Display Name: ${info.displayName}");
                                      debugPrint("Email: ${info.email}");
                                      debugPrint("Phone: ${info.phoneNumber}");
                                      debugPrint("Photo URL: ${info.photoURL}");
                                      debugPrint("----------------");
                                    }
                                    // Tenant ID
                                    debugPrint("Tenant ID: ${user.tenantId}");
                                    // ID Token
                                    final idToken = await user.getIdToken();
                                    debugPrint("ID Token: $idToken");
                                    // Token Details
                                    final tokenResult = await user.getIdTokenResult();
                                    debugPrint("\n------ Token Result Details ------");
                                    debugPrint("Auth Time: ${tokenResult.authTime}");
                                    debugPrint("Expiration Time: ${tokenResult.expirationTime}");
                                    debugPrint("Issued At Time: ${tokenResult.issuedAtTime}");
                                    debugPrint("Sign-In Provider: ${tokenResult.signInProvider}");
                                    debugPrint("Claims: ${tokenResult.claims}");

                                    debugPrint("\n================ END USER DATA ================");
                                  } else {
                                    debugPrint("Google Sign-In cancelled or failed");
                                  }
                                },
                                child: Text("Continue with google")
                            ),
                              ElevatedButton(
                              onPressed: () {
                                
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.shade400, width: 1,),),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset("assets/icon/google.png", height: 24, width: 24,),
                                  const SizedBox(width: 12),
                                  const Text("Sign in with Google", style: TextStyle(fontSize: 16,),),
                                ],
                              ),
                            )
                            /// <<< Login With Google ========================

                          ],
                        )
                    ),
                  ),
                ),
                if (isLoading)
                  Positioned(
                    top: 0,
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
