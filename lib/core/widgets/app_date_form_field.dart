import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/styles_manager.dart';
import '../utils/date_formatter.dart';
import 'app_input_decoration.dart';

/// Label on top + tap-to-pick date field that matches [AppTextFormField].
///
/// The validator receives the picked date (or `null`). Give it a
/// `GlobalKey<FormFieldState<DateTime>>` to re-validate it from outside, for
/// example an end date after the start date changed.
class AppDateFormField extends FormField<DateTime> {
  AppDateFormField({
    super.key,
    required String label,
    required ValueChanged<DateTime> onChanged,
    super.initialValue,
    super.validator,
    String hint = 'Select Date',
    Color? fillColor,
  }) : super(
         builder: (state) {
           final context = state.context;
           final value = state.value;

           Future<void> pick() async {
             final now = DateTime.now();
             final first = DateTime(AppConstants.datePickerFirstYear);
             final last = DateTime(AppConstants.datePickerLastYear);
             var initial = value ?? now;
             if (initial.isBefore(first)) initial = first;
             if (initial.isAfter(last)) initial = last;
             final picked = await showDatePicker(
               context: context,
               initialDate: initial,
               firstDate: first,
               lastDate: last,
             );
             if (picked == null) return;
             onChanged(picked);
             state.didChange(picked);
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 label,
                 style: getRegularStyle(
                   fontSize: AppConstants.captionSize,
                   color: context.colors.textPrimary,
                 ),
               ),
               const SizedBox(height: AppPadding.p4),
               InkWell(
                 borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                 onTap: pick,
                 child: InputDecorator(
                   decoration: appInputDecoration(context, fillColor: fillColor)
                       .copyWith(
                         errorText: state.errorText,
                         suffixIcon: Icon(
                           Icons.calendar_today_outlined,
                           size: AppConstants.iconSize,
                           color: context.colors.textSecondary,
                         ),
                       ),
                   child: Text(
                     value == null ? hint : formatDate(value),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: getRegularStyle(
                       fontSize: AppConstants.captionSize,
                       color: value == null
                           ? context.colors.textSecondary
                           : context.colors.textPrimary,
                     ),
                   ),
                 ),
               ),
             ],
           );
         },
       );
}
