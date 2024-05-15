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
  ({data, dataList}) async {
    if (data != null) {
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

### 💡 Mutate data

Some times we need mutate loaded data, such as user deleted one row, we should send DELETE request to the server, then fetch newest list back.

now you can use mutate to instantly change local data (you already have it in the data or dataList property of queryClient variable), then send DELETE request to the server, if success, just do noting (cos we already deleted that item); if request failed, just put the item back, and say "Uh oh, something went wrong, plz try again~" 🤣

let see how it works:

```dart
final _queryClient = QueryClient<bool>(
  ({data, dataList}) async {
    if (data != null) {
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

  final list = data.list;

  return GestureDetector(
    child: Column(
      children: list.map(
        (x) {
          return GestureDetector(
            child: Text(x.name),
            onTap: () {
              /// just delete this item
              _queryClient.mutate(({data, dataList}) {
                /// delete data from previous data or dataList
                final originIndex = data.list.indexWhere((y) => y.id == x.id);
                final origin = data.list.removeAt(originIndex);

                /// and send request to server, you should change this code to your real call
                /// don't wait for future here, just leave the function return a future, to trigger upper change to UI.
                return Request.deleteItem(x.id)
                  .then((res) {
                    /// success just leave it be
                  })
                  .catchError((err) {
                    /// just put it back
                    data.list.insert(originIndex, origin);
                    /// and don't forget to say sorry
                    Toast.show("🤕 Something went wrong! Try again!");
                  })
              });
            }
          );
        },
      ),
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