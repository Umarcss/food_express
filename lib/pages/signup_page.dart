import 'package:flutter/material.dart';
import 'package:food_express/components/my_button.dart';
import 'package:food_express/components/my_textfield.dart';

class SignupPage extends StatefulWidget {
  final void Function()? onTap;
  
  const SignupPage({super.key, required this.onTap});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
 final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController comfirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo 
            Icon(
              Icons.lock_open_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.inversePrimary,
              ),

              const SizedBox(height: 25),

              // message, or app slogan 
              Text(
                "Let's create an account for you",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

                 const SizedBox(height: 25),

                //  email textfield 
                MyTextfield(
                  controller: emailController,
                  hintText : "email",
                  obscureText: false,
                ),

                 const SizedBox(height: 10),
                 //  password textfield 

                   MyTextfield(
                  controller: passwordController,
                  hintText : "Password",
                  obscureText: true,
                ),

                 const SizedBox(height: 10),
                 //  comfirm password textfield 

                   MyTextfield(
                  controller: comfirmPasswordController,
                  hintText : "Comfirm Password",
                  obscureText: true,
                ),

                  const SizedBox(height: 25),
                // sign Un button 
              MyButton(
                text: "Sign Up", 
                onTap: () {},
                ),

               const SizedBox(height: 25),

              // already have an account ? login 
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account ?", 
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary
                  ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text("Login now",
                     style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ],
               )
          ],
          ),
      ),
    );
  }
}