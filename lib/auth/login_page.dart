import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginController = Provider.of<LoginController>(context, listen: false);
    final TextEditingController stambukController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        color: Colors.green,
        child: Center(
          child: Consumer<LoginController>(
            builder: (context, controller, _) {
              return controller.isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      width: 600,
                      height: 500,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/ikpmlogoonly.png',
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: stambukController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Stambuk',
                              prefixIcon: const Icon(Icons.person, color: Colors.green),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock, color: Colors.green),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                loginController.handleLogin(
                                  stambukController.text.trim(),
                                  passwordController.text.trim(),
                                  context,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text('Login', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              loginController.navigateToRegister(context);
                            },
                            child: const Text('Belum punya akun? Daftar di sini',
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}