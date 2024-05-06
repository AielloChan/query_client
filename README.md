# Query Client

More like react hook, but for Flutter.

## Features

### 👶 Simple api request

```dart
final _queryClient = QueryClient<bool>(({data, dataList}) async {
  await Future.delayed(Duration(seconds: 1));
  return true;
});

Widget build() {
  /// use future
  return FutureBuilder(
    future: _queryClient.future,
    build: () {
      return Text("just work"),
    }
  );
}
```

### 👨‍🚀 Auto Update UI

```dart
final _queryClient = QueryClient<bool>(
  ({data, dataList}) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  },
  onUpdate: () {
    /// if you wanna auto update the UI
    /// just add this
    if (mounted) setState(() {});
  },
)

Widget build() {
  if (_queryClient.isLoading) {
    return Center(
      child: Text("Loading..."),
    );
  }

  if (_queryClient.isError) {
    print("[MyWidget] error ${_queryClient.error}");
    return GestureDetector(
      child: Center(
        child: Text("🤕 Something went wrong! Tap to retry"),
      ),
      onTap: () {
        /// retry
        _queryClient.request();
      }
    );
  }

  return Center(
    child: Text("🎉 It works! ${_queryClient.data}"),
  );
}
```

### 🚀 Infinity Load (load more mode)

```dart
final _queryClient = QueryClient<bool>(
  ({previousData, dataList}) async {
    if (previousData != null) {
      /// you can use previousData to load next chunk of data
      /// such as get cursor from previousData or get pageId from previousData
      await Future.delayed(Duration(seconds: 1));
    } else {
      await Future.delayed(Duration(seconds: 1));
    }
    return true;
  },
  onUpdate: () {
    /// if you wanna auto update the UI
    /// just add this
    if (mounted) setState(() {});
  },
)

Widget build() {
  if (_queryClient.isLoading) {
    return Center(
      child: Text("Loading..."),
    );
  }

  if (_queryClient.isError) {
    print("[MyWidget] error ${_queryClient.error}");
    return GestureDetector(
      child: Center(
        child: Text("🤕 Something went wrong! Tap to retry"),
      ),
      onTap: () {
        /// retry
        /// will clean all loaded data, and request
        _queryClient.request();

        /// or you can just retry load more
        /// _queryClient.loadMore();
      }
    );
  }

  return GestureDetector(
    child: Center(
      child: Text("🎉 It works! ${_queryClient.data}. Tap to load more."),
    ),
    onTap: () {
      /// load more data
      _queryClient.loadMore();
    }
  );
}
```

## Feedback welcome

aiello.chan@gmail.com