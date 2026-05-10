import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'splash_screen.dart'; // For BlueprintPainter
import 'dormy_ai_screen.dart';
import 'services/chore_service.dart';
import 'services/house_service.dart';

class ChoreHistoryScreen extends StatelessWidget {
  const ChoreHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.schemeSurface(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: AppTheme.frostedBarBg(context),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: cs.outline),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                    color: AppTheme.schemeContainerHighest(context), height: 1),
              ),
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.primaryContainerOpacity20, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCpvezihTm1XB2FSmj2gUdxS1W1PAJel7dOhwTHvlvNhLwX9z-iY6CpXU8d3aUW79ptsN17ulm3CqHVmnzAiVbXJXWp6RlKol_YBE0tKbvEHokO2zNHj7hWBZGd65aa04dsPcpoX4fKYcuV5AM4J031IfNjmwVLENN19anaCcBRLUuE44dn5jZRjL1hSSU94MMLKmTnGpvOxEmjh2WlstBmtZnY95t-v5Y4_KvuQxss521_F2_um1sVhYE4N0qExMhuvAQLu_SLvzo'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dorm Mate',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_none, color: cs.outline),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Blueprint Grid Layer
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintPainter(brightness: Theme.of(context).brightness),
            ),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 24, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chore History', style: textTheme.headlineLarge),
                  const SizedBox(height: 16),

                  // Search Bar Group
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.primaryContainerOpacity8,
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: cs.outline),
                        hintText: 'Search tasks or roommates...',
                        hintStyle: textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: cs.primary, width: 2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Community Points Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.6)),
                        ),
                        child: Stack(
                          children: [
                            // Faint Background Watermark
                            Positioned(
                              right: -24,
                              top: -24,
                              child: Transform.rotate(
                                angle: 12 * math.pi / 180,
                                child: Icon(Icons.architecture,
                                    size: 100,
                                    color: Colors.black.withOpacity(0.05)),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('COMMUNITY POINTS',
                                        style: textTheme.labelSmall?.copyWith(
                                            color: AppTheme.outline,
                                            letterSpacing: 1.5)),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text('1,240',
                                            style: textTheme.headlineLarge
                                                ?.copyWith(
                                                    color: AppTheme.primary,
                                                    fontSize: 32)),
                                        const SizedBox(width: 4),
                                        Text('total',
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                    color: AppTheme
                                                        .onSurfaceVariant)),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 72,
                                      height: 32,
                                      child: Stack(
                                        children: [
                                          _buildAvatar(0,
                                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAGPZ3ljb56TCfciulg-qZrgxWJVEuL_1i0IdSvrSVzhJDr4VJwYfb9EowoZneCI6hCnNivDggp6VLEBceT2kxSsxUZGw7w-QVLy20AOADZ-7OehKBXbOr7lpgahfM8hTg_oqblrK-eCni8tx48THE0eaAY6ANg2Cxs9LRhLyiTTTro0zSl4B5A6wjYRFodA4rwBR7l6BUKAD0u0yDwAvgpOFVrolXdvNSvxzwNwz7S1YuRLhBE3Bs-V3YzU6yl-PM1UeEZH6QRfLI'),
                                          _buildAvatar(20,
                                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDak4Uuw2zWuOQO2j-RRQrU_GZzY5ND7-IfDTHzdfPQ9S23zLfqNlDdWHfjjYlAo0jU9jYiMbLxYP5zPky7F60MeY5NBKQF_SFMRo3dHdgEskt4dCTfXwzEiszjIn3fFhrtx7jG3r1Ek3RwM57yEr9S514rcFjxUVcqgu6-dRheHTP84CLMSe_MEGhud-Fp0IhIB8SVfw0AZ1-Ivf0BStnwzVV3Lnga-CBFVIQPIPwj6kIxspw76ayIyMgSn36SdRSowV1aZtr52Hg'),
                                          _buildAvatar(40,
                                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDlNrs823gjmTO_zLnSWn-Q5A3ujpof5V9UZA-z-eE2_QPTWPQgBjVeNrp5w8QDOxnREZGi2y1DSHRk9EFQLw298SNRwYcrs3PM8omqJwUVyOorwMiicOdPIluleYIxe34F4zSjtzV6EKMdIJbxc9lvEB3GWuRmslD6r6zaFdH-JMFlI4hv6y5myKB3gVXvp1yUlby8Fv1M_h5HKOdGhwqPZmeBz4uQTjcFqWBf0AwHE1-nKwq_5cVzS72t0VGnOtwVIRmpH-uc-g8'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('+12% this week',
                                        style: textTheme.labelSmall?.copyWith(
                                            color: AppTheme.primary)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Recent Activity Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Activity', style: textTheme.headlineMedium),
                      InkWell(
                        onTap: () {},
                        child: Text('Filter',
                            style: textTheme.labelMedium
                                ?.copyWith(color: AppTheme.primary)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: HouseService.instance.watchCurrentUserProfile(),
                    builder: (context, userSnapshot) {
                      final houseId = userSnapshot.data?.data()?['houseId'] as String?;
                      if (houseId == null) {
                        return _buildHistoryItem(
                          textTheme,
                          title: 'No house linked',
                          subtitle: 'Join or create a house first',
                          points: '-',
                          icon: Icons.info_outline,
                          iconColor: AppTheme.outline,
                          iconBg: AppTheme.surfaceContainer,
                        );
                      }
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: ChoreService.instance.watchCompletedChores(houseId),
                        builder: (context, choresSnapshot) {
                          if (choresSnapshot.hasError) {
                            return _buildHistoryItem(
                              textTheme,
                              title: 'Failed to load history',
                              subtitle: 'Please try again in a moment',
                              points: '-',
                              icon: Icons.error_outline,
                              iconColor: AppTheme.error,
                              iconBg: AppTheme.error.withOpacity(0.1),
                            );
                          }
                          final docs = [...(choresSnapshot.data?.docs ?? [])];
                          docs.sort((a, b) {
                            final aDate =
                                (a.data()['completedAt'] as Timestamp?)?.toDate();
                            final bDate =
                                (b.data()['completedAt'] as Timestamp?)?.toDate();
                            if (aDate == null && bDate == null) return 0;
                            if (aDate == null) return 1;
                            if (bDate == null) return -1;
                            return bDate.compareTo(aDate);
                          });
                          if (docs.isEmpty) {
                            return _buildHistoryItem(
                              textTheme,
                              title: 'No completed chores yet',
                              subtitle: 'Complete tasks to see activity here',
                              points: '-',
                              icon: Icons.check_circle_outline,
                              iconColor: AppTheme.primary,
                              iconBg: AppTheme.primaryContainer.withOpacity(0.1),
                            );
                          }

                          return Column(
                            children: docs.map((doc) {
                              final data = doc.data();
                              final title = (data['title'] as String?) ?? 'Untitled chore';
                              final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
                              final points = ((data['points'] as num?)?.toInt() ?? 10);
                              return _buildHistoryItem(
                                textTheme,
                                title: title,
                                subtitle: 'Completed • ${_dateText(completedAt)}',
                                points: '+$points pts',
                                icon: Icons.verified,
                                iconColor: AppTheme.primary,
                                iconBg: AppTheme.primaryContainer.withOpacity(0.1),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 24, // Sits slightly lower here since there is no Bottom Nav
            right: 24,
            child: FloatingActionButton(
              heroTag: 'history_ai_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DormyAiScreen()),
                );
              },
              backgroundColor: AppTheme.primaryContainer,
              elevation: 4,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double left, String url) {
    return Positioned(
      left: left,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  String _dateText(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildHistoryItem(
    TextTheme textTheme, {
    required String title,
    required String subtitle,
    required String points,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x082EC4B6), // Design system ambient shadow
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppTheme.outline)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(points,
                  style:
                      textTheme.labelMedium?.copyWith(color: AppTheme.primary)),
              const SizedBox(height: 4),
              const Icon(Icons.verified, color: AppTheme.primary, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
