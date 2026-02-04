import 'package:expense_tracker/auth/auth_service.dart';
import 'package:expense_tracker/components/my_button2.dart';
import 'package:expense_tracker/components/my_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  //register method
  void register() async {
    // get the auth service
    final _authService = AuthService();

    // check if password match create user -> create user
    if (passwordController.text == confirmPasswordController.text) {
      //try creating user
      try {
        await _authService.signUpWithEmailPassword(
          emailController.text,
          passwordController.text,
        );
      }
      //display any errors
      catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    }
    //if the password dont match
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text("Password dont match!")),
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
                  "Create account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Set up your account to start tracking.",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
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
                        hintText: 'Create a password',
                        labelText: 'Password',
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.lock_outline,
                        autofillHints: const [AutofillHints.newPassword],
                      ),

                      const SizedBox(height: 14),

                      //confirm password textfield
                      MyTextfield(
                        controller: confirmPasswordController,
                        hintText: 'Confirm password',
                        labelText: 'Confirm Password',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outline,
                        autofillHints: const [AutofillHints.newPassword],
                      ),

                      const SizedBox(height: 20),

                      //sign up
                      MyButton2(text: 'Sign Up', onTap: register),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Log in",
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
    );
  }
}
