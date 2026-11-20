import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../data/puzzle.dart';

/// Top 20 today. Your row is marked; if you're below 20, your row is added at the end.
class RankList extends StatelessWidget {
  const RankList({super.key, required this.result, required this.nickname});

  final Result result;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    final rows = [...result.top];
    if (!rows.any((r) => r.me)) rows.add(RankRow(position: result.rank, nickname: nickname, timeMs: result.timeMs, me: true));
    return Column(children: [for (final r in rows) _Row(row: r)]);
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});
  final RankRow row;

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: row.me ? AppColors.amberSoft : null, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            SizedBox(width: 40, child: Text('${row.position}', style: AppText.label.copyWith(color: AppColors.inkMuted))),
            Expanded(child: Text(row.nickname, style: AppText.label, overflow: TextOverflow.ellipsis)),
            Text(formatTime(row.timeMs), style: AppText.timer.copyWith(fontSize: 16, color: AppColors.inkMuted)),
          ],
        ),
      );
}
