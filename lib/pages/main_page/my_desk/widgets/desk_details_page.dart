import 'package:air_desk/constants.dart';
import 'package:air_desk/model/my_desk.dart';
import 'package:air_desk/pages/main_page/my_desk/widgets/code_box.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:air_desk/utils/upgrade_popup.dart';
import 'package:air_desk/widgets/edit_code_container.dart';
import 'package:blurbackground/blurbackground.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DeskDetailsPage extends StatelessWidget {
  const DeskDetailsPage({super.key, required this.deskCode, required this.adminCode, required this.deskData});
  final String deskCode, adminCode;
  final MyDeskData deskData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(context),
          const SizedBox(height: 32),
          const Text(
            "Access Keys",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 16),
          CodeBox(
            title: "Admin Access Code",
            code: adminCode,
            textColor: Colors.red,
            color: Colors.red,
            iconColor: Colors.red,
          ),
          const SizedBox(height: 16),
          CodeBox(
            title: "Public Share Code",
            code: deskCode,
            textColor: primaryBlue,
            color: primaryBlue,
            iconColor: primaryBlue,
          ),
          const SizedBox(height: 32),
          _buildInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final colors = GlobalColours(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.containerColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Text(
            "Your Unique Desk",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            "Receive files anonymously. Share your code or QR to get started.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  context,
                  "Share",
                  Icons.ios_share_rounded,
                  () => _showShareSheet(context)
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionBtn(
                  context,
                  "QR Code",
                  Icons.qr_code_rounded,
                  () => _showShareSheet(context)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: primaryBlue),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final colors = GlobalColours(context);
    final isPremium = deskData.myDesk?.isPremium ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPremium ? null : colors.containerColor,
        gradient: isPremium
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFBF953F),
                  Color(0xFFFCF6BA),
                  Color(0xFFB38728),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(24),
        border: isPremium ? null : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: isPremium
            ? [
                BoxShadow(
                  color: const Color(0xFFB38728).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPremium ? Icons.verified_rounded : Icons.info_outline_rounded,
                color: isPremium ? const Color(0xFF4A340F) : primaryBlue,
                size: 26,
              ),
              const SizedBox(width: 12),
              Text(
                isPremium ? "Premium Active" : "AirDesk Basic",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isPremium ? const Color(0xFF4A340F) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isPremium ? "Enjoy zero limits, high-speed file transfers, and priority data retention." : "Upgrade to unlock unlimited daily submissions and increased file size caps.",
            style: TextStyle(
              fontSize: 14,
              color: isPremium ? const Color(0xFF4A340F).withValues(alpha: 0.8) : Colors.grey[600],
              height: 1.5,
              fontWeight: isPremium ? FontWeight.w600 : null,
            ),
          ),
          if (!isPremium) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => showDialog(context: context, builder: (context) => UpgradePopup(adminCode: adminCode)),
                style: TextButton.styleFrom(
                  backgroundColor: primaryBlue.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("View Premium Benefits", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BlurBackground(
          blurX: 12,
          blurY: 12,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  'Share Portal',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan or use the code to enter the desk',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: deskCode,
                    size: 200,
                    version: QrVersions.auto,
                  ),
                ),
                const SizedBox(height: 48),
                EditCodeContainer(
                  editCode: '@$deskCode',
                  title: 'Desk Handle',
                  description: 'Easier to remember',
                  width: double.infinity,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}