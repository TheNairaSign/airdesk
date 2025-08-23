import 'package:air_desk/pages/main_page/my_desk/desk_creation_page.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:blurbackground/blurbackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void showCreationDialog(BuildContext context) {

  showDialog(
    context: context,
    builder: (context) {
      return CreationDialog();
    },
  );
}

class CreationDialog extends StatelessWidget {
  CreationDialog({super.key});

  final _globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final myDeskProvider = Provider.of<MyDeskProvider>(context, listen: false);
    
    return BlurBackground(
      blurX: 5,
      blurY: 5,
      child: AlertDialog(
        backgroundColor: GlobalColours(context).containerColor,
        icon: Consumer<MyDeskProvider>(
          builder: (context, myDesk, child) {
            return Row(
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
                else if (myDesk.createDeskController.text.length == 8 && myDesk.deskExists == true)...[
                  const SizedBox(width: 5),
                  Text('(@${myDesk.createDeskController.text} already exists)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red)),
                ]
              ],
            );
          }
        ),
        title: const ChooseYourCodeContainer(),
        content: Form(
          key: _globalKey,
          child: const CreationForm()
        ),
        actions: [ 
          CreateButton(() async {
            if (_globalKey.currentState!.validate()) {
              FocusScope.of(context).unfocus();
              await myDeskProvider.createDesk(context);
            }
          }) 
        ],
      ),
    );
  }
}

class CreationForm extends StatefulWidget {
  const CreationForm({super.key});

  @override
  State<CreationForm> createState() => _CreationFormState();
}

class _CreationFormState extends State<CreationForm> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyDeskProvider>(
      builder: (context, myDeskProvider, child) {
        return TextFormField(
          errorBuilder: (context, errorText) => Text(myDeskProvider.errorMessages(), style: const TextStyle(color: Colors.red),),
          controller: myDeskProvider.createDeskController,
          // enabled: !_isGeneratingAutoCode,
          onChanged: (value) {
            setState(() {
              myDeskProvider.updateValidity(value);
              if (value.length == 8) {
                myDeskProvider.checkDesk(context, value);
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
    );
  }
}

class CreateButton extends StatefulWidget {
  const CreateButton(this.onPressed, {super.key});
  final VoidCallback? onPressed;

  @override
  State<CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<CreateButton> {
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Consumer<MyDeskProvider>(
        builder: (context, myDeskProvider, child) {
          return ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: myDeskProvider.deskNameValid ? GlobalColours(context).buttonColor : Colors.grey,
              disabledBackgroundColor: Colors.grey,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: myDeskProvider.createLoading 
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
          );
        }
      ),
      );
  }
}