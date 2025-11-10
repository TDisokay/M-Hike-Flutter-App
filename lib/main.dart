import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'viewmodels/hike_viewmodel.dart'; 
import 'views/hike_list_screen.dart';

void main() {
  runApp(const MHikeApp());
}

// Main application widget
class MHikeApp extends StatelessWidget {
  const MHikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HikeViewModel()..loadHikes(),  
      child: MaterialApp(
        title: 'M-Hike App', 
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade800),
          useMaterial3: true,
        ),
        home: const HikeListScreen(), 
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
