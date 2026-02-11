import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:blurbackground/blurbackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showAccessDialog(BuildContext context, {String? code}) {

  showDialog(
    context: context,
    builder: (context) {
      return AccessDialog(code: code);
    },
  );
}

class AccessDialog extends ConsumerStatefulWidget {
  const AccessDialog({super.key, this.code});
  final String? code;

  @override
  ConsumerState<AccessDialog> createState() => _AccessDialogState();
}

class _AccessDialogState extends ConsumerState<AccessDialog> {

  final _globalKey = GlobalKey<FormState>();

  TextEditingController accessDeskController = TextEditingController();

  @override
  initState() {
    super.initState();
    debugPrint('AccessDialog initState');
    if (widget.code != null) {
      debugPrint(widget.code);
      accessDeskController.text = widget.code!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myDesk = ref.read(myDeskProvider.notifier);
    final isLoading = ref.watch(myDeskProvider).accessLoading;
    

    const loadingSpinkit = SpinKitRing(
      color: Colors.white,
      size: 20.0,
      lineWidth: 2,
    );

    return BlurBackground(
      blurX: 5,
      blurY: 5,
      child: AlertDialog(
        backgroundColor: GlobalColours(context).containerColor,
        icon: Text(
          'Access MyDesk',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GlobalColours(context).textColorForContainer
          ),
        ),
        title: Text(
          'Enter your admin access code',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        content: Form(
              key: _globalKey,
              child: TextFormField(
                cursorColor: Colors.blue,
                obscureText: false,
                controller: accessDeskController,
                onChanged: (value) {
                    myDesk.storeAccessCode(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter your admin access code',
                  // hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: .2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: .2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: .2),
                ),
                errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),

                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                cursorErrorColor: Colors.red,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your access code';
                  } else if (value.length < 6) {
                    return 'Access code must be at least 6 characters long';
                  }
                  return null;
                },
              ),
            ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_globalKey.currentState!.validate()) {
                  FocusScope.of(context).unfocus();
                  myDesk.getCreatorDesks();
                } else {
                  debugPrint('Validation failed');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalColours(context).buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading ? Center(
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    loadingSpinkit,
                    const SizedBox(width: 10),
                    Text('Accessing', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),)
                  ],
                ),
              )
              : Text(
                'Access MyDesk',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}