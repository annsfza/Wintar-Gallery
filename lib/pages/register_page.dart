import 'package:flutter/material.dart';
import 'package:Wintar_Gallery/helpers/database_helper.dart';
import 'package:Wintar_Gallery/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    setState(() => _isLoading = true);

    String name = nameController.text.trim();
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      _showDialog("Error", "Semua kolom harus diisi!");
      setState(() => _isLoading = false);
      return;
    }

    final response = await DatabaseHelper.instance.registerUser(
      name: name,
      username: username,
      email: email,
      password: password,
    );

    setState(() => _isLoading = false);

    if (response['success']) {
      _showDialog("Sukses", "Registrasi berhasil!", isSuccess: true);
    } else {
      _showDialog("Error", response['message']);
    }
  }

  void _showDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSuccess ? Colors.green : Colors.red,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_rounded, size: 100, color: Colors.black),
                  SizedBox(height: 20),
                  Text(
                    "Buat Akun",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 40),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildTextField(nameController, "Nama", Icons.person, false),
                          SizedBox(height: 20),
                          _buildTextField(usernameController, "Username", Icons.account_circle, false),
                          SizedBox(height: 20),
                          _buildTextField(emailController, "Email", Icons.email, false),
                          SizedBox(height: 20),
                          _buildTextField(passwordController, "Password", Icons.lock, true),
                          SizedBox(height: 25),
                          _buildRegisterButton(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      "Sudah punya akun? Login",
                      style: TextStyle(color: Colors.black, fontSize: 16),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: isPassword,
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registerUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text("Daftar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}