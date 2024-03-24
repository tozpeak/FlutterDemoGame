import 'package:flutter/cupertino.dart';

class CustomPhysics {

  static Offset? collisionSphereToBox(Rect sphere, Rect box) {
    if(!sphere.overlaps(box)) return null;
    var aabbIntersection = sphere.intersect(box);

    final List<Offset> withinRadius = [
      aabbIntersection.topLeft,
      aabbIntersection.topRight,
      aabbIntersection.bottomLeft,
      aabbIntersection.bottomRight,
    ];
    Offset center = sphere.center;
    //double radius = sphere.width / 2;

    for (var i = withinRadius.length-1; i > 0; i--) {
      for (var j = 0; j < i; j++) {
        if(withinRadius[j] == withinRadius[i]) {
          withinRadius.removeAt(i);
          break;
        }
      }
    }
    //print(withinRadius);

    if(withinRadius.length % 2 == 0) {
      Offset expected = withinRadius.fold(
        Offset.zero, 
        (previousValue, element) => previousValue + element / (withinRadius.length * 1.0)
      );
      withinRadius.clear();
      withinRadius.add(expected);
    }

    //withinRadius.removeWhere((element) => !isWithinRadius(element, center, radius));
    //print(withinRadius);

    if(withinRadius.isEmpty) return null;

    Offset target = withinRadius.fold(
      Offset.infinite, 
      (previousValue, element) => 
        ((previousValue - center).distance < (element - center).distance) 
        ? previousValue
        : element
    );

    Offset normal = center - target;

    // print({
    //   "target": target,
    //   "center": center,
    //   "normal": normal
    // });

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