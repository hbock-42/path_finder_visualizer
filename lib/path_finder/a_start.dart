import 'dart:math';

import 'package:meta/meta.dart';
import 'package:path_finder_visualizer/models/board.dart';
import 'package:path_finder_visualizer/models/board_tile.dart';

import 'base_path_finder.dart';

class AStar implements BasePathFinder {
  final Board board;
  final Point start;
  final Point end;
  List<Point> path;
  Random rand;

  AStar({
    @required this.board,
    @required this.start,
    @required this.end,
  });

  List<Point> getPath() {
    rand = Random.secure();
    Set<Point> openSet = Set<Point>();
    openSet.add(start);

    var cameFrom = Map<Point, Point>();

    var gScores = Map<Point, double>();
    gScores[start] = 0;

    var fScores = Map<Point, double>();
    fScores[start] = minCostToEnd(start);

    while (openSet.length > 0) {
      Point<num> current = getPointWithLowestFscore(openSet, fScores);
      if (current == end) {
        return _reconstructPath(cameFrom, current);
      }
      openSet.remove(current);
      List<Point> neighbors = _getNeighbors(current);
      for (var neighbor in neighbors) {
        var tentativeGScore = gScores[current] + 1;
        if (!gScores.containsKey(neighbor)) {
          gScores[neighbor] = double.maxFinite;
        }
        if (tentativeGScore < gScores[neighbor]) {
          cameFrom[neighbor] = current;
          gScores[neighbor] = tentativeGScore;
          fScores[neighbor] = gScores[neighbor] + minCostToEnd(neighbor);
          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }
    return List<Point>();
  }

  List<Point> _getNeighbors(Point current) {
    var possibleNeighbors = List<Point>();
    possibleNeighbors.add(current + Point(0, -1));
    possibleNeighbors.add(current + Point(0, 1));
    possibleNeighbors.add(current + Point(-1, 0));
    possibleNeighbors.add(current + Point(1, 0));
    var neighbors = List<Point>();
    for (int i = 0; i < possibleNeighbors.length; i++) {
      if (board.hasHorizontalTunnel) {
        if (possibleNeighbors[i].x < 0 &&
            board.horizontalTunnelPositions.contains(possibleNeighbors[i].y)) {
          possibleNeighbors[i] = Point(board.width - 1, possibleNeighbors[i].y);
        } else if (possibleNeighbors[i].x == board.width &&
            board.horizontalTunnelPositions.contains(possibleNeighbors[i].y)) {
          possibleNeighbors[i] = Point(0, possibleNeighbors[i].y);
        }
      }

      if (board.hasVerticalTunnel) {
        if (possibleNeighbors[i].y < 0 &&
            board.verticalTunnelPositions.contains(possibleNeighbors[i].x)) {
          possibleNeighbors[i] =
              Point(possibleNeighbors[i].x, board.height - 1);
        } else if (possibleNeighbors[i].y == board.height &&
            board.verticalTunnelPositions.contains(possibleNeighbors[i].x)) {
          possibleNeighbors[i] = Point(possibleNeighbors[i].x, 0);
        }
      }

      if (_isValidPointPath(possibleNeighbors[i])) {
        neighbors.add(possibleNeighbors[i]);
      }
    }
    return neighbors;
  }

  bool _isValidPointPath(Point point) {
    if (point.x < 0 ||
        point.y < 0 ||
        point.x >= board.width ||
        point.y >= board.height) {
      return false;
    }

    if (board.lines[point.y][point.x].type == TileType.wall) {
      return false;
    }

    return true;
  }

  List<Point> _reconstructPath(Map<Point, Point> cameFrom, Point current) {
    var totalPath = [current];
    while (cameFrom.containsKey(current)) {
      current = cameFrom[current];
      totalPath.insert(0, current);
    }
    return totalPath;
  }

  Point getPointWithLowestFscore(
      Set<Point> openSet, Map<Point, double> fScores) {
    Point<num> winner = openSet.first;
    openSet.forEach((point) {
      if (fScores[point] < fScores[winner]) {
        winner = point;
      } else if (fScores[point] == fScores[winner] && rand.nextBool()) {
        // we change the winner randomly so if there is multiple path with the same score
        // this is not always the same that will win
        winner = point;
      }
    });
    return winner;
  }

  double minCostToEnd(Point point) =>
      minHorizontalCost(point) + minVerticalCost(point);

  double minHorizontalCost(Point point) {
    double baseCost = (end.x - point.x).abs().toDouble();
    if (board.hasHorizontalTunnel) {
      // cost from point to tunnel + 1 (moving from tunnel entrance to exit) + cost from exist to end
      double tunneledCost;
      var entrance = closestHorizontalTunnel(point);
      double costPointEntrance = (point.x - entrance.x).abs().toDouble();
      var exit = getHorizontalTunnelExit(entrance);
      double costExitToEnd = (exit.x - end.x).abs().toDouble();
      tunneledCost = costPointEntrance + 1 + costExitToEnd;
      if (tunneledCost < baseCost) {
        return tunneledCost;
      }
    }
    return baseCost;
  }

  Point getHorizontalTunnelExit(Point entrance) {
    return Point(entrance.x == 0 ? board.width - 1 : 0, entrance.y);
  }

  Point closestHorizontalTunnel(Point point) {
    bool takeLeft = (point.x - 0).abs().toDouble() <
        (point.x - board.width - 1).abs().toDouble();
    Point closest;
    board.horizontalTunnelPositions.forEach((yPos) {
      if (closest == null ||
          ((yPos - point.y) < (closest.y - point.y).abs().toDouble())) {
        closest = Point(takeLeft ? 0 : board.width - 1, yPos);
      } else if ((yPos - point.y) == (closest.y - point.y).abs().toDouble() &&
          rand.nextBool()) {
        closest = Point(takeLeft ? 0 : board.width - 1, yPos);
      }
    });
    return closest;
  }

  double minVerticalCost(Point point) {
    double baseCost = (end.y - point.y).abs().toDouble();
    if (board.hasVerticalTunnel) {
      // cost from point to tunnel + 1 (moving from tunnel entrance to exit) + cost from exist to end
      double tunneledCost;
      var entrance = closestVerticalTunnel(point);
      double costPointEntrance = (point.y - entrance.y).abs().toDouble();
      var exit = getVerticalTunnelExit(entrance);
      double costExitToEnd = (exit.y - end.y).abs().toDouble();
      tunneledCost = costPointEntrance + 1 + costExitToEnd;
      if (tunneledCost < baseCost) {
        return tunneledCost;
      }
    }
    return baseCost;
  }

  Point getVerticalTunnelExit(Point entrance) {
    return Point(entrance.y == 0 ? board.height - 1 : 0, entrance.x);
  }

  Point closestVerticalTunnel(Point point) {
    bool takeTop = (point.y - 0).abs().toDouble() <
        (point.y - board.height - 1).abs().toDouble();
    Point closest;
    board.verticalTunnelPositions.forEach((xPos) {
      if (closest == null ||
          ((xPos - point.x) < (closest.x - point.x).abs().toDouble())) {
        closest = Point(xPos, takeTop ? 0 : board.height - 1);
      } else if ((xPos - point.x) == (closest.x - point.x).abs().toDouble() &&
          rand.nextBool()) {
        closest = Point(xPos, takeTop ? 0 : board.height - 1);
      }
    });
    return closest;
  }
}
