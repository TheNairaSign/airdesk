import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';


class AccessMyDeskScreen extends StatelessWidget {
  const AccessMyDeskScreen({super.key});

  final loadingSpinkit = const SpinKitRing(
    color: Colors.white,
    size: 20.0,
    lineWidth: 2,
  );


  @override
  Widget build(BuildContext context) {
    return Consumer<MyDeskProvider>(
      builder: (context, myDesk, child) {
        return Container(
          padding: const EdgeInsets.all(15.0),
          margin: const EdgeInsets.symmetric(horizontal: 15).copyWith(bottom: 15),
          decoration: BoxDecoration(
            color: GlobalColours(context).containerColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              GlobalColours(context).containerShadow
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Access MyDesk',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GlobalColours(context).textColorForContainer
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your admin access code',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 45,
                child: TextField(
                  obscureText: false,
                  controller: myDesk.accessDeskController,
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    myDesk.getCreatorDesks(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColours(context).buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: myDesk.isLoading ? Center(
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
    );
  }
} 