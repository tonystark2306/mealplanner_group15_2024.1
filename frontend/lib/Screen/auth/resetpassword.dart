import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  void handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      // Ở đây bạn sẽ thêm logic đặt lại mật khẩu
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đặt lại mật khẩu thành công!")),
      );
      Navigator.pushNamed(context, '/login');
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/reset_password_icon.png',
                  height: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  "Đặt lại mật khẩu",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: passwordController,
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu mới",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập mật khẩu mới";
                    } else if (value.length < 6) {
                      return "Mật khẩu phải có ít nhất 6 ký tự";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _isConfirmPasswordHidden,
                  decoration: InputDecoration(
                    labelText: "Xác nhận mật khẩu mới",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordHidden
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng xác nhận mật khẩu";
                    } else if (value != passwordController.text) {
                      return "Mật khẩu không khớp";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Đặt lại mật khẩu",
                    style: TextStyle(fontSize: 16),
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