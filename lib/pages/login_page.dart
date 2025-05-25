import 'package:flutter/material.dart';
import 'package:food_express/components/my_button.dart';
import 'package:food_express/components/my_textfield.dart';

import 'home_page.dart';


class LoginPage extends  StatefulWidget {
      final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
// text editing controller 
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

// login method 
void login() {
  /*

  fill out authentication 


  */

  // navigate to home page 
  Navigator.push(context, MaterialPageRoute(
    builder: (context) => const HomePage(),
    ),
     );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                "Food Delivery App",
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

                  const SizedBox(height: 25),
                // sign in button 
              MyButton(
                text: "Sign In", 
                onTap: login,
                ),

               const SizedBox(height: 25),
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account ?", 
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary
                  ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text("Sign up now",
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