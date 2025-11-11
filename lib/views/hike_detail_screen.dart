import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hike.dart';
import '../models/observation.dart';
import '../viewmodels/hike_detail_viewmodel.dart';

class HikeDetailScreen extends StatelessWidget {
  final Hike hike;
  const HikeDetailScreen({super.key, required this.hike});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HikeDetailViewModel()
        ..setHike(hike)
        ..loadObservations(),
      child: Consumer<HikeDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.hike.name), 
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHikeDetailsCard(context, viewModel.hike),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Observations",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                _buildObservationsList(viewModel),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddObservationDialog(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHikeDetailsCard(BuildContext context, Hike hike) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hike.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall, 
            ),
            Text(
              hike.location,
              style: Theme.of(
                context,
              ).textTheme.titleMedium, 
            ),
            SizedBox(height: 8),
            Text("Date: ${hike.hikeDate}"),
            Text("Parking: ${hike.parkingAvailable}"),
            Text("Length: ${hike.length} km"),
            Text("Difficulty: ${hike.difficulty}"),
            if (hike.description != null && hike.description!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(hike.description!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsList(HikeDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.observations.isEmpty) {
      return const Center(child: Text("No observations yet. Add one!"));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: viewModel.observations.length,
        itemBuilder: (context, index) {
          final observation = viewModel.observations[index];
          return ListTile(
            title: Text(observation.observation),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(observation.observationTime),
                if (observation.comments != null &&
                    observation.comments!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      observation.comments!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () =>
                  _showDeleteObservationDialog(context, viewModel, observation),
            ),
          );
        },
      ),
    );
  }

  void _showAddObservationDialog(BuildContext context) {
    final viewModel = Provider.of<HikeDetailViewModel>(context, listen: false);
    final obsController = TextEditingController();
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Observation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: obsController,
                decoration: InputDecoration(labelText: "Observation *"),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(labelText: "Comments (Optional)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (obsController.text.trim().isEmpty) return;
                viewModel.addObservation(
                  obsController.text.trim(),
                  commentController.text.trim().isEmpty
                      ? null
                      : commentController.text.trim(),
                );
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteObservationDialog(
    BuildContext context,
    HikeDetailViewModel viewModel,
    Observation observation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Observation"),
        content: Text("Are you sure you want to delete this observation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteObservation(observation.id!);
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
