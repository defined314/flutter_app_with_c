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

final int Function() nativeMinusCountCpp =
nativeLib.lookup<NativeFunction<Int32 Function()>>("minusCountCpp").asFunction();

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

final Coordinate Function(Coordinate p1) nativeModifyCoordinate =
nativeLib.lookup<NativeFunction<Coordinate Function(Coordinate)>>("modify_coordinate").asFunction();


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
  int _counter_add = 0;
  int _counter_minus = 0;
  double _dist = 0.0;
  late Place _placeA;
  late Place _placeB;
  List<Place> _placeList = [];  // 구조체 배열 테스트용

  void _incrementCounter() {
    setState(() {
      Pointer<Int32> pointer = calloc.allocate(4);
      pointer.value = _counter_add;
      nativeAddPointer(pointer);
      _counter_add = pointer.value;

      _counter_minus = nativeMinusCountCpp();

      // nativeSayHello();
      // final message = nativeSayWorld().toDartString();
      // print(message);
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
    // print('tried to create placeA');
    _placeA = _createPlace('placeA', latitude, longitude);
  }

  void _createPlaceB(double latitude, double longitude) {
    // print('tried to create placeB');
    _placeB = _createPlace('placeB', latitude, longitude);
  }

  void _updateDistanceAB() {
    setState(() {
      if (_placeList.length <= 1) {
        _placeList.add(_placeA);
        _placeList.add(_placeB);
      } else {
        // print('_placeA old: ${_placeList[0].coordinate.latitude},'
        //     '${_placeList[0].coordinate.longitude}'
        //     ', _placeB old: ${_placeList[1].coordinate.latitude},'
        //     '${_placeList[1].coordinate.longitude}');
        _placeList[0] = _placeA;
        _placeList[1] = _placeB;
      }
      // print('_placeA new: ${_placeList[0].coordinate.latitude},'
      //     '${_placeList[0].coordinate.longitude}'
      //     ', _placeB new: ${_placeList[1].coordinate.latitude},'
      //     '${_placeList[1].coordinate.longitude}');
      final coordinateA = _placeList[0].coordinate;
      final coordinateB = _placeList[1].coordinate;
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
            // cpp에서 pointer 수정
            Text(
              '$_counter_add\n',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'minus count in cpp:',
            ),
            // cpp 내의 변수 수정하여 반환
            Text(
              '$_counter_minus\n',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                _createPlaceA(0, 0);
                _createPlaceB(0, 0);
                _updateDistanceAB();
              },
              child: Text(
                '\ncreate placeA and placeB to (0, 0)\n',
              ),
            ),
            TextButton(
              onPressed: () {
                _createPlaceA(7, 9);
                _createPlaceB(4, 2);
                _updateDistanceAB();
              },
              child: Text(
                'create placeA(7, 9), placeA(4, 2)\n',
              ),
            ),
            // cpp에서 _place.coordinate의 lat/lon 값 수정
            TextButton(
              onPressed: () {
                _placeA.coordinate =
                    nativeModifyCoordinate(_placeA.coordinate);
                _updateDistanceAB();
              },
              child: Text(
                'modify placeA(+1, +1) in cpp\n',
              ),
            ),
            // _placeList 내 coordinate 이용하여 A와 B 사이 거리 확인
            Text(
                '\ncheck distance between placeA and placeB: ',
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
