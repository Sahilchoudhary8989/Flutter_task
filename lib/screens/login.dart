// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:productify/screens/home/home_screen.dart';
import 'package:productify/screens/utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    try {
      setState(() {
        _loading = true;
      });
      if (!_formKey.currentState!.validate()) {
        throw "Email and Password are required";
      }

      String email = _emailController.text;
      String password = _passwordController.text;

      debugPrint("Email: $email");
      debugPrint("Password: $password");

      final response = await http.post(
        Uri.parse("https://reqres.in/api/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      debugPrint(response.body);
      if (response.statusCode != 200) {
        throw "Invalid email or password";
      }

      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString("productify-token", data["token"]);

      // showSnackBar(
      //   context: context,
      //   title: "Login successfull",
      //   duration: 1000,
      // );

      setState(() {
        _loading = false;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const HomeScreen();
        }));
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      debugPrint(e.toString());
      showSnackBar(
          context: context, title: e.toString(), duration: 1000, type: "error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // heightSpace(getHeight(context, 10)),
                  Image.asset(
                    "assets/login.jpeg",
                    width: getWidth(context, 100),
                    height: 300,
                    fit: BoxFit.fill,
                  ),
                  heightSpace(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      widthSpace(getWidth(context, 10)),
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  heightSpace(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      widthSpace(20),
                      SizedBox(
                        width: getWidth(context, 70),
                        child: TextFormField(
                          controller: _emailController,
                          textAlign: TextAlign.start,
                          cursorColor: Colors.black,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            fillColor: Color.fromARGB(179, 255, 255, 255),
                            filled: true,
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.grey),
                            isDense: true,
                            contentPadding: EdgeInsets.all(10),
                            // hintText: hintText,
                          ),
                          validator: (value) {
                            if ((value == null || value.isEmpty)) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                  heightSpace(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.password_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      widthSpace(20),
                      SizedBox(
                        width: getWidth(context, 70),
                        child: TextFormField(
                          controller: _passwordController,
                          textAlign: TextAlign.start,
                          cursorColor: Colors.black,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            fillColor: const Color.fromARGB(179, 255, 255, 255),
                            filled: true,
                            hintText: "Password",
                            hintStyle: const TextStyle(color: Colors.grey),
                            isDense: true,
                            contentPadding: const EdgeInsets.all(10),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if ((value == null || value.isEmpty)) {
                              return "Password is required";
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                  heightSpace(10),
                  SizedBox(
                    width: getWidth(context, 80),
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  heightSpace(30),
                  SizedBox(
                    width: getWidth(context, 80),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _loading ? "Processing..." : "Login",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_loading)
                            const SizedBox(
                              width: 10,
                            ),
                          if (_loading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  heightSpace(10),
                  SizedBox(
                    width: getWidth(context, 80),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1,
                            endIndent: 10,
                          ),
                        ),
                        Text("OR"),
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  heightSpace(10),
                  Container(
                    height: 50,
                    width: getWidth(context, 80),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 211, 235, 255),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/google.png', height: 30),
                        const SizedBox(width: 10),
                        const Text("Login with Google",
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                  heightSpace(30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("New to Logistics?"),
                      GestureDetector(
                        onTap: () {
                          // Handle registration action
                        },
                        child: const Text(
                          " Register ",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
