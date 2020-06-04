import 'dart:math';

import 'board_tile.dart';

class Board {
  List<List<BoardTile>> lines;
  int get width => lines.first.length;
  int get height => lines.length;
  List<int> verticalTunnelPositions;
  List<int> horizontalTunnelPositions;
  bool get hasVerticalTunnel => verticalTunnelPositions.length > 0;
  bool get hasHorizontalTunnel => horizontalTunnelPositions.length > 0;

  Board(this.lines) {
    _computeOpenings(lines);
  }

  Board.empty(int width, int height) {
    lines = List<List<BoardTile>>.generate(
      height,
      (y) => List<BoardTile>.generate(
        width,
        (x) => BoardTile(
          position: Point(x, y),
          type: TileType.empty,
        ),
      ),
    );
    _computeOpenings(lines);
  }

  Board.random(int width, int height, double wallRatio,
      {bool hasHorizontalTunnel = false, bool hasVerticalTunnel = false}) {
    wallRatio = max(0, min(1, wallRatio));
    Random rand = Random.secure();
    lines = List<List<BoardTile>>();
    for (var y = 0; y < height; y++) {
      lines.add(List<BoardTile>());
      for (var x = 0; x < width; x++) {
        var randBoardTile = BoardTile(
          position: Point(x, y),
          type: _createTileType(
            width,
            height,
            x,
            y,
            rand,
            wallRatio,
            hasHorizontalTunnel: hasHorizontalTunnel,
            hasVerticalTunnel: hasVerticalTunnel,
          ),
        );
        lines[y].add(randBoardTile);
      }
    }
    _computeOpenings(lines);
  }

  static List<BoardTile> parseRow(String row, int lineNumber) {
    List<BoardTile> line = List<BoardTile>();
    for (var i = 0; i < row.length; i++) {
      TileType type;
      if (row[i] == "#") {
        type = TileType.wall;
      } else if (row[i] == " ") {
        type = TileType.empty;
      }
      line.add(BoardTile(position: Point(i, lineNumber), type: type));
    }
  }

  void _computeOpenings(List<List<BoardTile>> lines) {
    var openingLeft = List<Point>();
    var openingRight = List<Point>();
    var openingTop = List<Point>();
    var openingBottom = List<Point>();
    for (var y = 0; y < lines.length; y++) {
      for (var x = 0; x < lines[y].length; x++) {
        var currentTile = lines[y][x];
        if (y == 0 && currentTile.type == TileType.empty) {
          openingTop.add(currentTile.position);
        } else if (y + 1 == lines.length &&
            currentTile.type == TileType.empty) {
          openingBottom.add(currentTile.position);
        } else if (x == 0 && currentTile.type == TileType.empty) {
          openingLeft.add(currentTile.position);
        } else if (x + 1 == lines[y].length &&
            currentTile.type == TileType.empty) {
          openingRight.add(currentTile.position);
        }
      }
    }
    verticalTunnelPositions = List<int>();
    horizontalTunnelPositions = List<int>();
    openingLeft.forEach((posLeft) {
      openingRight.forEach((posRigh) {
        if (posLeft.y == posRigh.y) {
          horizontalTunnelPositions.add(posLeft.y);
        }
      });
    });
    openingTop.forEach((posTop) {
      openingBottom.forEach((posBot) {
        if (posTop.x == posBot.x) {
          verticalTunnelPositions.add(posTop.x);
        }
      });
    });
  }

  TileType _createTileType(
    int boardWidth,
    int boardHeight,
    int tileX,
    int tileY,
    Random rand,
    double wallRatio, {
    bool hasHorizontalTunnel,
    bool hasVerticalTunnel,
  }) {
    if (hasHorizontalTunnel &&
        tileY == (boardHeight / 2).floor() &&
        (tileX == 0 || tileX == boardWidth - 1)) return TileType.empty;
    if (hasVerticalTunnel &&
        tileX == (boardWidth / 2).floor() &&
        (tileY == 0 || tileY == boardHeight - 1)) return TileType.empty;
    if (tileX == 0 ||
        tileX + 1 == boardWidth ||
        tileY == 0 ||
        tileY + 1 == boardHeight) return TileType.wall;

    return rand.nextDouble() < wallRatio ? TileType.wall : TileType.empty;
  }
}
