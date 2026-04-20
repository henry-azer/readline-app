import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/core/services/pdf_processing_service.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/contracts/document_repository.dart';
import 'package:read_it/data/models/pdf_document_model.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';
import 'package:read_it/presentation/home/viewmodels/home_viewmodel.dart';
import 'package:read_it/presentation/home/widgets/active_state.dart';
import 'package:read_it/presentation/home/widgets/empty_state.dart';
import 'package:read_it/presentation/home/widgets/stats_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleImportPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;

      final service = getIt<PdfProcessingService>();
      final doc = await service.processFile(File(path));
      await getIt<DocumentRepository>().save(doc);
      await _viewModel.refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.errorImportPdf.tr)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: onSurface),
          onPressed: () {},
        ),
        title: Text(
          AppStrings.homeTitle.tr,
          style: AppTypography.titleLarge.copyWith(color: onSurface),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: StreamBuilder<bool>(
        stream: _viewModel.isLoading$,
        builder: (context, loadingSnap) {
          final isLoading = loadingSnap.data ?? true;

          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.primary : AppColors.lightPrimary,
              ),
            );
          }

          return RefreshIndicator(
            color: isDark ? AppColors.primary : AppColors.lightPrimary,
            onRefresh: _viewModel.refresh,
            child: _HomeBody(
              viewModel: _viewModel,
              onImportPdf: _handleImportPdf,
            ),
          );
        },
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final HomeViewModel viewModel;
  final VoidCallback onImportPdf;

  const _HomeBody({required this.viewModel, required this.onImportPdf});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PdfDocumentModel>>(
      stream: viewModel.documents$,
      builder: (context, docsSnap) {
        return StreamBuilder<HomeStats>(
          stream: viewModel.stats$,
          builder: (context, statsSnap) {
            return StreamBuilder<PdfDocumentModel?>(
              stream: viewModel.currentDocument$,
              builder: (context, currentSnap) {
                return StreamBuilder<StreakModel>(
                  stream: viewModel.streak$,
                  builder: (context, streakSnap) {
                    return StreamBuilder<List<ReadingSessionModel>>(
                      stream: viewModel.recentSessions$,
                      builder: (context, sessionsSnap) {
                        final docs = docsSnap.data ?? const [];
                        final stats = statsSnap.data ?? const HomeStats();
                        final current = currentSnap.data;
                        final streak = streakSnap.data ?? const StreakModel();
                        final sessions = sessionsSnap.data ?? const [];

                        final hasDocuments = docs.isNotEmpty;

                        return CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: AppSpacing.sm),

                                  // Stats bar
                                  StatsBar(
                                    stats: stats,
                                    hasDocuments: hasDocuments,
                                  ),

                                  const SizedBox(height: AppSpacing.xl),

                                  // Conditional body
                                  if (!hasDocuments || current == null)
                                    EmptyState(onImportPdf: onImportPdf)
                                  else
                                    ActiveState(
                                      document: current,
                                      recentSessions: sessions,
                                      streak: streak,
                                      onContinueReading: () {
                                        context.go(
                                          '${AppRoutes.reading}/${current.id}',
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
