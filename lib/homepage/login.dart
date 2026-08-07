import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eform_ldte/core/controller.dart';
import 'package:eform_ldte/misc/widget.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController c = Get.put(LoginController());
    return Obx(() => c.isLoading.value
      ? Center(child: CircularProgressIndicator()) 
      : Column(
        spacing: 24,
        children: [
          SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    labelText: 'Email',
                    errorText: c.emailE.value,
                    controller: c.email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  CustomTextField(
                    labelText: 'Password',
                    errorText: c.passwordE.value,
                    controller: c.password,
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: () => c.isObscured.value = !c.isObscured.value,
                          icon: Icon(
                            c.isObscured.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    obscureText: c.isObscured.value,
                    onSubmitted: (value) => c.signInWithPassword(),
                    autofillHints: const [AutofillHints.password],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: ElevatedButton(onPressed: c.signInWithPassword, child: Text('Login')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ));
  }
}