import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/ball.dart';
import 'package:flutter_application_1/button.dart';
import 'package:flutter_application_1/missile.dart';
import 'package:flutter_application_1/player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum direction { LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  static double playerX = 0;
  double missileX = playerX;
  double missileHeight = 10;
  bool midShot = false;
  double ballX = 0.5;
  double ballY = 1;
  var ballDirection = direction.LEFT;
  int score = 0; // Variable para la puntuación

  void startGame() {
    double time = 0;
    double height = 0;
    double velocity = 60;

    Timer.periodic(Duration(milliseconds: 10), (timer) {
      height = -5 * time * time + velocity * time;
      if (height < 0) {
        time = 0;
      }
      setState(() {
        ballY = heightToPosition(height);
      });

      if (ballX - 0.005 < -1) {
        ballDirection = direction.RIGHT;
      } else if (ballX + 0.005 > 1) {
        ballDirection = direction.LEFT;
      }

      if (ballDirection == direction.LEFT) {
        setState(() {
          ballX -= 0.005;
        });
      } else if (ballDirection == direction.RIGHT) {
        setState(() {
          ballX += 0.005;
        });
      }

      if (playerDies()) {
        timer.cancel();
        _showDialog();
      }
      time += 0.1;
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[700],
          title: Center(
            child: Text(
              "Juego Perdido",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void moveLeft() {
    setState(() {
      if (playerX - 0.1 >= -1) {
        playerX -= 0.1;
      }
      if (!midShot) {
        missileX = playerX;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (playerX + 0.1 <= 1) {
        playerX += 0.1;
      }
      if (!midShot) {
        missileX = playerX;
      }
    });
  }

  void fireMissile() {
    if (!midShot) {
      Timer.periodic(Duration(milliseconds: 20), (timer) {
        midShot = true;
        setState(() {
          missileHeight += 10;
        });

        if (missileHeight > MediaQuery.of(context).size.height * 3 / 4) {
          resetMissile();
          timer.cancel();
        }

        if (ballY > heightToPosition(missileHeight) && (ballX - missileX).abs() < 0.03) {
          setState(() {
            score += 1; // Aumentar la puntuación
            ballX = 0;  // Reiniciar la posición de la pelota
          });
          resetMissile();
          timer.cancel();
        }
      });
    }
  }

  double heightToPosition(double height) {
    double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
    return 1 - 2 * height / totalHeight;
  }

  void resetMissile() {
    missileX = playerX;
    missileHeight = 0;
    midShot = false;
  }

  bool playerDies() {
    return (ballX - playerX).abs() < 0.05 && ballY > 0.95;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
        if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          fireMissile();
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.yellow[100],
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 20,
                    child: Text(
                      'Puntuación: $score', // Muestra la puntuación
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  MyBall(ballX: ballX, ballY: ballY),
                  MyMissile(height: missileHeight, missileX: missileX),
                  MyPlayer(playerX: playerX),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(icon: Icons.play_arrow, function: startGame),
                  MyButton(icon: Icons.arrow_back, function: moveLeft),
                  MyButton(icon: Icons.arrow_upward, function: fireMissile),
                  MyButton(icon: Icons.arrow_forward, function: moveRight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
