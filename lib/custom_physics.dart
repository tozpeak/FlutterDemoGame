// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:math';
import 'dart:ui';

class CustomPhysics {

  static var _debugLevel = 0;

  static List<Offset> collisionSphereToBox(Rect sphere, Rect box, {debug = false}) {
    _debugLevel = debug ? 2 : 0;
    if(!sphere.overlaps(box)) return const [];

    if(_debugLevel > 0) print("collision with $box (sphere: ${sphere.center}, ${sphere.width/2})");

    var boxLineStrip = [
      box.topLeft,
      box.topRight,
      box.bottomRight,
      box.bottomLeft,
      box.topLeft,
    ];

    final normals = <Offset>[];

    for (var i = 0; i < boxLineStrip.length-1; i++) {
      final collision = collideSphereWithLine(
        sphere, 
        boxLineStrip[i], 
        boxLineStrip[i+1]
      );

      if(collision != null) { 
        normals.add(collision); 
        if(_debugLevel >= 1) print({
          "a": boxLineStrip[i], 
          "b": boxLineStrip[i+1],
          "n": collision,
        });
        //return Offset.fromDirection(collision.direction);
      }
    }

    return normals;
  }

  static Offset? collideSphereWithLine(Rect sphere, Offset pointA, Offset pointB) {
    final origin = pointA;
    final b = pointB - origin; //line to collide with in local vector form
    final c = sphere.center - origin; //local shpere center
    //scaled projection c on b, where 0 = on point A, 1 = on point B
    //proj = c*b / |b|
    //scaled_proj = proj / |b| = c*b / (|b|^2)
    final scaled_proj = dotProduct(b, c) / b.distanceSquared;
    final d = b * clampDouble(scaled_proj, 0, 1); //getting point of deepest colision

    var n = c - d; //normal from line to the shpere center

    final n_dist = n.distance;
    final radius = sphere.width / 2;
    if(n_dist > radius) return null; //no collision

    var force_coef = min((radius - n_dist)/n_dist, 0.00001);
    var flip = false;

    final leftBNormal = Offset(b.dy, -b.dx);
    if(dotProduct(n, leftBNormal) <= 0) {
      //sphere got center into the box, flip the push vector
      n = -n;
      force_coef += radius/n_dist;
      flip = true;
    }

    force_coef = 1;

    if(_debugLevel == 2) print({
      "origin": origin,
      "b": b,
      "c": c,
      "pr": scaled_proj,
      "d": d,
      "n": n,
      "n_d": n_dist,
      "left_norm": leftBNormal,
      "flip": flip
    });

    return n * force_coef;
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