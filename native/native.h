// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#define _CRT_SECURE_NO_WARNINGS

#define EXTERNC extern "C" __attribute__((visibility("default"))) __attribute__((used))
//#define EXTERNC __attribute__((visibility("default"))) __attribute__((used))


EXTERNC
int32_t simpleAdd(int32_t x, int32_t y);
EXTERNC
int32_t simpleDiff(int32_t x, int32_t y);
EXTERNC
int32_t simpleMultiple(int32_t x, int32_t y);
EXTERNC
void addPointer(int32_t* original);
EXTERNC
int32_t minusCountCpp();

EXTERNC
void say_hello();
EXTERNC
char *say_world();

EXTERNC
struct Coordinate
{
    double latitude;
    double longitude;
};
EXTERNC
struct Place
{
    char *name;
    struct Coordinate coordinate;
};

EXTERNC
struct Coordinate create_coordinate(double latitude, double longitude);
EXTERNC
struct Place create_place(char *name, double latitude, double longitude);
EXTERNC
double distance(struct Coordinate, struct Coordinate);

EXTERNC
struct Coordinate modify_coordinate(struct Coordinate c_old);
