import 'package:delta_compressor_202501017/core/data/remote/models/response/first_loading_response.dart';

class FirstLoadingModel {
  final String? imageUrl;

  FirstLoadingModel({this.imageUrl});

  factory FirstLoadingModel.fromResponse(FirstLoadingResponse response) {
    return FirstLoadingModel(
      imageUrl: response.data?.imageUrl,
    );
  }
}
