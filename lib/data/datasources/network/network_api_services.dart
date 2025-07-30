import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:naspend/data/app_excaptions.dart';
import 'package:naspend/data/datasources/network/base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  
  @override
  Future getGetApiResponse(String url) async {
    dynamic responseJson;

    try {
      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).timeout(Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }

    return responseJson;
  }

  @override
  Future getPostApiResponse(String url, dynamic data) async {
    dynamic responseJson;

    try {
      Response response = await Dio().post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).timeout(Duration(seconds: 10));

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }

    return responseJson;
  }

  @override
  Future getPutApiResponse(String url, dynamic data) async {
    dynamic responseJson;

    try {
      Response response = await Dio().put(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).timeout(Duration(seconds: 10));

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }

    return responseJson;
  }

  @override
  Future getDeleteApiResponse(String url) async {
    dynamic responseJson;

    try {
      Response response = await Dio().delete(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).timeout(Duration(seconds: 10));

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }

    return responseJson;
  }

}

dynamic returnResponse(Response response) {
  switch (response.statusCode) {
    case 200:
    case 201:
      dynamic responseJson = jsonDecode(response.data);
      return responseJson;
    case 400:
      throw BadRequestException(response.data.toString());
    case 401:
    case 403:
      throw UnauthorisedException(response.data.toString());
    case 500:
    default:
      throw FetchDataException('Error occurred while communicating with server with status code: ${response.statusCode}');
  }
}