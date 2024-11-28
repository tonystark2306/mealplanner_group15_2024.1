import 'package:flutter/material.dart';

class SimpleLoginScreen extends StatefulWidget {
  const SimpleLoginScreen({super.key});

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  void handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Giả lập xử lý đăng nhập
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Hiển thị thông báo sau khi đăng nhập thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đi chợ tiện lợi'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Nhập email của bạn",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.green),
                      filled: true,
                      fillColor: Colors.green[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập email";
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return "Vui lòng nhập email hợp lệ";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      hintText: "Nhập mật khẩu của bạn",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.green),
                      filled: true,
                      fillColor: Colors.green[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập mật khẩu";
                      } else if (value.length < 6) {
                        return "Mật khẩu phải có ít nhất 6 ký tự";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[700], // Nền nút
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Đăng nhập",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Optional Sign Up Prompt
                  TextButton(
                    onPressed: () {
                      // Chuyển đến màn hình đăng ký
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      "Chưa có tài khoản? Đăng ký",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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