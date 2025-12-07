import 'package:air_desk/constants.dart';
import 'package:blurbackground/blurbackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'global_colours.dart';

class UpgradePopup extends StatelessWidget {
   UpgradePopup({super.key, required this.adminCode});
   final String adminCode;

   final _emailController = TextEditingController();

   final _naira = SvgPicture.asset('assets/svg/naira.svg');

  @override
  Widget build(BuildContext context) {
    return BlurBackground(
      blurX: 5,
      blurY: 5,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: GlobalColours(context).containerColor,
        child: Padding(
          padding:  const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upgrade to AirDesk Premium",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon:  const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
               const SizedBox(height: 16),

              // Premium Card
              Container(
                width: double.infinity,
                padding:  const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      "Premium",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                     const SizedBox(height: 4),
                     Row(
                       children: [
                         SizedBox(
                           height: 15,
                           width: 15,
                           child: _naira
                         ),
                         Text(
                          "2,500",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                                             ),
                       ],
                     ),
                     const SizedBox(height: 10),
                     Text(
                       "Benefits:",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                     ),
                     const SizedBox(height: 6),
                    const _BenefitItem("Unlimited myDesk submissions"),
                    const _BenefitItem("Enhanced security features"),
                    const _BenefitItem("Higher file size limits"),
                  ],
                ),
              ),

               const SizedBox(height: 16),
               const Divider(),

              // Admin Code
               Text(
                "MyDesk admin code",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 12, color: Colors.grey),
              ),
               const SizedBox(height: 4),
               Text(
                adminCode,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: "monospace"),
              ),
               const SizedBox(height: 16),

              // Email Input
              Text(
                "Email Address",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 12),
              ),
               const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GlobalColours(context).textColorForContainer),
                decoration: InputDecoration(
                  hintText: "Enter your email address",
                  enabled: true,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                    // borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),

               const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 30,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child:  const Text("Cancel"),
                    ),
                  ),
                   const SizedBox(width: 8),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        // handle payment
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: Text(
                        "Upgrade",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Benefit bullet point widget
class _BenefitItem extends StatelessWidget {
  final String text;
   const _BenefitItem(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
         const Icon(Icons.check_circle,
            color: Colors.green, size: 16),
         const SizedBox(width: 6),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.grey : Colors.grey[900], height: 2))),
      ],
    );
  }
}
