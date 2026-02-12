import 'package:air_desk/constants.dart';
import 'package:air_desk/pages/data_page/qr_data_page.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:air_desk/services/desk_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ViewField extends ConsumerStatefulWidget {
  const ViewField({super.key});

  @override
  ConsumerState<ViewField> createState() => _ViewFieldState();
}

class _ViewFieldState extends ConsumerState<ViewField> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final DeskCacheService _deskCacheService = DeskCacheService();
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween<double>(begin: 0.98, end: 1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.repeat(reverse: true);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * .20;
    final deskProvider = ref.watch(viewProvider);
    final sendToDesk = deskProvider.changeControllerState;
    final deskExists = ref.watch(deskNotifierProvider).deskExists == true;
    final color = deskExists ? primaryBlue : Colors.red;

    final sendController = ref.watch(sendCodeControllerProvider);
    
    final colors = sendToDesk ? deskExists ? color : Colors.red : const Color(0xff069383);
    final backgroundColor = sendToDesk ? deskExists ? color.withValues(alpha: .1) : Colors.red.withValues(alpha: .1) : Colors.grey.withValues(alpha: .1);

    return ScaleTransition(
      scale: _animation,
      child: Padding(
        padding: EdgeInsets.only(right: width, bottom: 15, left: 5),
        child: RawAutocomplete<String>(
          textEditingController: sendController,
          focusNode: _focusNode,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.startsWith('@')) {
              final cachedCodes = await _deskCacheService.getCachedDeskCodes();
              return cachedCodes.where((code) => code.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            }
            return const Iterable<String>.empty();
          },
          onSelected: (String selection) {
            sendController.text = selection; 
            ref.watch(viewProvider.notifier).deskNameListener();
          }, 
          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
            return TextFormField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              inputFormatters: [
                LengthLimitingTextInputFormatter(9),
              ],
              onChanged: (value) {
                setState(() {
                  ref.watch(viewProvider.notifier).deskNameListener();
                });
              },
              cursorColor: colors,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors, width: .5),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors, width: .5),
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: backgroundColor,
                filled: true,
                contentPadding: const EdgeInsets.all(12),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                hintText: 'Enter code to view/edit or @userDesk',
                enabled: true,
                border: InputBorder.none
              ),
              onFieldSubmitted: (value) async {
                final result = await ref.read(viewProvider.notifier).submitView();
                
                result.fold(
                  (failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
                    );
                  },
                  (success) {
                    if (success is DeskCheckSuccess) {
                      final message = success.exists ? "Desk verified!" : "Desk not found";
                      final color = success.exists ? Colors.green : Colors.red;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message), backgroundColor: color),
                      );
                    } else if (success is EditFilesSuccess) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit mode enabled"), backgroundColor: Colors.green),
                      );
                    } else if (success is FetchDeskSuccess) {
                       // Typically fetchData already navigates or updates state that triggers navigation? 
                       // The existing logic just called fetchData which updated state. 
                       // The UI reacting to deskData change might handle navigation? 
                       // Assuming SendButton handles navigation for regular fetch? 
                       // Wait, ViewField is also used to VIEW. 
                       // If FetchDeskSuccess, we might want to navigate to QrDataPage or similar?
                       // The SendButton logic: 
                       // result.fold(..., (success) { if (success is FetchDataSuccess) ... Navigator.push... })
                       // So I should replicate that navigation here if it's the intent.
                       
                       // Looking at SendButton.dart (from context):
                       /*
                        if (success is FetchDataSuccess) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => QrDataPage(
                              content: success.data.text,
                              ...
                            ),
                          ));
                        }
                       */
                       // I will duplicate this navigation here.
                       Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => QrDataPage(
                            content: success.data.text,
                            files: success.data.images,
                            data: success.data.code,
                            createdAt: success.data.createdAt ?? DateTime.now(),
                          ),
                        ));
                    }
                  }
                );
              },
            );
          },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 0,
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200, minHeight: 50),
                  margin: const EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width * 0.7, // Adjust width as needed since it's an overlay
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onSelected(option),
                            hoverColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Text(
                                option,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}