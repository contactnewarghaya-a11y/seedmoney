import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/explore_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().search('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Consumer<ExploreProvider>(
          builder: (context, exploreProv, child) {
            final displayedProfiles = exploreProv.results;
            
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'NutriScan AI',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
                          onPressed: () => context.push('/alerts'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Explore\nIngredients',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'Decode the safety profile of additives, preservatives, and authentic Indian ingredients with scientific precision.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                            exploreProv.search(val);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search additives, E-numbers, or prese...',
                            hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (_searchQuery.isEmpty) ...[
                          const Text(
                            'TRENDING SEARCHES',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _TrendingChip(
                                label: 'E621 Monosodium Glutamate',
                                isSelected: _searchQuery == 'E621',
                                onTap: () {
                                  _searchController.text = 'E621';
                                  setState(() => _searchQuery = 'E621');
                                  exploreProv.search('E621');
                                },
                              ),
                              _TrendingChip(
                                label: 'Turmeric Curcumin',
                                isSelected: _searchQuery == 'Curcumin',
                                onTap: () {
                                  _searchController.text = 'Curcumin';
                                  setState(() => _searchQuery = 'Curcumin');
                                  exploreProv.search('Curcumin');
                                },
                              ),
                              _TrendingChip(
                                label: 'Aspartame',
                                isSelected: _searchQuery == 'Aspartame',
                                onTap: () {
                                  _searchController.text = 'Aspartame';
                                  setState(() => _searchQuery = 'Aspartame');
                                  exploreProv.search('Aspartame');
                                },
                              ),
                              _TrendingChip(
                                label: 'E102 Tartrazine',
                                isSelected: _searchQuery == 'Tartrazine',
                                onTap: () {
                                  _searchController.text = 'Tartrazine';
                                  setState(() => _searchQuery = 'Tartrazine');
                                  exploreProv.search('Tartrazine');
                                },
                              ),
                              _TrendingChip(
                                label: 'Sodium Benzoate',
                                isSelected: _searchQuery == 'Benzoate',
                                onTap: () {
                                  _searchController.text = 'Benzoate';
                                  setState(() => _searchQuery = 'Benzoate');
                                  exploreProv.search('Benzoate');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Browse by Category',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 16),
                          _CategoryCard(
                            title: 'E-Numbers',
                            subtitle: 'International safety codes for food additives.',
                            tagText: '500+ Items',
                            imageUrl: 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&q=80&w=600',
                            onTap: () {
                              _searchController.text = 'E-NUMBER';
                              setState(() => _searchQuery = 'E-NUMBER');
                              exploreProv.search('E-NUMBER');
                            },
                          ),
                          const SizedBox(height: 12),
                          _CategoryCard(
                            title: 'Natural Colors',
                            subtitle: 'Pigments extracted from fruits, vegetables, and minerals.',
                            tagText: 'Plant Derived',
                            imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&q=80&w=600',
                            onTap: () {
                              _searchController.text = 'NATURAL';
                              setState(() => _searchQuery = 'NATURAL');
                              exploreProv.search('NATURAL');
                            },
                          ),
                          const SizedBox(height: 12),
                          _CategoryCard(
                            title: 'Preservatives',
                            subtitle: 'Common agents used to inhibit microbial growth.',
                            tagText: 'Shelf Life',
                            imageUrl: 'https://images.unsplash.com/photo-1615486511484-92e172e270b2?auto=format&fit=crop&q=80&w=600',
                            isTagGrey: true,
                            onTap: () {
                              _searchController.text = 'PRESERVATIVE';
                              setState(() => _searchQuery = 'PRESERVATIVE');
                              exploreProv.search('PRESERVATIVE');
                            },
                          ),
                          const SizedBox(height: 32),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                _searchQuery.isEmpty ? 'Recent Safety\nProfiles' : 'Search\nResults',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark, height: 1.1),
                              ),
                            ),
                            if (_searchQuery.isEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('View all', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                                  Row(
                                    children: [
                                      const Text('database', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward, color: AppTheme.primaryColor, size: 14),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isEmpty)
                          const Text('Verified by NutriScan AI labs', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        const SizedBox(height: 20),
                        
                        if (exploreProv.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (displayedProfiles.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text('No results found for "$_searchQuery"', style: TextStyle(color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                          )
                        else
                          ...displayedProfiles.map((p) => _ProfileCard(
                            type: p['type'] ?? 'INGREDIENT',
                            title: p['title'] ?? '',
                            description: p['description'] ?? '',
                            status: p['status'] ?? 'Unknown',
                            isCaution: p['caution'] ?? false,
                            isSafe: p['safe'] ?? false,
                            allergens: List<String>.from(p['allergens'] ?? []),
                          )),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TrendingChip({required this.label, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLightest : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textDark,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tagText;
  final String imageUrl;
  final bool isTagGrey;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.tagText,
    required this.imageUrl,
    this.isTagGrey = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isTagGrey ? Colors.grey.shade600.withValues(alpha: 0.8) : AppTheme.primaryColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(tagText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String type;
  final String title;
  final String description;
  final String status;
  final bool isSafe;
  final bool isCaution;
  final List<String> allergens;

  const _ProfileCard({
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    this.isSafe = false,
    this.isCaution = false,
    required this.allergens,
  });

  @override
  Widget build(BuildContext context) {
    Color chipBgColor = isSafe ? AppTheme.primaryLightest : (isCaution ? AppTheme.dangerLight : const Color(0xFFE2E8F0));
    Color chipTextColor = isSafe ? AppTheme.primaryColor : (isCaution ? AppTheme.dangerRed : const Color(0xFF4A5568));
    IconData chipIcon = isSafe ? Icons.check_circle_outline : (isCaution ? Icons.warning_amber_rounded : Icons.info_outline);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(type, style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCaution) Icon(chipIcon, size: 14, color: chipTextColor)
                    else if (isSafe) Icon(chipIcon, size: 14, color: chipTextColor)
                    else Icon(Icons.location_on_outlined, size: 14, color: chipTextColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: chipTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          const Text('Associated Allergens', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergens.map((a) => _AllergenTag(label: a)).toList(),
          ),
        ],
      ),
    );
  }
}

class _AllergenTag extends StatelessWidget {
  final String label;
  const _AllergenTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Light grey
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF4A5568), fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
