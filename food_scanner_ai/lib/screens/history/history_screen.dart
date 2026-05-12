import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: history.isEmpty
          ? const Center(child: Text('No scan history found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final result = item.result;

                Color riskColor;
                if (result.riskLevel.toLowerCase() == 'safe') {
                  riskColor = Colors.green;
                } else if (result.riskLevel.toLowerCase() == 'medium') {
                  riskColor = Colors.orange;
                } else {
                  riskColor = Colors.red;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Slidable(
                    key: ValueKey(item.id),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => context.read<HistoryProvider>().toggleFavorite(item.id),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: item.isFavorite ? Icons.favorite : Icons.favorite_border,
                          label: 'Favorite',
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        SlidableAction(
                          onPressed: (_) => context.read<HistoryProvider>().deleteItem(item.id),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: riskColor.withValues(alpha: 0.2),
                          child: Icon(
                            result.riskLevel.toLowerCase() == 'safe' 
                                ? Icons.check
                                : Icons.warning_amber_rounded,
                            color: riskColor,
                          ),
                        ),
                        title: Text(
                          'Score: ${result.nutritionScore}/10 - ${result.riskLevel}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            result.warning,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (item.isFavorite)
                              const Icon(Icons.favorite, color: Colors.red, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              "${item.createdAt.month}/${item.createdAt.day}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
