// @dart=2.9

import 'dart:async';

void noop() {
  // pass
}

abstract class QueryClientAbstract<T> {
  Future<T> get future;

  /// 本次请求的数据
  T get data;

  /// 如果 infinity 模式为 false
  ///   则该数组中最多只会有一个元素，该元素与 data 为同一个元素
  /// 如果 infinity 模式为 true
  ///   则该数组中存放着所有分页获取的数据
  List<T> get pages;

  /// 错误信息
  dynamic get error;

  /// 是否报错
  bool get isError;

  /// 当前正在全新加载数据
  bool get loading;

  /// 当前已有数据，并且正在拉取最新数据
  /// infinity 模式下，当已经拉到过一条数据后，后续的请求都会是 validating 为 true
  bool get validating;

  QueryClientAbstract(
    Future<T> Function()

        /// 请求函数
        fn, {

    /// 手动触发请求
    bool manual = false,

    /// 使用 stale-while-revalidation 模式
    bool swr = true,

    /// 使用无限加载模式
    bool infinity = false,

    /// 更新界面的回调
    void Function() onUpdate = noop,
  });

  /// 重置所有数据及状态，包含 error、data、loading 状态等
  void Function() get reset;

  /// 仅重置所有数据，包含 error 和 data
  void Function() get clean;

  /// 全新请求
  Future<T> Function() get request;

  /// 增量请求
  Future<T> Function() get loadMore;

  /// 修改本地数据
  Future<R> mutate<R>(Future<R> Function() fn);
}
