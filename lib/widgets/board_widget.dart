import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_finder_visualizer/models/board.dart';
import 'package:path_finder_visualizer/models/board_tile.dart';

class BoardWidget extends StatefulWidget {
  final Board board;
  final bool canPlaceWalls;
  final bool canPlaceStart;
  final bool canPlaceEnd;

  const BoardWidget({
    Key key,
    @required this.board,
    @required this.canPlaceWalls,
    @required this.canPlaceStart,
    @required this.canPlaceEnd,
  }) : super(key: key);

  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  bool mouseDown = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double horizontalSize = constraints.maxWidth / widget.board.width;
      double verticalSize = constraints.maxHeight / widget.board.height;
      var tileSize = min(horizontalSize, verticalSize);
      return buildBoard(tileSize);
    });
  }

  Widget _buildTile(BoardTile tile, double size) => MouseRegion(
        onEnter: (event) {
          if (mouseDown && widget.canPlaceWalls && tile.type != TileType.wall) {
            widget.board.lines[tile.position.y][tile.position.x].type =
                TileType.wall;
            setState(() {});
          }
        },
        child: Listener(
          onPointerUp: (event) {
            print(tile.position);
            mouseDown = false;
          },
          onPointerDown: (event) => mouseDown = true,
          child: SizedBox(
            width: size,
            height: size,
            child: Container(color: _realTileColor(tile)),
          ),
        ),
      );

  Widget buildRow(List<BoardTile> row, double tileSize) {
    List<Widget> tiles = List<Widget>();
    row.forEach((boardTile) => tiles.add(_buildTile(boardTile, tileSize)));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: tiles);
  }

  Widget buildBoard(double tileSize) {
    List<Widget> rows = List<Widget>();
    widget.board.lines.forEach((row) => rows.add(buildRow(row, tileSize)));
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: rows);
  }

  Color _realTileColor(BoardTile tile) {
    return tile.type == TileType.empty ? Colors.white : Colors.black;
  }

  Color _tempTileColorFromPosition(Point position) {
    if (position.x % 2 == 0 && position.y % 2 == 0 ||
        position.x % 2 == 1 && position.y % 2 == 1) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}
