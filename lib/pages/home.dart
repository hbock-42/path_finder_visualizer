import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_finder_visualizer/models/board.dart';
import 'package:path_finder_visualizer/widgets/board_widget.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Board board;
  bool canPlaceWalls = true;

  @override
  void initState() {
    board = Board.empty(80, 80);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              CupertinoSwitch(
                onChanged: (bool value) =>
                    setState(() => canPlaceWalls = value),
                value: canPlaceWalls,
              ),
            ],
          ),
          BoardWidget(
            board: board,
            canPlaceWalls: canPlaceWalls,
          ),
        ],
      ),
    );
  }
}
