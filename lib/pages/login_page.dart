import 'dart:convert';

import 'package:bank_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to M-Bank",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a valid password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print("On login button pressed");
                      _loginUser(
                          _usernameController.text, _passwordController.text);
                    }
                  },
                  child: const Text("LOGIN"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _loginUser(String username, String password) async {
    // http://176.58.110.189:8085/authentication/login
    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse("http://176.58.110.189:8085/authentication/login");
    try {
      final response = await http.post(url, body: {
        "username": username,
        "password": password,
      });
      final data = json.decode(response.body);
      print("Token: ${data['token']}");
      prefs.setString("token", data["token"]);
      prefs.setString("username", username);
      if (!mounted) return;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const DashboardPage()));
    } catch (e) {
      print("Error while logging in: ${e.toString()}");
    }
  }
}
