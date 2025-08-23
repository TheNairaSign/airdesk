// import 'dart:math';

import 'package:air_desk/pages/main_page/my_desk/desk_creation_page.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DeskCreationForm extends StatefulWidget {
  const DeskCreationForm({super.key});

  @override
  State<DeskCreationForm> createState() => _DeskCreationFormState();
}

class _DeskCreationFormState extends State<DeskCreationForm> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<MyDeskProvider>(
      builder: (context, myDeskProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Create MyDesk',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: GlobalColours(context).textColorForContainer
                      ),
                    ),
                    TextSpan(
                      text: '  (Choose your code)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const ChooseYourCodeContainer(),
              const SizedBox(height: 10),
              SizedBox(
                height: 45,
                child: TextFormField(
                  errorBuilder: (context, errorText) => Text(myDeskProvider.errorMessages(), style: const TextStyle(color: Colors.red),),
                  controller: myDeskProvider.createDeskController,
                  // enabled: !_isGeneratingAutoCode,
                  onChanged: (value) {
                    setState(() {
                      myDeskProvider.updateValidity(value);
                    });
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(8),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    FilteringTextInputFormatter.singleLineFormatter,
                  ],
                  enabled: true,
                  cursorColor: Colors.blue,
                  decoration: InputDecoration(
                    hintText:  'Enter code',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey, width: .2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue, width: .2),
                    ),
                  ),
                  validator: (value) {
                    // return null;
                  
                    final errorMessage = myDeskProvider.errorMessages();
                    // if (errorMessage.isNotEmpty) {
                    if (errorMessage.isNotEmpty) {
                      return errorMessage;
                    }
                    return null;
                    // // }
                  }
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (!myDeskProvider.deskNameValid) {
                      return;
                    } 

                    // if (_formKey.currentState.validate()) {
                    
                    // }
                    await myDeskProvider.createDesk(context);

                    // if (_formKey.currentState?.validate() ?? false) {
                    //   // Handle MyDesk creation
                    //   final code = _isGeneratingAutoCode 
                    //     ? myDeskProvider.generateMixedCode() 
                    //     : myDeskProvider.createDeskController.text;
                    //   print('Creating MyDesk with code: $code');
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: myDeskProvider.deskNameValid ? GlobalColours(context).buttonColor : Colors.grey,
                    disabledBackgroundColor: Colors.grey,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: myDeskProvider.isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white)
                      ) 
                    : Text(
                        'Create MyDesk',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// String _generateAutoCode() {
//   const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
//   final random = Random();
//   return String.fromCharCodes(Iterable.generate(
//     8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
// }