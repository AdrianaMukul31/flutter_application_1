import 'dart:async'; // Importa el paquete para usar temporizadores (Timers).

import 'package:flutter/material.dart'; // Importa los widgets de Flutter.
import 'package:flutter/services.dart'; // Para leer eventos del teclado.
import 'package:flutter_application_1/ball.dart'; // Importa la clase de la pelota.
import 'package:flutter_application_1/button.dart'; // Importa la clase para los botones de control.
import 'package:flutter_application_1/missile.dart'; // Importa la clase del misil.
import 'package:flutter_application_1/player.dart'; // Importa la clase del jugador.

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState(); // Crea el estado de la página de inicio.
}

enum direction { LEFT, RIGHT } // Define las direcciones de movimiento de la pelota.

class _HomePageState extends State<HomePage> {
  static double playerX = 0; // Posición inicial del jugador en el eje X (horizontal).
  double missileX = playerX; // Posición inicial del misil (igual al jugador).
  double missileHeight = 10; // Altura inicial del misil.
  bool midShot = false; // Determina si el misil está en vuelo.
  double ballX = 0.5; // Posición inicial de la pelota en el eje X.
  double ballY = 1; // Posición inicial de la pelota en el eje Y.
  var ballDirection = direction.LEFT; // Dirección inicial de la pelota (izquierda).
  int score = 0; // Puntuación inicial del jugador.

  void startGame() {
    double time = 0; // Tiempo de simulación para el movimiento del proyectil.
    double height = 0; // Altura calculada del proyectil.
    double velocity = 60; // Velocidad de lanzamiento del proyectil.

    Timer.periodic(Duration(milliseconds: 10), (timer) {
      // Temporizador para actualizar la posición de la pelota a intervalos regulares.
      height = -5 * time * time + velocity * time; // Ecuación de movimiento para la pelota (física básica).
      if (height < 0) {
        time = 0; // Si la pelota toca el suelo, reinicia el tiempo.
      }
      setState(() {
        ballY = heightToPosition(height); // Actualiza la posición de la pelota en pantalla.
      });

      // Cambia la dirección de la pelota si toca los límites de la pantalla.
      if (ballX - 0.005 < -1) {
        ballDirection = direction.RIGHT;
      } else if (ballX + 0.005 > 1) {
        ballDirection = direction.LEFT;
      }

      // Mueve la pelota en la dirección indicada.
      if (ballDirection == direction.LEFT) {
        setState(() {
          ballX -= 0.005;
        });
      } else if (ballDirection == direction.RIGHT) {
        setState(() {
          ballX += 0.005;
        });
      }

      // Verifica si el jugador pierde (cuando la pelota lo toca).
      if (playerDies()) {
        timer.cancel(); // Detiene el juego si el jugador muere.
        _showDialog("Juego Perdido ❌"); // Muestra el mensaje de "Juego Perdido".
      }
      time += 0.1; // Incrementa el tiempo de simulación.
    });
  }

  void _showDialog(String message) {
    // Muestra un cuadro de diálogo con el mensaje indicado.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[700], // Fondo gris oscuro para el cuadro de diálogo.
          title: Center(
            child: Text(
              message, // Mensaje de victoria o derrota.
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el cuadro de diálogo.
                if (message == "¡Juego Ganado! 🌟") {
                  resetGame(); // Reinicia el juego si el mensaje es de victoria.
                }
              },
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void moveLeft() {
    // Mueve al jugador hacia la izquierda.
    setState(() {
      if (playerX - 0.1 >= -1) { // Verifica que el jugador no se salga de la pantalla.
        playerX -= 0.1;
      }
      if (!midShot) {
        missileX = playerX; // Si el misil no está en vuelo, se coloca sobre el jugador.
      }
    });
  }

  void moveRight() {
    // Mueve al jugador hacia la derecha.
    setState(() {
      if (playerX + 0.1 <= 1) { // Verifica que el jugador no se salga de la pantalla.
        playerX += 0.1;
      }
      if (!midShot) {
        missileX = playerX; // Si el misil no está en vuelo, se coloca sobre el jugador.
      }
    });
  }

  void fireMissile() {
    // Lanza el misil si no está en vuelo.
    if (!midShot) {
      Timer.periodic(Duration(milliseconds: 20), (timer) {
        midShot = true; // El misil está en vuelo.
        setState(() {
          missileHeight += 10; // El misil sube con cada actualización.
        });

        // Cuando el misil alcanza el límite superior de la pantalla, se reinicia.
        if (missileHeight > MediaQuery.of(context).size.height * 3 / 4) {
          resetMissile();
          timer.cancel();
        }

        // Verifica si el misil impacta a la pelota.
        if (ballY > heightToPosition(missileHeight) && (ballX - missileX).abs() < 0.03) {
          setState(() {
            score += 1; // Aumenta el puntaje al impactar con la pelota.
            ballX = 0; // Reinicia la posición de la pelota después del impacto.
          });
          resetMissile();
          timer.cancel();

          // Si el jugador alcanza 5 puntos, muestra el mensaje de victoria.
          if (score == 5) {
            _showDialog("¡Juego Ganado! 🌟");
          }
        }
      });
    }
  }

  double heightToPosition(double height) {
    // Convierte la altura física en una posición en la pantalla.
    double totalHeight = MediaQuery.of(context).size.height * 3 / 4; // Calcula la altura total disponible.
    return 1 - 2 * height / totalHeight; // Mapea la altura a la posición vertical de la pantalla.
  }

  void resetMissile() {
    // Reinicia la posición del misil y su estado.
    missileX = playerX;
    missileHeight = 0;
    midShot = false;
  }

  void resetGame() {
    // Reinicia el estado del juego (puntuación, pelota y jugador).
    setState(() {
      score = 0;
      ballX = 0.5;
      ballY = 1;
      playerX = 0;
    });
  }

  bool playerDies() {
    // Verifica si el jugador muere (cuando la pelota lo toca).
    return (ballX - playerX).abs() < 0.05 && ballY > 0.95;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(), // Necesario para detectar las teclas presionadas.
      autofocus: true, // Activa el foco automático para detectar las teclas.
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft(); // Mueve al jugador hacia la izquierda.
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight(); // Mueve al jugador hacia la derecha.
        }
        if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          fireMissile(); // Lanza el misil al presionar la barra espaciadora.
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.yellow[100], // Color de fondo del área de juego.
              child: Stack(
                alignment: Alignment.topCenter, // Alinea los elementos en el centro.
                children: [
                  Positioned(
                    top: 20,
                    child: Text(
                      'Puntuación: $score', // Muestra la puntuación actual.
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  MyBall(ballX: ballX, ballY: ballY), // Muestra la pelota.
                  MyMissile(height: missileHeight, missileX: missileX), // Muestra el misil.
                  MyPlayer(playerX: playerX), // Muestra el jugador.
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey, // Color de fondo del área de botones.
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Alinea los botones.
                children: [
                  MyButton(icon: Icons.play_arrow, function: startGame), // Botón para iniciar el juego.
                  MyButton(icon: Icons.arrow_back, function: moveLeft), // Botón para mover izquierda.
                  MyButton(icon: Icons.arrow_upward, function: fireMissile), // Botón para disparar misil.
                  MyButton(icon: Icons.arrow_forward, function: moveRight), // Botón para mover derecha.
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
