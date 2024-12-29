import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'OTPVerificationScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> handleForgotPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/api/user/send-verification-code'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'email': emailController.text,
          }),
        );

        final responseData = json.decode(response.body);

        if (context.mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['resultMessage']['vn']),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Navigate to OTP screen with confirm token
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(
                  email: emailController.text,
                  confirmToken: responseData['confirmToken'],
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['resultMessage']['vn']),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (error) {
        if (context.mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi kết nối đến server, vui lòng thử lại sau.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image.asset(
                    //   'assets/forgot_password_icon.png',
                    //   height: 120,
                    // ),
                    const SizedBox(height: 20),
                    Text(
                      "Quên mật khẩu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Vui lòng nhập email để đặt lại mật khẩu",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng nhập email";
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Email không hợp lệ";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoading ? null : handleForgotPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                            "Gửi yêu cầu",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white, // Chuyển màu chữ sang màu trắng
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
