import 'package:flutter/material.dart';
import '../data/firebase_content_repository.dart';
import '../l10n/l10n.dart';
import '../models/parenting_tip.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';

class ParentingTipsScreen extends StatefulWidget {
  const ParentingTipsScreen({super.key});

  @override
  State<ParentingTipsScreen> createState() => _ParentingTipsScreenState();
}

class _ParentingTipsScreenState extends State<ParentingTipsScreen> {
  late final Future<List<ParentingTipCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = FirebaseContentRepository.getParentingTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.parentingTips),
      body: SafeArea(
        child: FutureBuilder<List<ParentingTipCategory>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final categories = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryCard(category: category);
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ParentingTipCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, size: 20, color: AppColors.primary),
          ),
          title: Text(
            category.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          children: category.tips
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
