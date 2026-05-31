import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

class SearchZoneDialog extends StatefulWidget {
  const SearchZoneDialog({super.key});

  @override
  State<SearchZoneDialog> createState() => _SearchZoneDialogState();
}

class _SearchZoneDialogState extends State<SearchZoneDialog> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedPlace;
  String _selectedCategory = DangerZoneCategories.etc;

  Future<void> _searchPlace() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _selectedPlace = null;
    });

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1&limit=5&accept-language=ko');
      final response = await http.get(url, headers: {
        'User-Agent': 'WalletSaver/1.0',
        'Accept-Language': 'ko-KR,ko;q=0.9',
      });
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _searchResults = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('검색 중 오류가 발생했습니다.')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('위험 지역 검색', style: AppTextStyles.sectionHeader),
            const SizedBox(height: 16),
            
            // Search Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '장소 이름 (예: 강남역 스타벅스)',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.bgPage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _searchPlace(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _searchPlace,
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Results List
            if (_searchResults.isNotEmpty && _selectedPlace == null) ...[
              const Divider(),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final place = _searchResults[index];
                    return ListTile(
                      title: Text(place['name'] ?? '알 수 없는 장소', maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(place['display_name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        setState(() {
                          _selectedPlace = place;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            
            // Selected Place Details
            if (_selectedPlace != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.tagBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_selectedPlace!['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _selectedPlace = null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              Text('카테고리 선택', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCategoryChip('쇼핑', DangerZoneCategories.mall),
                  _buildCategoryChip('백화점', DangerZoneCategories.dept),
                  _buildCategoryChip('카페', DangerZoneCategories.cafe),
                  _buildCategoryChip('여가/오락', DangerZoneCategories.entertainment),
                  _buildCategoryChip('기타', DangerZoneCategories.etc),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소', style: TextStyle(color: AppColors.textHint)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedPlace == null ? null : () {
                    final result = {
                      'name': _selectedPlace!['name'],
                      'category': _selectedCategory,
                      'lat': double.parse(_selectedPlace!['lat'].toString()),
                      'lng': double.parse(_selectedPlace!['lon'].toString()), // Nominatim uses 'lon'
                    };
                    Navigator.pop(context, result);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('저장하기'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String categoryValue) {
    final isSelected = _selectedCategory == categoryValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedCategory = categoryValue);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
    );
  }
}
