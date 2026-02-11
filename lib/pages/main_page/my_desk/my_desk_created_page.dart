import 'package:air_desk/components/copy.dart';
import 'package:air_desk/constants.dart';
import 'package:air_desk/pages/main_page/my_desk/dialogs/access_dialog.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/capture.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:air_desk/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyDeskCreatedPage extends ConsumerStatefulWidget {
  const MyDeskCreatedPage({super.key});

  @override
  ConsumerState<MyDeskCreatedPage> createState() => _MyDeskCreatedPageState();
}

class _MyDeskCreatedPageState extends ConsumerState<MyDeskCreatedPage> {
  final GlobalKey _boundaryKey = GlobalKey();

  bool _isSavedTapped = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final myDesk = ref.read(myDeskProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        title:  Text(
          "Create MyDesk",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  RepaintBoundary(
                    key: _boundaryKey,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: GlobalColours(context).containerColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "MyDesk created successfully!",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Public Code
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.public_rounded, size: 18, color: primaryBlue),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Your public MyDesk code",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      myDesk.publicCode ?? 'public',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'Courier',
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Copy(textToCopy: myDesk.publicCode ?? 'public'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: QrImageView(
                                    backgroundColor: Colors.white,
                                    data: '@${myDesk.publicCode ?? 'public'}',
                                    version: 3,
                                    size: 200.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  "Scan to send content to your desk",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 13, 
                                    color: Colors.grey[600]
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Admin Access Code
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.vpn_key_rounded, size: 18, color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Your admin access code",
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDarkMode ? Colors.amber[200] : Colors.amber[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        myDesk.adminCode ?? 'admin',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          // fontFamily: 'Courier',
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Copy(textToCopy: myDesk.adminCode ?? 'admin'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_outline_rounded, size: 14, color: Colors.red),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Keep private! Needed to access submissions",
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 12, 
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  showAccessDialog(context, code: myDesk.adminCode ?? 'admin');
                                },
                                icon: const Icon(Icons.login_rounded),
                                label: Text("Access Desk", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  side: BorderSide(color: primaryBlue.withValues(alpha: 0.5)),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _isSavedTapped = true;
                                  });

                                  try {
                                    final result = await captureAndDownloadWithResult(_boundaryKey);
                                    if (context.mounted) {
                                      if (result.isSuccess) {
                                      snackBar('Image saved to: ${result.filePath}', context);
                                    } else {
                                      snackBar('Download Failed: ${result.error}', context);
                                    }
                                    }
                                  } catch (error) {
                                    if (context.mounted) {
                                      snackBar('Error saving image: $error', context);
                                    }
                                  } finally {
                                    setState(() {
                                      _isSavedTapped = false;
                                    });
                                  }
                                },
                                icon: _isSavedTapped 
                                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.download_rounded, color: primaryBlue),
                                label: Text("Save Card", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: primaryBlue)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
      ),
    );
  }
}
