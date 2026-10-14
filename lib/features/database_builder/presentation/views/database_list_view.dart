import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/widgets/breadcrumb_header.dart';
import '../../../../core/widgets/status_message.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../viewmodels/database_list_cubit/database_list_cubit.dart';
import 'create_database_view.dart';
import '../widgets/database_action_bar.dart';
import '../widgets/database_filter_panel.dart';
import '../widgets/database_sliver_grid.dart';
import '../widgets/database_tabs_bar.dart';

/// Database Builder dashboard: tabs with live counters, search / filter / sort
/// and the grid of databases.
class DatabaseListView extends StatefulWidget {
  const DatabaseListView({super.key});

  @override
  State<DatabaseListView> createState() => _DatabaseListViewState();
}

class _DatabaseListViewState extends State<DatabaseListView> {
  late DatabaseListCubit databaseListCubit;

  @override
  void initState() {
    databaseListCubit = getIt.get<DatabaseListCubit>();
    super.initState();
    databaseListCubit.getDatabases();
  }

  @override
  void dispose() {
    databaseListCubit.close();
    super.dispose();
  }

  Future<void> _openCreateDatabase() async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreateDatabaseView()));
    // A `true` result means a database (or draft) was stored: reload so the
    // list and the tab counters are up to date.
    if (saved == true && mounted) databaseListCubit.getDatabases();
  }

  void _openFilter() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: dialogContext.colors.surface,
        insetPadding: const EdgeInsets.all(AppPadding.p16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.filterPanelMaxWidth,
          ),
          child: SingleChildScrollView(
            child: DatabaseFilterPanel(
              initialAccessType: databaseListCubit.data.accessFilter,
              onApply: (accessType) {
                databaseListCubit.filterByAccessType(accessType);
                Navigator.of(dialogContext).pop();
              },
              onReset: () {
                databaseListCubit.filterByAccessType(null);
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatabases(DatabaseListState state) {
    final data = state.data;
    switch (state) {
      case DatabaseListInitial():
      case DatabaseListLoading():
        // While refreshing, keep showing the current list.
        if (data.databases.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      case DatabaseListFailure():
        return SliverFillRemaining(
          hasScrollBody: false,
          child: StatusMessage(
            message: state.error,
            onRetry: databaseListCubit.getDatabases,
          ),
        );
      case DatabaseListSuccess():
        break;
    }

    final visible = data.visibleDatabases;
    if (visible.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: StatusMessage(message: 'No databases found'),
      );
    }
    return DatabaseSliverGrid(databases: visible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.contentMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
              child: BlocBuilder<DatabaseListCubit, DatabaseListState>(
                bloc: databaseListCubit,
                builder: (context, state) {
                  final data = state.data;
                  return CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppPadding.p16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: BreadcrumbHeader(
                                  items: ['Database Builder'],
                                ),
                              ),
                              ThemeToggleButton(),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: DatabaseTabsBar(
                          counts: data.counts,
                          selected: data.tab,
                          onSelected: databaseListCubit.selectTab,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppPadding.p16,
                          ),
                          child: DatabaseActionBar(
                            sort: data.sort,
                            onSearchChanged: databaseListCubit.searchDatabases,
                            onFilterPressed: _openFilter,
                            onSortSelected: databaseListCubit.sortBy,
                            onCreatePressed: _openCreateDatabase,
                          ),
                        ),
                      ),
                      _buildDatabases(state),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppPadding.p24),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
