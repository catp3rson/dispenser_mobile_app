import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const duration = Duration(milliseconds: 200);
// const baseURL = 'https://thay-tam.herokuapp.com';
const baseURL = 'http://10.0.2.2:3109';
const apiURL = baseURL + '/api/v1';

class UUIDArgument {
  final dynamic uuid;

  UUIDArgument(this.uuid);
}

enum RequestType { getRequest, postRequest, putRequest, deleteRequest }

Future request(RequestType type, String url, String token,
    {Map<String, dynamic>? body}) async {
  var dio = Dio();
  dio.options.headers['content-Type'] = 'application/json';
  dio.options.headers['authorization'] = 'JWT ' + token;
  switch (type) {
    case RequestType.getRequest:
      return dio.get(url);
    case RequestType.postRequest:
      return dio.post(url, data: body);
    case RequestType.putRequest:
      return dio.put(url, data: body);
    case RequestType.deleteRequest:
      return dio.delete(url, data: body);
  }
}

Future<List<Map<String, dynamic>>> getOrder() => Future.delayed(
    duration,
    () => List.generate(
        8,
        (index) => {
              'uuid': 'uuid_$index',
              'name': 'My order ' + (index + 1).toString(),
              'desc': 'Coke',
            }));

Future<List<Map<String, dynamic>>> getFoodShop() => Future.delayed(
    duration,
    () => List.generate(
        13,
        (i) => {
              'uuid': 'uuid_' + (i + 1).toString(),
              'name': 'Coke ' + (i + 69).toString(),
              'desc': 'Drinks',
            }));

Future<Map<String, dynamic>> getOrderDetail() => Future.delayed(
      duration,
      () => {
        'name': 'My order',
        'item': List.generate(
            15,
            (i) => {
                  'uuid': 'uuid_' + (i + 1).toString(),
                  'name': 'Coke ' + i.toString(),
                  'desc': 'Drinks',
                  'quantity': i + 1,
                })
      },
    );
