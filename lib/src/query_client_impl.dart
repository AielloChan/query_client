// @dart=2.9
import 'dart:async';

import 'package:query_client/query_client.dart';
import 'package:query_client/src/uniqId.dart';

/// 单一请求客户端
class QueryClient<T> implements QueryClientAbstract {
  final Future<T> Function({
    T data,
    List<T> dataList,
  }) _fn;

  /// 数据区域
  List<T> _dataList = [];
  dynamic _error;

  /// 状态区域
  bool _isLoading = false;
  bool _isValidating = false;

  /// 配置区域
  bool _swr = true;

  /// 控制器
  Completer<T> _completer;

  /// 回调
  void Function() _onUpdate;

  String _requestKey;

  QueryClient(
    this._fn, {
    onUpdate,
    swr = true,
    manual = false,
    infinity = false,
  }) {
    _swr = swr;
    _onUpdate = onUpdate;
    _completer = _createCompleter();

    if (!manual) {
      _request();
    }
  }

  @override
  get error => _error;

  @override
  T get data => _dataList.isNotEmpty ? _dataList.last : null;

  @override
  List<T> get dataList => _dataList;

  @override
  Future<T> get future => _completer.future;

  @override
  get isError => _error != null;

  @override
  get isLoading => _isLoading;

  @override
  get isValidating => _isValidating;

  @override
  void Function() get clean => _clean;
  @override
  void Function() get reset => _reset;
  @override
  Future<T> Function() get request => _request;
  @override
  Future<T> Function() get loadMore => () => _request(isAppend: true);

  Completer<T> _createCompleter() {
    Completer<T> completer = Completer();
    _completer = completer;
    return completer;
  }

  void _triggerUpdate() {
    if (_onUpdate != null) {
      _onUpdate();
    }
  }

  Future<T> _request({
    bool isAppend = false,
  }) {
    if (_isLoading || _isValidating) {
      /// 如果当前已经有请求
      /// 则直接返回当前的数据
      return future;
    }
    _createCompleter();

    if (!_swr) {
      _dataList = [];
    }

    if (_dataList.isEmpty) {
      /// 没有数据，是全新拉取
      _isLoading = true;
      _isValidating = true;
    } else {
      /// 如果有数据，说明是重新拉取
      /// 只需要设置 validating 为 true
      _isValidating = true;
    }

    /// 用做请求唯一判断
    final requestKey = generateUniqueId();
    _requestKey = requestKey;

    /// 同时捕获同步错误和异步错误
    try {
      /// 在发出请求前，触发界面更新
      _triggerUpdate();

      Future<T> response;
      if (isAppend) {
        response = _fn(data: data, dataList: _dataList);
      } else {
        response = _fn(data: null, dataList: []);
      }

      response
          .then((value) => _handleSuccess(requestKey, value, isAppend))
          .catchError((error) => _handleError(requestKey, error, isAppend));
    } catch (error) {
      _handleError(requestKey, error, isAppend);
    }

    return future;
  }

  /// 处理请求成功逻辑
  void _handleSuccess(String requestKey, T value, bool isAppend) {
    if (_requestKey != requestKey) {
      // 不是当前要处理的请求
      return;
    }

    _error = null;
    if (isAppend) {
      _dataList.add(value);
    } else {
      _dataList = [value];
    }
    _isLoading = false;
    _isValidating = false;
    _completer.complete(value);

    _triggerUpdate();
  }

  /// 处理请求失败逻辑
  void _handleError(String requestKey, dynamic error, bool isAppend) {
    if (_requestKey != requestKey) {
      // 不是当前要处理的请求
      return;
    }

    _error = error;
    if (!isAppend) {
      _dataList = [];
    }
    _isLoading = false;
    _isValidating = false;
    _completer.completeError(error);

    _triggerUpdate();
  }

  void _reset() {
    _clean();
    _isLoading = false;
    _isValidating = false;
  }

  void _clean() {
    _error = null;
    _dataList = [];
  }

  @override
  Future<R> mutate<R>(Future<R> Function({T data, List<T> dataList}) fn) async {
    final future = fn(data: data, dataList: dataList);
    _triggerUpdate();
    final result = await future;
    _triggerUpdate();
    return result;
  }
}
