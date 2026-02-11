import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SendButton extends ConsumerWidget {
  const SendButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final share = ref.watch(shareProvider);

    final viewText = ref.read(sendCodeControllerProvider).text;
    final shareController = ref.read(shareControllerProvider);

    final sendToDesk = ref.watch(viewProvider).changeControllerState;


    const spinKit = SpinKitThreeBounce(
      color: Colors.white,
      size: 15,
    );

    final deskExists = ref.watch(deskNotifierProvider).deskExists;
    final color = sendToDesk ? deskExists == true? primaryBlue : Colors.red : (share.isEdit ? const Color(0xff069383) : primaryBlue);


    return Positioned(
      right: 15,
      bottom: -15,
      child: GestureDetector(
    onTap: share.isLoading ? null : () async {
      FocusScope.of(context).unfocus();
      debugPrint("Sending Data");
      if(shareController.text.isNotEmpty
          || share.files.isNotEmpty
          || share.editFiles.isNotEmpty
          || (shareController.text.isEmpty && viewText.isNotEmpty && viewText.length == 6)
      ) {
        ref.read(shareProvider.notifier).submit();
        // if(shareProvider.isEdit) {
        //   await shareProvider.updateEdit(context);
        // } else {
        //   await shareProvider.postData(context, rp.sharedFiles);
        // }
      }
    },
    child: share.isLoading
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
      )
    );
  }
}