import 'dart:math';

import 'package:meta/meta.dart';

enum TileType {
  wall,
  empty,
}

class BoardTile {
  final Point position;
  TileType type;

  BoardTile({@required this.position, @required this.type});

  @override
  operator ==(other) =>
      other is BoardTile && position == other.position && type == other.type;

  @override
  String toString() => 'board tile at $position of type $type';
}
