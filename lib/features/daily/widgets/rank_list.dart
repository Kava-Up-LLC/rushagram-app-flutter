import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../data/puzzle.dart';

/// Top 20 today (DESIGN.md §5). Your row is highlighted; if you're below 20, it is added at the end after "···".
class RankList extends StatelessWidget {
  const RankList({super.key, required this.result, required this.nickname});

  final Result result;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    final rows = [...result.top];
    final inTop = rows.any((r) => r.me);
    return Column(children: [
      for (final r in rows) _Row(row: r),
      if (!inTop) ...[
        Text('···', textAlign: TextAlign.center, style: AppText.heading.copyWith(color: AppColors.slotEdge, height: 0.8)),
        _Row(row: RankRow(position: result.rank, nickname: nickname, timeMs: result.timeMs, me: true)),
      ],
    ]);
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});
  final RankRow row;

  @override
  Widget build(BuildContext context) => Container(
        height: 42,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: row.me
            ? BoxDecoration(
                color: AppColors.highlight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink, width: 2),
              )
            : null,
        child: Row(
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 28),
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: row.position == 1 || row.me ? AppColors.amber : AppColors.tile,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: Text('${row.position}', style: AppText.label.copyWith(fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(row.me ? '${row.nickname} (you)' : row.nickname, style: AppText.label.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis)),
            Text(formatTime(row.timeMs), style: AppText.time),
          ],
        ),
      );
}
