import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../utils/encryption.dart';
import 'profile_screen.dart'; // Pastikan ProfileScreen sudah ada

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username and Password are required!')),
      );
      return;
    }

    final db = await DBHelper().database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [_usernameController.text],
    );

    if (result.isNotEmpty) {
      final userData = result.first;
      final decryptedPassword = EncryptionHelper.decryptPassword(
        _usernameController.text,
        userData['password'] as String, // Convert to String explicitly
      );

      if (decryptedPassword == _passwordController.text) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: userData['id'] as int), // Assuming 'id' is an int
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid password!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}
