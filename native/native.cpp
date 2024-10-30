#include <cstdio>
#include <cstdlib>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <iostream>
#include "native.h"


EXTERNC
int32_t simpleAdd(int32_t x, int32_t y) {
    return x + y;
};

EXTERNC
int32_t simpleDiff(int32_t x, int32_t y) {
    return x - y;
};

EXTERNC
int32_t simpleMultiple(int32_t x, int32_t y) {
    return x * y;
};

EXTERNC
void addPointer(int32_t* original) {
    (*original) += 1;
};

EXTERNC
void say_hello() {
    printf("Hello");
};

EXTERNC
char *say_world() {
    std::string str = "World";
    char* ch = strcpy(new char[str.length() + 1], str.c_str());
    return ch;
};

EXTERNC
struct Coordinate create_coordinate(double latitude, double longitude) {
    struct Coordinate coordinate;
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
    return coordinate;
}

EXTERNC
struct Place create_place(char *name, double latitude, double longitude) {
    struct Place place;
    place.name = name;
    place.coordinate = create_coordinate(latitude, longitude);
    return place;
}

EXTERNC
double distance(struct Coordinate c1, struct Coordinate c2) {
    double xd = c2.latitude - c1.latitude;
    double yd = c2.longitude - c1.longitude;
    return sqrt(xd*xd + yd*yd);
}