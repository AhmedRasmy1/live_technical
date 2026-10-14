import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/widgets/breadcrumb_header.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/error_snack_bar.dart';
import '../../../../core/widgets/form_action_buttons.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../viewmodels/create_database_cubit/create_database_cubit.dart';
import '../widgets/database_details_step.dart';
import '../widgets/database_members_step.dart';
import '../widgets/database_summary_step.dart';

/// "Database Builder > Create Database" wizard.
/// Pops with `true` once something was saved, so the dashboard can refresh.
class CreateDatabaseView extends StatefulWidget {
  const CreateDatabaseView({super.key});

  @override
  State<CreateDatabaseView> createState() => _CreateDatabaseViewState();
}

class _CreateDatabaseViewState extends State<CreateDatabaseView> {
  late CreateDatabaseCubit createDatabaseCubit;
  final _detailsFormKey = GlobalKey<FormState>();
  final _summaryFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    createDatabaseCubit = getIt.get<CreateDatabaseCubit>();
    super.initState();
    createDatabaseCubit.getEmployees();
  }

  @override
  void dispose() {
    createDatabaseCubit.close();
    super.dispose();
  }

  // -------------------------------------------------------------------- actions

  void _onNext() {
    var reloadEmployees = false;
    switch (createDatabaseCubit.form.step) {
      case DatabaseWizardStep.details:
        if (!(_detailsFormKey.currentState?.validate() ?? false)) return;
        // The first fetch can have failed (and its state been replaced while
        // typing), so try again when the list is empty and nothing is loading.
        reloadEmployees =
            createDatabaseCubit.form.employees.isEmpty &&
            createDatabaseCubit.state is! CreateDatabaseLoading;
      case DatabaseWizardStep.members:
        if (!createDatabaseCubit.form.hasMembers) {
          showErrorSnackBar(context, 'Please Select At Least One Employee');
          return;
        }
      case DatabaseWizardStep.summary:
        return;
    }
    createDatabaseCubit.nextStep();
    if (reloadEmployees) createDatabaseCubit.getEmployees();
  }

  void _onSaveForLater() => createDatabaseCubit.saveDraft();

  /// Validates the summary, asks for confirmation, then writes everything.
  Future<void> _onGrantAccess() async {
    if (!createDatabaseCubit.form.hasMembers) {
      showErrorSnackBar(context, 'Please Select At Least One Employee');
      return;
    }
    if (!(_summaryFormKey.currentState?.validate() ?? false)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(
        title: 'Creating Database',
        message: 'Are You Sure You Want To Create This Database?',
      ),
    );
    if (confirmed != true || !mounted) return;
    createDatabaseCubit.createDatabase();
  }

  Future<void> _onStateChanged(CreateDatabaseState state) async {
    switch (state) {
      case CreateDatabaseSuccess():
        switch (state.outcome) {
          case CreateDatabaseOutcome.draftSaved:
            await _showSuccessAndClose(
              title: 'Save For Later',
              message: 'Your Database Was Saved As A Draft',
            );
          case CreateDatabaseOutcome.databaseCreated:
            await _showSuccessAndClose(
              title: 'Creating Database',
              message: 'You Successfully Created This Database',
            );
          case CreateDatabaseOutcome.employeesLoaded:
          case CreateDatabaseOutcome.formChanged:
            break;
        }
      case CreateDatabaseFailure():
        if (state.operation != CreateDatabaseOperation.loadEmployees) {
          showErrorSnackBar(context, state.error);
        }
      case CreateDatabaseInitial():
      case CreateDatabaseLoading():
        break;
    }
  }

  Future<void> _showSuccessAndClose({
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessDialog(title: title, message: message),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // ----------------------------------------------------------------- building

  Widget _buildStep(CreateDatabaseState state) {
    switch (state.form.step) {
      case DatabaseWizardStep.details:
        return DatabaseDetailsStep(
          cubit: createDatabaseCubit,
          formKey: _detailsFormKey,
        );
      case DatabaseWizardStep.members:
        return DatabaseMembersStep(cubit: createDatabaseCubit, state: state);
      case DatabaseWizardStep.summary:
        return DatabaseSummaryStep(
          cubit: createDatabaseCubit,
          form: state.form,
          formKey: _summaryFormKey,
        );
    }
  }

  /// Breadcrumb, with a back arrow on the later steps (desktop and web have
  /// no system back button).
  Widget _buildHeader(DatabaseWizardStep step) {
    return Row(
      children: [
        if (step != DatabaseWizardStep.details)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppPadding.p8),
            child: IconButton(
              tooltip: 'Back',
              onPressed: createDatabaseCubit.previousStep,
              icon: Icon(
                Icons.arrow_back,
                size: AppConstants.iconSize,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        const Expanded(
          child: BreadcrumbHeader(
            items: ['Database Builder', 'Create Database'],
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(CreateDatabaseState state) {
    switch (state.form.step) {
      case DatabaseWizardStep.details:
        return FormActionButtons(
          discardLabel: 'Discard',
          submitLabel: 'Next',
          onDiscard: () => Navigator.of(context).pop(),
          onSubmit: _onNext,
        );
      case DatabaseWizardStep.members:
        return FormActionButtons(
          discardLabel: 'Save For Later',
          submitLabel: 'Review',
          onDiscard: _onSaveForLater,
          onSubmit: _onNext,
        );
      case DatabaseWizardStep.summary:
        return FormActionButtons(
          discardLabel: 'Save For Later',
          submitLabel: 'Grant Access',
          onDiscard: _onSaveForLater,
          onSubmit: _onGrantAccess,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateDatabaseCubit, CreateDatabaseState>(
      bloc: createDatabaseCubit,
      listener: (context, state) => _onStateChanged(state),
      builder: (context, state) {
        final isBusy =
            state is CreateDatabaseLoading &&
            state.operation != CreateDatabaseOperation.loadEmployees;
        // The system back button walks back through the steps first.
        return PopScope(
          canPop: state.form.step == DatabaseWizardStep.details,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) createDatabaseCubit.previousStep();
          },
          child: Scaffold(
            backgroundColor: context.colors.background,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.contentMaxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p16,
                        ),
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppPadding.p16,
                                ),
                                child: _buildHeader(state.form.step),
                              ),
                            ),
                            SliverToBoxAdapter(child: _buildStep(state)),
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppPadding.p24,
                                  ),
                                  child: _buildButtons(state),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isBusy) const LoadingOverlay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
