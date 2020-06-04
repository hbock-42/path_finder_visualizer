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
  bool get canPlaceWalls => selectedButton[0];
  bool get canPlaceStart => selectedButton[1];
  bool get canPlaceEnd => selectedButton[2];
  List<bool> selectedButton = List<bool>.filled(3, false);

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButtons(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                color: Colors.black,
                selectedColor: Colors.blue,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('place walls'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('move start'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('move end'),
                  ),
                ],
                isSelected: selectedButton,
                onPressed: (index) {
                  setState(() {
                    for (var i = 0; i < selectedButton.length; i++) {
                      selectedButton[i] = false;
                    }
                    selectedButton[index] = true;
                    print(selectedButton);
                  });
                },
              )
            ],
          ),
          BoardWidget(
            board: board,
            canPlaceWalls: canPlaceWalls,
            canPlaceStart: canPlaceStart,
            canPlaceEnd: canPlaceEnd,
          ),
        ],
      ),
    );
  }
}
