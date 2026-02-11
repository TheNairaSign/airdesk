import 'package:air_desk/pages/main_page/my_desk/desk_creation_page.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:blurbackground/blurbackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

void showCreationDialog(BuildContext context) {

  showDialog(
    context: context,
    builder: (context) {
      return CreationDialog();
    },
  );
}

class CreationDialog extends ConsumerWidget {
  CreationDialog({super.key});

  final _globalKey = GlobalKey<FormState>();

  final creationController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myDesk = ref.watch(myDeskProvider);
    
    return BlurBackground(
      blurX: 5,
      blurY: 5,
      child: AlertDialog(
        backgroundColor: GlobalColours(context).containerColor,
        icon: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Create MyDesk', style: Theme.of(context).textTheme.bodyLarge),

            if (myDesk.checkingDesk) ... [
              const SizedBox(width: 5),
              const SizedBox(
                height: 7,
                width: 7,
                child: CircularProgressIndicator(color: Colors.green, strokeWidth: 1)
              )
            ]
            else if (creationController.text.length == 8 && myDesk.deskExists == true)...[
              const SizedBox(width: 5),
              Text('(@${creationController.text} already exists)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red)),
            ]
          ],
        ),
        title: const ChooseYourCodeContainer(),
        content: Form(
          key: _globalKey,
          child: CreationForm(controller: creationController,)
        ),
        actions: [ 
          CreateButton(() async {
            if (_globalKey.currentState!.validate()) {
              FocusScope.of(context).unfocus();
              await ref.read(myDeskProvider.notifier).createDesk(creationController.text);
            }
          }) 
        ],
      ),
    );
  }
}

class CreationForm extends ConsumerStatefulWidget {
  const CreationForm({super.key, required this.controller});
  final TextEditingController controller;

  @override
  ConsumerState<CreationForm> createState() => _CreationFormState();
}

class _CreationFormState extends ConsumerState<CreationForm> {
  @override
  Widget build(BuildContext context) {
    final myDesk = ref.watch(myDeskProvider.notifier);
    return TextFormField(
          errorBuilder: (context, errorText) => Text(myDesk.errorMessages(errorText), style: const TextStyle(color: Colors.red),),
          controller: widget.controller,
          // enabled: !_isGeneratingAutoCode,
          onChanged: (value) {
            setState(() {
              myDesk.updateValidity(value);
              if (value.length == 8) {
                myDesk.checkDesk(value);
              }
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: .2),
            )
          ),
          validator: (value) {
            return null;
          
            // debugPrint('Validator value: $value');
            // if (value != null && value.length == 6) {
            //   myDeskProvider.checkDesk(context, value);

            //   if (myDeskProvider.deskExists) {
            //     debugPrint('Validator checking desk name and desk exists');
            //     return 'Desk name exists';
            //   }
            // }
            // return null;
          }
    );
  }
}

class CreateButton extends ConsumerStatefulWidget {
  const CreateButton(this.onPressed, {super.key});
  final VoidCallback? onPressed;

  @override
  ConsumerState<CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends ConsumerState<CreateButton> {
  @override
  Widget build(BuildContext context) {
    final myDesk = ref.watch(myDeskProvider);
    return  Center(
      child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: myDesk.deskNameValid ? GlobalColours(context).buttonColor : Colors.grey,
              disabledBackgroundColor: Colors.grey,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: myDesk.createLoading 
              ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white)
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Creating...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ) 
              : Text(
                'Create MyDesk',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
            ),
          )
      );
  }
}