import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String name = "";
  int currentBalance = 0;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Dashboard"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(fontSize: 50),
              ),
            ),
            const SizedBox(height: 20),
            Text("Welcome $name"),
            const SizedBox(height: 10),
            const Text("Current Balance"),
            Text("KES $currentBalance"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: _buildWithdrawBottomSheet,
                      );
                    },
                    child: const Text("Withdraw")),
                const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: _buildDepositBottomSheet,
                      );
                    },
                    child: const Text("Deposit")),
              ],
            )
          ],
        ),
      ),
    );
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    setState(() {
      name = prefs.getString("username") ?? "";
    });
    final url = Uri.parse("http://176.58.110.189:8085/users/v1/balance");
    try {
      final response =
          await http.get(url, headers: {"Authorization": "Bearer $token"});
      final data = json.decode(response.body);
      print("Balance ${data["results"]["balance"]}");
      setState(() {
        currentBalance = data["results"]["balance"];
      });
    } catch (e) {
      print("Error while fetching wallet balance: ${e.toString()}");
    }
  }

  Widget _buildWithdrawBottomSheet(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Text("Are you sure you want to withdraw $currentBalance?"),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _withdraw, child: const Text("CONFIRM")),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildDepositBottomSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text("Enter the Amount you wish to deposit"),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            ElevatedButton(onPressed: _deposit, child: const Text("DEPOSIT")),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void _withdraw() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final url = Uri.parse("http://176.58.110.189:8085/users/v1/withdraw");
    try {
      final response = await http.post(
        url,
        body: {
          "amount": "$currentBalance",
        },
        headers: {"Authorization": "Bearer $token"},
      );
      print(response.body);
      final data = json.decode(response.body);
      final bool isSuccess = data["status"];
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          content: Text(data["message"]),
        ),
      );
      _loadData();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error while withdrawing: ${e.toString()}");
    }
  }

  void _deposit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final url = Uri.parse("http://176.58.110.189:8085/users/v1/deposit");
    try {
      final response = await http.post(
        url,
        body: {
          "amount": _amountController.text,
        },
        headers: {"Authorization": "Bearer $token"},
      );
      print(response.body);
      final data = json.decode(response.body);
      final bool isSuccess = data["status"];
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          content: Text(data["message"]),
        ),
      );
      _loadData();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error while withdrawing: ${e.toString()}");
    }
  }
}
