import 'dart:math';

import 'package:air_desk/pages/main_page/my_desk/desk_creation_page.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

class DeskCreationForm extends StatefulWidget {
  const DeskCreationForm({super.key});

  @override
  State<DeskCreationForm> createState() => _DeskCreationFormState();
}

class _DeskCreationFormState extends State<DeskCreationForm> {

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isGeneratingAutoCode = true;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _codeController,
              // enabled: !_isGeneratingAutoCode,
              enabled: true,
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                hintText: _isGeneratingAutoCode ? 'Auto-generated' : 'Enter code',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: .2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: .2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isGeneratingAutoCode 
                      ? Icons.lock_outline 
                      : Icons.lock_open,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGeneratingAutoCode = !_isGeneratingAutoCode;
                      if (_isGeneratingAutoCode) {
                        _codeController.clear();
                      }
                    });
                  },
                ),
              ),
              validator: (value) {
                if (!_isGeneratingAutoCode && value != null && value.isNotEmpty) {
                  if (value.length != 8) {
                    return 'Code must be 8 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'Only letters and numbers allowed';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Handle MyDesk creation
                  final code = _isGeneratingAutoCode 
                    ? _generateAutoCode() 
                    : _codeController.text;
                  print('Creating MyDesk with code: $code');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalColours(context).buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
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
}

String _generateAutoCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return String.fromCharCodes(Iterable.generate(
    8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}