import 'package:expense_tracker/auth/auth_service.dart';
import 'package:expense_tracker/components/my_button2.dart';
import 'package:expense_tracker/components/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // login method
  void login() async {
    //get the instance of auth service
    final authService = AuthService();

    //try sign in
    try {
      await authService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
    }
    //display any errors
    catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      "Welcome back",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Sign in to continue tracking your expenses.",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          //email textfield
                          MyTextfield(
                            controller: emailController,
                            hintText: 'you@email.com',
                            labelText: 'Email',
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.mail_outline,
                            autofillHints: const [AutofillHints.email],
                          ),

                          const SizedBox(height: 14),

                          //password textfield
                          MyTextfield(
                            controller: passwordController,
                            hintText: '••••••••',
                            labelText: 'Password',
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.lock_outline,
                            autofillHints: const [AutofillHints.password],
                          ),

                          const SizedBox(height: 20),

                          //sign in
                          MyButton2(text: 'Sign In', onTap: login),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not registered?",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Create account",
                            style: TextStyle(
                              color: Color(0xFF1B3A57),
                              fontWeight: FontWeight.w700,
                            ),
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
      ),
    );
  }
}
