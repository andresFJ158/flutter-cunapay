import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/buy_moment_indicator.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _allNews = []; // Todas las noticias cargadas
  List<dynamic> _displayedNews = []; // Noticias mostradas actualmente
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingCategories = true;
  bool _hasMore = true;
  int _displayedCount = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCategories();
    _loadNews(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreNews();
      }
    }
  }

  void _loadMoreFromCache() {
    if (_displayedCount >= _allNews.length) {
      setState(() => _hasMore = false);
      return;
    }

    setState(() {
      final nextBatch = _allNews.skip(_displayedCount).take(_pageSize).toList();
      _displayedNews.addAll(nextBatch);
      _displayedCount = _displayedNews.length;
      _hasMore = _displayedCount < _allNews.length;
      _isLoadingMore = false;
    });
  }

  List<dynamic> _parseNewsResponse(dynamic data) {
    if (data == null) return [];
    
    if (data is List) {
      return List.from(data);
    }
    
    if (data is Map) {
      // Intentar diferentes formatos comunes
      if (data['items'] != null && data['items'] is List) {
        return List.from(data['items']);
      }
      if (data['data'] != null && data['data'] is List) {
        return List.from(data['data']);
      }
      if (data['news'] != null && data['news'] is List) {
        return List.from(data['news']);
      }
      // Si el objeto tiene campos que parecen noticias, devolverlo como lista
      if (data.containsKey('title') || data.containsKey('id') || data.containsKey('_id')) {
        return [data];
      }
    }
    
    return [];
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService().getNewsCategories();
      if (mounted) {
        setState(() {
          if (response.data != null && response.data['categories'] != null) {
            _categories = List<String>.from(response.data['categories']);
          }
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _loadNews({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _allNews = [];
        _displayedNews = [];
        _displayedCount = 0;
        _hasMore = true;
      });
    }

    try {
      // Cargar noticias con paginación inicial
      final response = await ApiService().getNews(
        limit: _pageSize, // Cargar solo 10 inicialmente
        category: _selectedCategory,
      );
      if (mounted) {
        final newsList = _parseNewsResponse(response.data);
        
        setState(() {
          if (reset) {
            _allNews = newsList;
            _displayedNews = newsList.take(_pageSize).toList();
            _displayedCount = _displayedNews.length;
          } else {
            // Filtrar duplicados
            final existingIds = _allNews.map((n) => n['id'] ?? n['_id'] ?? n.toString()).toSet();
            final newNews = newsList.where((n) {
              final id = n['id'] ?? n['_id'] ?? n.toString();
              return !existingIds.contains(id);
            }).toList();
            
            _allNews.addAll(newNews);
            _displayedNews = _allNews.take(_displayedCount + _pageSize).toList();
            _displayedCount = _displayedNews.length;
          }
          
          // Si recibimos menos noticias que el límite, no hay más
          _hasMore = newsList.length >= _pageSize;
          
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        // Mostrar error al usuario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar noticias: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      // Cargar más noticias del servidor
      final response = await ApiService().getNews(
        limit: _pageSize,
        category: _selectedCategory,
      );
      
      if (mounted) {
        final newsList = _parseNewsResponse(response.data);
        
        // Filtrar noticias que ya tenemos para evitar duplicados
        final existingIds = _allNews.map((n) => n['id'] ?? n['_id'] ?? n.toString()).toSet();
        final newNews = newsList.where((n) {
          final id = n['id'] ?? n['_id'] ?? n.toString();
          return !existingIds.contains(id);
        }).toList();
        
        setState(() {
          _allNews.addAll(newNews);
          _displayedNews = _allNews.take(_displayedCount + _pageSize).toList();
          _displayedCount = _displayedNews.length;
          
          // Si recibimos menos noticias que el límite, no hay más
          _hasMore = newNews.length >= _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _hasMore = false; // Detener intentos si hay error
        });
      }
    }
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadNews(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Noticias'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadNews(reset: true);
          await _loadCategories();
        },
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador de momento
                    const BuyMomentIndicator(),
                    const SizedBox(height: AppSpacing.lg),
                    // Filtros de categoría
                    if (!_isLoadingCategories && _categories.isNotEmpty) ...[
                      Text(
                        'Filtrar por categoría',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimary : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _CategoryChip(
                              label: 'Todas',
                              isSelected: _selectedCategory == null,
                              onTap: () => _onCategorySelected(null),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            ..._categories.map((category) => Padding(
                                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                                  child: _CategoryChip(
                                    label: category,
                                    isSelected: _selectedCategory == category,
                                    onTap: () => _onCategorySelected(category),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    // Título de noticias
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Noticias',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                        if (_selectedCategory != null)
                          TextButton(
                            onPressed: () => _onCategorySelected(null),
                            child: const Text('Limpiar filtro'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Lista de noticias
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (_allNews.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No hay noticias',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _selectedCategory != null
                            ? 'No hay noticias en esta categoría'
                            : 'Las noticias aparecerán aquí',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _displayedNews.length) {
                        final news = _displayedNews[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: _NewsCard(news: news),
                        );
                      } else if (_isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    childCount: _displayedNews.length + (_isLoadingMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final dynamic news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewsDetailScreen(news: news),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de la noticia
                if (news['image'] != null && news['image'].toString().isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      news['image'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: isDark ? const Color(0xFF1E2130) : AppColors.surface,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: 48,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: isDark ? const Color(0xFF1E2130) : AppColors.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Row(
                  children: [
                    if (news['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          news['category'],
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (news['category'] != null) const SizedBox(height: 8),
                Text(
                  news['title'] ?? 'Sin título',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                ),
                if (news['summary'] != null || news['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    news['summary'] ?? news['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                // Impacto económico
                if (news['economicImpact'] != null && news['economicImpact'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            news['economicImpact'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (news['created_at'] != null || news['createdAt'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(news['created_at'] ?? news['createdAt']),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsed = DateTime.parse(date);
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF252940) : AppColors.surface),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.textPrimary : AppColors.textDark)
                      .withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppColors.textPrimary
                  : (isDark ? AppColors.textPrimary : AppColors.textDark),
            ),
          ),
        ),
      ),
    );
  }
}

