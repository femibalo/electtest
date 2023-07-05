import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MTextFormField extends StatelessWidget {
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool isDense;
  final bool enabled;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextCapitalization textCapitalization;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforced;
  final int? errorMaxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Color? enabledBorderColor;
  final bool readOnly;
  final Function? onTap;
  final double? suffixIconWidth;
  final double? suffixIconHeight;
  final TextStyle? style;
  final bool disableSuffixIconConstraints;

  const MTextFormField(
      {Key? key,
      this.disableSuffixIconConstraints = false,
      this.obscureText = false,
      this.enableSuggestions = false,
      this.autocorrect = false,
      this.isDense = false,
      this.enabled = true,
      this.maxLengthEnforced,
      this.controller,
      this.textInputAction,
      this.keyboardType,
      this.hintText,
      this.labelText,
      this.helperText,
      this.errorText,
      this.prefixIcon,
      this.suffixIcon,
      this.prefixText,
      this.autofillHints,
      this.onEditingComplete,
      this.validator,
      this.onChanged,
      this.textCapitalization = TextCapitalization.none,
      this.maxLines = 1,
      this.minLines = 1,
      this.maxLength,
      this.errorMaxLines,
      this.onFieldSubmitted,
      this.inputFormatters,
      this.readOnly = false,
      this.enabledBorderColor,
      this.onTap,
      this.style,
      this.suffixIconWidth,
      this.suffixIconHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      obscureText: obscureText,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      enabled: enabled,
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      cursorColor: Colors.blue,
      cursorWidth: 1,
      style: Theme.of(context).textTheme.titleMedium,
      autofillHints: autofillHints,
      onEditingComplete: onEditingComplete,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforced,
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      inputFormatters: inputFormatters ?? [],
      decoration: InputDecoration(
        suffixIconConstraints: disableSuffixIconConstraints
            ? null
            : BoxConstraints(
                maxHeight: suffixIconHeight ?? 24,
                maxWidth: suffixIconWidth ?? 24),
        isDense: isDense,
        hintText: hintText,
        labelText: labelText,
        errorText: errorText,
        helperText: helperText,
        prefixText: prefixText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              width: 1,
              style: BorderStyle.solid),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide( width: 2, style: BorderStyle.solid),
        ),
        labelStyle: Theme.of(context).textTheme.titleLarge,
        errorMaxLines: errorMaxLines,
      ),
    );
  }
}
