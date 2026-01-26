import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:air_desk/services/desk_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ViewField extends StatefulWidget {
  const ViewField({super.key});

  @override
  State<ViewField> createState() => _ViewFieldState();
}

class _ViewFieldState extends State<ViewField> with SingleTickerProviderStateMixin {
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
    final deskProvider = Provider.of<ViewProvider>(context);
    final sendToDesk = deskProvider.changeControllerState;

    return Consumer<ViewProvider>(
      builder: (context, viewProvider, child) {
        final deskExists = context.watch<MyDeskProvider>().deskExists == true;
        final color = deskExists ? primaryBlue : Colors.red;
        
        final colors = sendToDesk ? deskExists ? color : Colors.red : const Color(0xff069383);
        final backgroundColor = sendToDesk ? deskExists ? color.withValues(alpha: .1) : Colors.red.withValues(alpha: .1) : Colors.grey.withValues(alpha: .1);
        return ScaleTransition(
          scale: _animation,
          child: Padding(
            padding: EdgeInsets.only(right: width, bottom: 15, left: 5),
            child: RawAutocomplete<String>(
              textEditingController: viewProvider.sendCodeController,
              focusNode: _focusNode,
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.startsWith('@')) {
                  final cachedCodes = await _deskCacheService.getCachedDeskCodes();
                  return cachedCodes.where((code) => code.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                }
                return const Iterable<String>.empty();
              },
              onSelected: (String selection) {
                viewProvider.sendCodeController.text = selection;
                viewProvider.deskNameListener(context);
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
                      viewProvider.deskNameListener(context);
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
                  onFieldSubmitted: (value) {
                    onFieldSubmitted();
                    viewProvider.updateControllerState(context);
                  },
                );
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    );
  }
}