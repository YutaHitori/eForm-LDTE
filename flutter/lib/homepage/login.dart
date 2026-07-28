import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/core/controller.dart';
import 'package:ldte_stei_itb/misc/widget.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController c = Get.put(LoginController());
    return Row(
          children: [
            Obx(() => Expanded(
              child: c.isLoading.value
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
                                suffixIcon: MaterialButton(
                                  onPressed: () => c.isObscured.value = !c.isObscured.value,
                                  minWidth: 0,
                                  child: Icon(
                                    c.isObscured.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
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
                ),
              )),
          ],
    );
  }
}