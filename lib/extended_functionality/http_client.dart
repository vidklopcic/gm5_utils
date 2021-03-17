import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class HttpClientWithHeaders extends http.BaseClient {
  final Map<String, String> defaultHeaders;
  http.Client _httpClient = new http.Client();

  HttpClientWithHeaders({this.defaultHeaders = const {}});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(defaultHeaders);
    return _httpClient.send(request);
  }

  @override
  Future<Response> get(url, {Map<String, String> headers}) {
    headers = _mergeHeaders(headers, defaultHeaders);
    return _httpClient.get(url, headers: headers);
  }

  @override
  Future<Response> post(url, {Map<String, String> headers, body, Encoding encoding}) {
    headers = _mergeHeaders(headers, defaultHeaders);
    return _httpClient.post(url, headers: headers, encoding: encoding);
  }

  @override
  Future<Response> patch(url, {Map<String, String> headers, body, Encoding encoding}) {
    headers = _mergeHeaders(headers, defaultHeaders);
    return _httpClient.patch(url, headers: headers, encoding: encoding);
  }

  @override
  Future<Response> put(url, {Map<String, String> headers, body, Encoding encoding}) {
    headers = _mergeHeaders(headers, defaultHeaders);
    return _httpClient.put(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> head(url, {Map<String, String> headers}) {
    headers = _mergeHeaders(headers, defaultHeaders);
    return _httpClient.head(url, headers: headers);
  }

  @override
  Future<Response> delete(Uri url, {Map<String, String> headers, Object body, Encoding encoding}) {
    headers = _mergeHeaders(headers, defaultHeaders);
    return _httpClient.delete(url, headers: headers);
  }

  Map<String, String> _mergeHeaders(Map<String, String> headers, Map<String, String> add) {
    headers ??= <String, String>{};
    headers.addAll(add);
    return headers;
  }
}
