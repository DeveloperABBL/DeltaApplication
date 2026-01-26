import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/feature/first_loading/models/first_loading_model.dart';
import 'package:delta_compressor_202501017/feature/first_loading/repository/first_loading_repo.dart';
import 'package:delta_compressor_202501017/feature/first_loading/repository/introductions_repo.dart';
import 'package:delta_compressor_202501017/feature/first_loading/viewmodel/first_loading_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirstLoadingPage extends StatelessWidget {
  const FirstLoadingPage({super.key});

  static final pagePath = '/first-loading';
  static final pageName = 'first-loading';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FirstLoadingViewmodel(
        context: context,
        firstLoadingDataSource: FirstLoadingRepo(),
        introductionsDataSource: IntroductionsRepo(),
      ),
      child: const FirstLoadingWidget(),
    );
  }
}

class FirstLoadingWidget extends StatefulWidget {
  const FirstLoadingWidget({super.key});

  @override
  State<FirstLoadingWidget> createState() => _FirstLoadingWidgetState();
}

class _FirstLoadingWidgetState extends State<FirstLoadingWidget> {
  late final FirstLoadingViewmodel _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = context.read<FirstLoadingViewmodel>();
    _viewmodel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewmodel.fetchFirstLoading();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Selector<FirstLoadingViewmodel, UiResult<FirstLoadingModel>>(
        selector: (context, provider) => provider.content,
        builder: (context, content, child) {
          if (content.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (content.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${content.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _viewmodel.fetchFirstLoading(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (content.isEmpty) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final model = content.requireData;
          final imageUrl = model.imageUrl;

          if (imageUrl == null || imageUrl.isEmpty) {
            return const Center(
              child: Text('No image URL available'),
            );
          }

          return SizedBox.expand(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Failed to load image'),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
