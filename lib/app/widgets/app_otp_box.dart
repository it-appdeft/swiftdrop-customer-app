import 'package:swiftdrop_customer_app/export.dart';

class AppOtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspaceOnEmpty;
  final double? size;

  const AppOtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspaceOnEmpty,
    this.size,
  });

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        controller.text.isEmpty) {
      onBackspaceOnEmpty();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = size ?? AppDimensions.otpBoxSize;
    return AnimatedBuilder(
      animation: Listenable.merge([controller, focusNode]),
      builder: (_, _) {
        final isFocused = focusNode.hasFocus;
        final hasContent = controller.text.isNotEmpty;
        return Container(
          width: boxSize,
          height: boxSize,
          decoration: (isFocused || hasContent)
              ? AppDecorations.lightOtpBoxFocused
              : AppDecorations.lightOtpBox,
          child: Focus(
            onKeyEvent: _handleKey,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.pMedium.copyWith(
                color: AppColors.lightInputText,
              ),
              onChanged: onChanged,
              decoration: const InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: AppColors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        );
      },
    );
  }
}
