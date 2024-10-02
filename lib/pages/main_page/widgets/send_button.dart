import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../providers/share_provider.dart';

class SendButton extends StatelessWidget {
  const SendButton({super.key});

  
  @override
  Widget build(BuildContext context) {
    
    const spinKit = SpinKitThreeBounce(
    color: Colors.white,
    size: 15,
  );

    return Consumer<ShareProvider>(
      builder: (context, shareProvider, child) {
        return Positioned(
          right: 30,
          bottom: -25,
          child: GestureDetector(
            onTap: shareProvider.isLoading ? null : () async {
              debugPrint("Sending Data");
              await shareProvider.postData(context);
            },
            child: shareProvider.isLoading
                ? Container(
                    height: 35,
                    width: 60,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: spinKit,
                  )
                : Container(
                    padding: const EdgeInsets.all(13),
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryBlue,
                    ),
                    child: SvgPicture.asset("assets/svg/paper-plane.svg"),
                  ),
          ),
        );
      }
    );
  }
}