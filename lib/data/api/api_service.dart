import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:story_app/data/model/serialization/asset_detail_response.dart';
import 'package:story_app/data/model/serialization/asset_list_response.dart';
import 'package:story_app/data/model/serialization/upload_response.dart';

class ApiService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1/';

  ApiService();

  String endpointsFull = '';

  Future<dynamic> httpRequest({
    required String endpoints,
    required String method,
    required Map<String, String>? headers,
    required Map<String, dynamic> bodyPost,
    required String query,
  }) async {
    http.Response response;

    switch (method.toLowerCase()) {
      case 'get':
        endpointsFull = endpoints;
        if (query.isNotEmpty) {
          endpointsFull = 'search$query';
        }
        response = await http.get(
          Uri.parse("$_baseUrl$endpointsFull"),
          headers: headers,
        );
      case 'post':
        response = await http.post(
          Uri.parse("$_baseUrl$endpoints"),
          headers: headers,
          body: bodyPost,
        );
        break;
      default:
        throw Exception('HTTP method tidak didukung');
    }

    final responseBody = jsonDecode(response.body);
    if (responseBody['error'] == false) {
      switch (endpoints) {
        case 'login':
          if (response.statusCode == 200) {
            return responseBody;
          }
        case 'register':
          if (response.statusCode == 201) {
            return responseBody;
          } else {
            return {'error': true};
          }
        default:
      }
    } else {
      throw Exception(responseBody['message']);
    }

    return false;
  }

  Future<DetailResponse> httpRequestDetail({
    required String endpoints,
    required Map<String, String>? headers,
  }) async {
    try {
      final response =
          await http.get(Uri.parse("$_baseUrl$endpoints"), headers: headers);

      if (response.statusCode == 200) {
        return DetailResponse.fromJson(
          json.decode(response.body),
        );
      } else {
        throw Exception(
            'Detail cerita gagal dimuat dengan status kode: ${response.statusCode}');
      }
    } catch (e, s) {
      throw Exception(
          'Terjadi kesalahan saat memuat detail cerita: $e, Trace: $s');
    }
  }

  Future<UploadResponse> uploadDocument(
    List<int> bytes,
    String fileName,
    String description,
    double latitude,
    double longitude,
    String token,
  ) async {
    try {
      const String url = '${_baseUrl}stories';
      final uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);

      final multiPartFile = http.MultipartFile.fromBytes(
        "photo",
        bytes,
        filename: fileName,
      );

      final Map<String, String> fields = {
        "description": description,
        "lat": latitude.toString(),
        "lon": longitude.toString(),
      };

      final Map<String, String> headers = {
        "Content-type": "multipart/form-data",
        "Authorization": "Bearer $token",
      };

      request.files.add(multiPartFile);
      request.fields.addAll(fields);
      request.headers.addAll(headers);

      final http.StreamedResponse streamedResponse = await request.send();
      final int statusCode = streamedResponse.statusCode;

      final Uint8List responseList = await streamedResponse.stream.toBytes();
      final String responseData = String.fromCharCodes(responseList);

      if (statusCode == 201) {
        final Map<String, dynamic> responseMap = json.decode(responseData);

        final UploadResponse uploadResponse =
            UploadResponse.fromJson(responseMap);
        return uploadResponse;
      } else {
        throw Exception("Upload file error: $statusCode");
      }
    } catch (e) {
      throw Exception('Upload file failed: $e');
    }
  }

  Future<ListResponse> getStories(
      [int page = 1, int size = 4, String? token = '']) async {
    var url = Uri.parse("${_baseUrl}stories?page=$page&size=$size");

    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    final statusCode = response.statusCode;

    if (statusCode == 200) {
      return ListResponse.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception("Get stories error");
    }
  }
}
