import 'package:air_desk/pages/main_page/widgets/desk_creation_form.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

class MyDeskCreationScreen extends StatefulWidget {
  const MyDeskCreationScreen({super.key});

  @override
  State<MyDeskCreationScreen> createState() => _MyDeskCreationScreenState();
}

class _MyDeskCreationScreenState extends State<MyDeskCreationScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.symmetric(horizontal: 15).copyWith(bottom: 15),
      decoration: BoxDecoration(
        color:  GlobalColours(context).containerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          GlobalColours(context).containerShadow
        ],
      ),
      // child: const DeskCreationForm(),
    );
  }
}

class ChooseYourCodeContainer extends StatelessWidget {
  const ChooseYourCodeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    double fontSize = 10;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GlobalColours(context).chooseCodeContainer?.withOpacity(.1),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        border: BorderDirectional(
          start: BorderSide(
            color: GlobalColours(context).chooseCodeContainer!,
            width: 5,
          ),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '6-8 characters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: GlobalColours(context).chooseCodeContainer,
                fontSize: fontSize,
              ),
            ),
            TextSpan(
              text: ' • ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: GlobalColours(context).chooseCodeContainer,
                fontSize: fontSize,
              ),
            ),
            TextSpan(
              text: 'Letters and numbers only • ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GlobalColours(context).chooseCodeContainer,
                fontSize: fontSize,
              ),
            ),
            TextSpan(
              text: 'We’ll auto-complete short codes with (-)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: GlobalColours(context).chooseCodeContainer,
                fontSize: fontSize,
              ),
            ),
          ],
        ),

      ),
    );
  }
}