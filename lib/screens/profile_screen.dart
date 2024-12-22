import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountUsernameController = TextEditingController();
  final TextEditingController _accountPasswordController = TextEditingController();

  Future<List<Map<String, dynamic>>> _fetchAccounts() async {
    final dbHelper = DBHelper();
    return await dbHelper.getAccounts(widget.userId);
  }

  Future<void> _addAccount() async {
    if (_accountNameController.text.isEmpty ||
        _accountUsernameController.text.isEmpty ||
        _accountPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    final dbHelper = DBHelper();
    final result = await dbHelper.createAccount(
      widget.userId,
      _accountNameController.text,
      _accountUsernameController.text,
      _accountPasswordController.text,
    );

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account added successfully!')),
      );
      _accountNameController.clear();
      _accountUsernameController.clear();
      _accountPasswordController.clear();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add account!')),
      );
    }
  }

  Future<void> _deleteAccount(int accountId) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteAccount(accountId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form untuk menambahkan akun baru
            TextField(
              controller: _accountNameController,
              decoration: InputDecoration(labelText: 'Account Name'),
            ),
            TextField(
              controller: _accountUsernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _accountPasswordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _addAccount,
              child: Text('Add Account'),
            ),
            SizedBox(height: 20),

            // Daftar akun yang dikelola
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>( 
                future: _fetchAccounts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No accounts found.'));
                  }

                  final accounts = snapshot.data!;
                  return ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return ListTile(
                        title: Text(account['account_name']),
                        subtitle: Text(account['username']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteAccount(account['id']);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
