import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/firebase_auth/provider/user_hive_provider.dart';
import '../utils/constant/app_colors.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  /// >>> Some Initialization Start Here =======================================
  int currentStep = 1;
  bool isLoading = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phnNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  /// <<< Some Initialization End Here =========================================


  /// >>> Helper Text & Icon Here
  Icon nameIcon = Icon(Icons.person,color: AppColors.appInputFieldUnActiveColor, size: 15,);
  Icon emailIcon = Icon(Icons.email,color: AppColors.appInputFieldUnActiveColor, size: 15,);
  Icon phoneIcon = Icon(Icons.phone,color: AppColors.appInputFieldUnActiveColor, size: 15,);
  Icon passIcon = Icon(Icons.password,color: AppColors.appInputFieldUnActiveColor, size: 15,);
  Icon conPassIcon = Icon(Icons.password,color: AppColors.appInputFieldUnActiveColor, size: 15,);


  String nameHelperText = "Your Full Name";
  String emailHelperText = "Example : prothes19@gmail.com";
  String phoneHelperText = "Example : 01317818826";
  String passHelperText = "At least 8 chars, Example : Prothes@123";
  String conPassHelperText = "Re-type Password";


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phnNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }


  /// >>> Navigate Login Page ==================================================
  void _navigateLoginPage(){
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,);
  }
  /// <<< Navigate Login Page ==================================================


  /// >>> Show Popup After Registration ========================================
  void showMessage(String message, bool flag){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(flag ? "Successful" : "Failed"),
          content: Text(message),
          actions: [ElevatedButton(onPressed: (){Navigator.pop(context);flag ? _navigateLoginPage() : null; }, child: Text("OK"))],
        ),
    );
  }
  /// <<< Show Popup After Registration ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,),
        extendBodyBehindAppBar: true,
        extendBody: true,
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
                      padding: EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0,bottom: 10.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              SizedBox(height: kToolbarHeight),

                              /// >>> Form Title Start Here ====================
                              Text("Registration Form",style:TextStyle(color: AppColors.primaryColor,fontSize: 30,fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                              SizedBox(height: 50,),
                              /// <<< Form Title End Here ======================


                              /// >>> User Name Field Start Here ===============
                              if (currentStep >= 1)...[
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Full Name",
                                    hintStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    labelStyle: TextStyle(color: AppColors.appInputFieldUnActiveColor),
                                    floatingLabelStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldUnActiveColor)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldActiveColor)),
                                    prefixIcon: Icon(Icons.person),
                                    prefixIconColor: AppColors.appInputFieldActiveColor,
                                    fillColor: Colors.white.withValues(alpha: 0.3),
                                    filled: true,
                                    helper: Row(children: [nameIcon, SizedBox(width: 5,), Text(nameHelperText,style: TextStyle(color : AppColors.appInputFieldUnActiveColor),)],),
                                  ),
                                  keyboardType: TextInputType.text,
                                  maxLength: 64,
                                  cursorColor: AppColors.appInputFieldActiveColor,
                                  controller: nameController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),],
                                  onChanged: (value){
                                    setState(() {
                                      if (RegExp(r'^[a-zA-Z\s.)(]+$').hasMatch(value)){
                                        nameHelperText = "Valid Name";
                                        nameIcon = Icon(Icons.verified,color: Colors.green, size: 15,);
                                        currentStep = 2;
                                      }else{
                                        nameHelperText = "";
                                      }
                                    });
                                  },
                                  validator: (value){
                                    if(value == null || value.trim().isEmpty){
                                      return "Field is Empty";
                                    }

                                    if (!RegExp(r'^[a-zA-Z\s.)(]+$').hasMatch(value)){
                                      return "Ignore Some Special Symbol";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20,),
                              ],
                              /// <<< User Name Field End Here =================


                              /// >>> Email Field Start Here ===================
                              if (currentStep >= 2)...[
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Email",
                                    hintStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    labelStyle: TextStyle(color: AppColors.appInputFieldUnActiveColor),
                                    floatingLabelStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldUnActiveColor)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldActiveColor)),
                                    helper: Row(children: [emailIcon, SizedBox(width: 5,), Text(emailHelperText,style: TextStyle(color : AppColors.appInputFieldUnActiveColor),)],),
                                    fillColor: Colors.white.withValues(alpha: 0.3),
                                    filled: true,
                                    prefixIcon: Icon(Icons.email_outlined),
                                    prefixIconColor: AppColors.appInputFieldActiveColor,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  maxLength: 45,
                                  cursorColor: AppColors.appInputFieldActiveColor,
                                  controller: emailController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  onChanged: (value){
                                    setState(() {
                                      if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)){
                                        emailHelperText = "Valid Email";
                                        emailIcon = Icon(Icons.verified,color: Colors.green, size: 15,);
                                        currentStep = 3;
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
                              ],
                              /// <<< Email Field End Here =====================


                              /// >>> Phone Number Field Start Here ============
                              if (currentStep >= 3)...[
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Phone Number",
                                    hintStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    labelStyle: TextStyle(color: AppColors.appInputFieldUnActiveColor),
                                    floatingLabelStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldUnActiveColor)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldActiveColor)),
                                    fillColor: Colors.white.withValues(alpha: 0.3),
                                    filled: true,
                                    prefixIcon: Icon(Icons.phone),
                                    prefixIconColor: AppColors.appInputFieldActiveColor,
                                    helper: Row(children: [phoneIcon, SizedBox(width: 5,), Text(phoneHelperText,style: TextStyle(color : AppColors.appInputFieldUnActiveColor),)],),
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 11,
                                  cursorColor: AppColors.appInputFieldActiveColor,
                                  controller: phnNumberController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  onChanged: (value){
                                    setState(() {
                                      if (value.length == 11 && RegExp(r'^(01[3-9])[0-9]{8}$').hasMatch(value)){
                                        phoneHelperText = "Valid Phone Number";
                                        phoneIcon = Icon(Icons.verified,color: Colors.green, size: 15,);
                                        currentStep = 4;
                                      }else{
                                        phoneHelperText = "";
                                      }
                                    });
                                  },
                                  validator: (value){
                                    if(value == null || value.trim().isEmpty){
                                      return "Field is Empty";
                                    }
                                    if (!RegExp(r'^[0-9]+$').hasMatch(value)){
                                      return "Invalid Number";
                                    }
                                    value = value.trim().replaceAll('+', '');
                                    if (value.length != 11) {
                                      return "11 Digit Phone Number";
                                    }
                                    final pattern = RegExp(r'^(01[3-9])[0-9]{8}$');
                                    if (!pattern.hasMatch(value)) {
                                      return "Invalid Number";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20,),
                              ],
                              /// <<< Phone Number Field End Here ==============


                              /// >>> Password Field Start Here ================
                              if (currentStep >= 4)...[
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    labelStyle: TextStyle(color: AppColors.appInputFieldUnActiveColor),
                                    floatingLabelStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldUnActiveColor)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldActiveColor)),
                                    fillColor: Colors.white.withValues(alpha: 0.3),
                                    filled: true,
                                    prefixIcon: Icon(Icons.password_outlined),
                                    prefixIconColor: AppColors.appInputFieldActiveColor,
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
                                        currentStep = 5;
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
                              ],
                              /// <<< Password Field End Here ==================


                              /// >>> Confirm Password Field Start Here ========
                              if (currentStep >= 5)...[
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Confirm Password",
                                    hintStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    labelStyle: TextStyle(color: AppColors.appInputFieldUnActiveColor),
                                    floatingLabelStyle: TextStyle(color: AppColors.appInputFieldActiveColor),
                                    border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldUnActiveColor)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appInputFieldActiveColor)),
                                    fillColor: Colors.white.withValues(alpha: 0.3),
                                    filled: true,
                                    prefixIcon: Icon(Icons.password_outlined),
                                    prefixIconColor: AppColors.appInputFieldActiveColor,
                                    helper: Row(children: [conPassIcon, SizedBox(width: 5,), Text(conPassHelperText,style: TextStyle(color : AppColors.appInputFieldUnActiveColor),)],),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppColors.appInputFieldActiveColor,),
                                      onPressed: () {
                                        setState(() {_obscureConfirm = !_obscureConfirm;});
                                      },
                                    ),
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  maxLength: 22,
                                  cursorColor: AppColors.appInputFieldActiveColor,
                                  controller: confirmPasswordController,
                                  obscureText: _obscureConfirm,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  onChanged: (value){
                                    setState(() {
                                      if (value == passwordController.text && value.isNotEmpty){
                                        conPassHelperText = "Password Matched";
                                        conPassIcon = Icon(Icons.verified,color: Colors.green, size: 15,);
                                        currentStep = 6;
                                      }else{
                                        conPassHelperText = "";
                                      }
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Field is Empty";
                                    }
                                    if (value != passwordController.text) {
                                      return "Password and Confirm Password do not match";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20,),
                              ],
                              /// <<< Confirm Password Field End Here ==========


                              /// >>> Registration Button Start Here ===========
                              ElevatedButton(
                                  onPressed: isLoading || currentStep != 6 ? null :() async{
                                    FocusScope.of(context).unfocus();
                                    if(currentStep == 6 && _formKey.currentState!.validate()){

                                      String name = nameController.text.trim();
                                      String phone = phnNumberController.text.trim();
                                      String email = emailController.text.trim();
                                      String password = confirmPasswordController.text.trim();
                                      setState(() {isLoading = true;});

                                      try{
                                        final userProvider = Provider.of<UserHiveProvider>(context, listen: false);

                                        /// >>> Firebase Auth ==================
                                        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                                        String uid = userCredential.user!.uid;
                                        /// >>> Firebase Save Name & Phone =====
                                        await FirebaseFirestore.instance.collection('users').doc(uid).set({
                                          'name' : name,
                                          'phone' : phone,
                                          'email' : email,
                                          'createAt' : DateTime.now(),
                                        });

                                        /// >>> Name & Phone Locally ===========
                                        userProvider.updateUser(name: name,email: email,phone: phone);
                                        if(!mounted) return;
                                        showMessage("Successfully Registration Complete", true);
                                      }on FirebaseAuthException catch(err){
                                        String message = "Registration failed!";
                                        if (err.code == 'email-already-in-use') message = "Email already registered";
                                        showMessage(message, false);
                                      }finally{
                                        if (mounted) setState(() { isLoading = false; });
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.grey,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                  child: isLoading?Padding(padding: EdgeInsets.all(10.0), child: Text("Wait..",style: TextStyle(fontSize: 20),),):Padding(padding: EdgeInsets.all(10.0), child: Text("Registration",style: TextStyle(fontSize: 20),),)
                              ),
                              /// <<< Registration Button End Here =============


                              /// >>> =============== IF Already His / Her Account Exists so Login Here =================
                              SizedBox(height: 25,),
                              InkWell(
                                onTap:()=>_navigateLoginPage(),
                                child: Text("Already have an account ? Login",style: TextStyle(color: AppColors.primaryColor),),
                              ),
                              /// <<< =============== IF Already His / Her Account Exists so Login Here =================

                              SizedBox(height: 100,),
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
        )
    );
  }
}
