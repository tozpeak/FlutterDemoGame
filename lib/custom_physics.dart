import 'package:flutter/cupertino.dart';

class CustomPhysics {

  static Offset? collisionSphereToBox(Rect sphere, Rect box, double value) {
    var aabbIntersection = sphere.intersect(box);
    if(aabbIntersection.isEmpty) return null;

    final List<Offset> withinRadius = [
      aabbIntersection.topLeft,
      aabbIntersection.topRight,
      aabbIntersection.bottomLeft,
      aabbIntersection.bottomRight,
    ];
    Offset center = sphere.center;
    double radius = sphere.width / 2;

    withinRadius.removeWhere((element) => !isWithinRadius(element, center, radius));

    if(withinRadius.isEmpty) return null;

    Offset normal = withinRadius.fold(
      Offset.zero, 
      (previousValue, element) => previousValue + (center - element)
    );

    return Offset.fromDirection(normal.direction);
  }

  static Offset reflectSpeed(Offset speed, Offset normal) {
    //n2 = n1 - 2( n1.s )s
    return speed - normal * 2 * dotProduct(speed, normal);
  }

  static double dotProduct(Offset a, Offset b) {
    return a.dx * b.dx + a.dy *b.dy;
  }

  static bool isWithinRadius(Offset a, Offset b, double radius) {
    return (b - a).distance <= radius;
  }

}