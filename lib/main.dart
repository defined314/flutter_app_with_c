import 'dart:math';
// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:flutter/material.dart';
import 'package:ffi/ffi.dart'; // For FFI
import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX


final DynamicLibrary nativeLib = Platform.isWindows
    ? DynamicLibrary.open('Dll_test.dll')
    : DynamicLibrary.open("libnative.so"); // DynamicLibrary.process()


// Example of handling a simple C struct
final class Coordinate extends Struct {
  @Double()
  external double latitude;

  @Double()
  external double longitude;
}

// Example of a complex struct (contains a string and a nested struct)
final class Place extends Struct {
  external Pointer<Utf8> name;

  external Coordinate coordinate;
}

final int Function(int x, int y) nativeSimpleAdd =
nativeLib.lookup<NativeFunction<Int32 Function(Int32, Int32)>>("simpleAdd").asFunction();
final int Function(int x, int y) nativeSimpleDiff =
nativeLib.lookup<NativeFunction<Int32 Function(Int32, Int32)>>("simpleDiff").asFunction();
final int Function(int x, int y) nativeSimpleMultiple =
nativeLib.lookup<NativeFunction<Int32 Function(Int32, Int32)>>("simpleMultiple").asFunction();
final void Function(Pointer<Int32>) nativeAddPointer =
nativeLib.lookup<NativeFunction<Void Function(Pointer<Int32>)>>("addPointer").asFunction();
final void Function() nativeSayHello =
nativeLib.lookup<NativeFunction<Void Function()>>("say_hello").asFunction();
final Pointer<Utf8> Function() nativeSayWorld =
nativeLib.lookup<NativeFunction<Pointer<Utf8> Function()>>("say_world").asFunction();

final Coordinate Function(double latitude, double longitude) nativeCreateCoordinate =
nativeLib.lookup<NativeFunction<Coordinate Function(Double, Double)>>("create_coordinate").asFunction();
final Place Function(Pointer<Utf8> name, double latitude, double longitude) nativeCreatePlace =
nativeLib.lookup<NativeFunction<Place Function(Pointer<Utf8>, Double, Double)>>("create_place").asFunction();
final double Function(Coordinate p1, Coordinate p2) nativeDistance =
nativeLib.lookup<NativeFunction<Double Function(Coordinate, Coordinate)>>("distance").asFunction();


void main() {

  final coordinate = nativeCreateCoordinate(7.3, 5.2);
  print('Coordinate is lat ${coordinate.latitude}, long ${coordinate.longitude}');
  final nameUtf8 = 'daejeon_moonji'.toNativeUtf8();
  final place = nativeCreatePlace(nameUtf8, 18.0, 28.0);
  final nameString = place.name.toDartString();
  calloc.free(nameUtf8);
  final coord = place.coordinate;
  print('The name of my place is $nameString at ${coord.latitude}, ${coord.longitude}');
  final dist = nativeDistance(nativeCreateCoordinate(10.0, 20.0), nativeCreateCoordinate(15.0, 15.0));
  print("distance between (10,20) and (15,15) = $dist");

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '플러터 demo 페이지'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double _dist = 0.0;
  late Place _placeA;
  late Place _placeB;

  void _incrementCounter() {
    setState(() {
      Pointer<Int32> pointer = calloc.allocate(4);
      pointer.value = _counter;
      nativeAddPointer(pointer);
      _counter = pointer.value;

      nativeSayHello();
      final message = nativeSayWorld().toDartString();
      print(message);
    });
  }

  Place _createPlace(String name, double latitude, double longitude) {
    final nameUtf8 = name.toNativeUtf8();
    final place = nativeCreatePlace(nameUtf8, latitude, longitude);
    final nameString = place.name.toDartString();
    calloc.free(nameUtf8);

    final coordinate = place.coordinate;
    print('${nameString}\'s lat:${coordinate.latitude}, lon:${coordinate.longitude}');
    return place;
  }

  void _createPlaceA(double latitude, double longitude) {
    setState(() {
      print('tried to create placeA');
      _placeA = _createPlace('placeA', latitude, longitude);
      _updateDistanceAB();
    });
  }

  void _createPlaceB(double latitude, double longitude) {
    setState(() {
      print('tried to create placeB');
      _placeB = _createPlace('placeB', latitude, longitude);
      _updateDistanceAB();
    });
  }

  void _updateDistanceAB() {
    setState(() {
      final coordinateA = _placeA.coordinate;
      final coordinateB = _placeB.coordinate;
      _dist = nativeDistance(coordinateA, coordinateB);
      print('distance between (${coordinateA.latitude}, ${coordinateA.longitude})'
            ' and (${coordinateB.latitude}, ${coordinateB.longitude}) = $_dist');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter\n',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                _createPlaceA(1, 2);
              },
              child: Text(
                'create placeA(1,2)\n',
              ),
            ),
            TextButton(
              onPressed: () {
                _createPlaceB(3, 4);
              },
              child: Text(
                'create placeB(3,4)\n',
              ),
            ),
            Text(
                'update distance between placeA and placeB: ',
            ),
            Text(
                '$_dist',
                style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
