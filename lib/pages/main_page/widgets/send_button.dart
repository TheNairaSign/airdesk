import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/providers/receive_file_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SendButton extends StatelessWidget {
  const SendButton({super.key});

  @override
  Widget build(BuildContext context) {
    final deskProvider = Provider.of<ViewProvider>(context);
    final sendToDesk = deskProvider.changeControllerState;
    
    const spinKit = SpinKitThreeBounce(
      color: Colors.white,
      size: 15,
    );

    return Consumer<ShareProvider>(
      builder: (context, shareProvider, child) {
        
        final deskExists = context.watch<MyDeskProvider>().deskExists;
        final color = sendToDesk ? deskExists == true? primaryBlue : Colors.red : (shareProvider.isEdit ? const Color(0xff069383) : primaryBlue);

        return Positioned(
          right: 15,
          bottom: -15,
          child: Consumer<ReceiveFileProvider>(
            builder: (context, rp, child) {
              return GestureDetector(
                onTap: shareProvider.isLoading ? null : () async {
                  FocusScope.of(context).unfocus();
                  debugPrint("Sending Data");
                  if(shareProvider.shareController.text.isNotEmpty || shareProvider.file.isNotEmpty || rp.sharedFiles.isNotEmpty || shareProvider.editFiles.isNotEmpty) {
                    shareProvider.submit(context);
                    // if(shareProvider.isEdit) {
                    //   await shareProvider.updateEdit(context);
                    // } else {
                    //   await shareProvider.postData(context, rp.sharedFiles);
                    // }
                  }
                },
                child: shareProvider.isLoading
                  ? Container(
                      height: 35,
                      width: 60,
                      decoration: BoxDecoration(
                        color:  color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: spinKit,
                    )
                  : Container(
                      padding: const EdgeInsets.all(13),
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                      child: SvgPicture.asset("assets/svg/paper-plane.svg"),
                    ),
              );
            }
          ),
        );
      }
    );
  }
}