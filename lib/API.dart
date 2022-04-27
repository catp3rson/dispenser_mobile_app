import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const duration = Duration(milliseconds: 200);
const baseURL = 'https://thay-tam.herokuapp.com';
// const baseURL = 'http://10.0.2.2:3109';
const apiURL = baseURL + '/api/v1';

class UUIDArgument {
  final String uuid;

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

Future<void> showMyDialog(
    BuildContext context, String title, String message, Function approveFunc,
    [bool pop = true]) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline1,
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              approveFunc();
              if (pop) Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
