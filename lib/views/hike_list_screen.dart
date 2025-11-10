import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hike.dart';
import '../viewmodels/hike_viewmodel.dart';
import 'hike_detail_screen.dart';
import 'add_edit_hike_screen.dart';

class HikeListScreen extends StatefulWidget {
  const HikeListScreen({super.key});

  @override
    State<HikeListScreen> createState() => _HikeListScreenState();
}

class _HikeListScreenState extends State<HikeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search hikes...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18),
      onChanged: (query) {
        Provider.of<HikeViewModel>(context, listen: false).searchHikes(query);
      },
    );
  }

  Widget _buildTitle() {
    return const Text('M-Hike App');
  }

  Widget _buildSearchAction() {
    return IconButton(
      icon: Icon(_isSearching ? Icons.close : Icons.search),
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
          if (!_isSearching) {
            // If closing search, clear text and reload all hikes
            _searchController.clear();
            Provider.of<HikeViewModel>(context, listen: false).loadHikes();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : _buildTitle(),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          _buildSearchAction(),

          IconButton(
            icon: Icon(Icons.delete_sweep),
            tooltip: "Delete All",
            onPressed: () {
              // Only show if not searching and list is not empty
              final viewModel = Provider.of<HikeViewModel>(
                context,
                listen: false,
              );
              if (!_isSearching && viewModel.hikes.isNotEmpty) {
                _showDeleteAllConfirmationDialog(context, viewModel);
              }
            },
          ),
        ],
      ),
      body: Consumer<HikeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.hikes.isEmpty) {
            return _buildLoadingWidget();
          }
          if (viewModel.errorMessage != null) {
            return _buildErrorWidget(context, viewModel);
          }
          if (viewModel.hikes.isEmpty) {
            return _buildEmptyWidget(context, _isSearching);
          }
          return _buildHikeList(context, viewModel);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddHike(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Builder Widgets
  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(BuildContext context, HikeViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text('Error', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(viewModel.errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.loadHikes(), 
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.terrain,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No Results Found' : 'No Hikes Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (!isSearching)
            Text(
              'Add your first hike by tapping the + button',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildHikeList(BuildContext context, HikeViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: viewModel.hikes.length,
      itemBuilder: (context, index) {
        final hike = viewModel.hikes[index];
        return _buildHikeCard(context, viewModel, hike);
      },
    );
  }

  Widget _buildHikeCard(
    BuildContext context,
    HikeViewModel viewModel,
    Hike hike,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            hike.name.isNotEmpty ? hike.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(hike.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(hike.location), Text(hike.hikeDate)],
        ),
        onTap: () => _navigateToHikeDetail(context, hike),
        trailing: Row(
          mainAxisSize:
              MainAxisSize.min, 
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditHike(context, hike),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: () =>
                  _showDeleteConfirmation(context, viewModel, hike),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation and Dialogs
  void _navigateToAddHike(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditHikeScreen(),
      ),
    );
  }

  void _navigateToEditHike(BuildContext context, Hike hike) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditHikeScreen(hike: hike)),
    );
  }

  void _navigateToHikeDetail(BuildContext context, Hike hike) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HikeDetailScreen(hike: hike),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    HikeViewModel viewModel,
    Hike hike,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hike'),
        content: Text('Are you sure you want to delete "${hike.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteHike(hike.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirmationDialog(BuildContext context, HikeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete All Data"),
        content: Text("Are you sure you want to delete ALL hikes and observations? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteAllHikes(); // Call the viewmodel
            },
            child: Text("Delete All", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
