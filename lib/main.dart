import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: MainMenu())); //Routes

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         iconTheme: const IconThemeData(
    color: Color.fromARGB(255, 0, 255, 8), // Neon green for drawer icon
  ),
        title: const Text(
          "Hop! Hop! Hop! Hop! Hop! Hop! Hop! Hop! Hop! Hop! Hop! Hop!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color.fromARGB(255, 0, 255, 8), // Neon green
          ),
        ),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text("Play", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HoldJumpGame()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.green),
              title: const Text("About", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                showAboutDialog(
                  context: context,
                  applicationName: "Neon Hopper",
                  applicationVersion: "1.0",
                  children: [
                    const Text("A fun retro-style jumping game."),
                  ],
                );
              },
            ),
            ListTile(
  leading: const Icon(Icons.group, color: Colors.green),
  title: const Text("Group Info", style: TextStyle(color: Colors.white)),
  onTap: () {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupInfoPage()),
    );
  },
),

          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 0, 0, 0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Game title
        SizedBox(
  width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
  child: FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.center,
    child: Text(
      "Neon Hopper",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 48, // Base size for large screens
        color: const Color(0xFF39FF14),
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
        shadows: [
          Shadow(
            blurRadius: 10,
            color: Colors.greenAccent,
            offset: Offset(0, 0),
          ),
        ],
      ),
    ),
  ),
),

        const SizedBox(height: 50),

        // Play button
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HoldJumpGame()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            foregroundColor: Colors.greenAccent,
            shadowColor: Colors.greenAccent,
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.greenAccent, width: 2),
            ),
          ),
          child: const Text('PLAY'),
        ),
      ],
    ),
  ),
),

    );
  }
}


class HoldJumpGame extends StatefulWidget {
  const HoldJumpGame({Key? key}) : super(key: key);

  @override
  _HoldJumpGameState createState() => _HoldJumpGameState();
}

class _HoldJumpGameState extends State<HoldJumpGame> {
  double playerY = 1;
  double velocity = 0;
  final double gravity = -0.5;
  double jumpForce = 8.0;
  double holdBoost = 0.25;

  bool isJumping = false;
  bool isHolding = false;
  bool isGameOver = false;
  int score = 0;
List<TrailDot> trailDots = [];
final int maxTrailDots = 20;

List<PowerUp> powerUps = [];
final int maxPowerUps = 3;


  List<Obstacle> obstacles = [];
  Random random = Random();

  Timer? gameLoop;
  Timer? obstacleSpawner;

  double gameSpeed = 1.0;

  void resetGame() {
    playerY = 1;
    velocity = 0;
    isJumping = false;
    isHolding = false;
    isGameOver = false;
    score = 0;
    obstacles.clear();
    gameSpeed = 1.0;
  }

  void startGame() {
    resetGame();

    gameLoop = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!isGameOver) {
        updateGame();
      } else {
        gameLoop?.cancel();
        obstacleSpawner?.cancel();
        showGameOverDialog();
      }
    });

    // Spawn obstacles and power-ups periodically
obstacleSpawner = Timer.periodic(const Duration(seconds: 2), (_) {
  double height = 0.2 + random.nextDouble() * 0.4;
  obstacles.add(Obstacle(x: 1.2, height: height));

  // Spawn power-up randomly if under max count
  if (powerUps.length < maxPowerUps && random.nextInt(5) == 0) {
    double puX = 1.2 + random.nextDouble() * 0.5; // spawn just off right edge
    double puY = 0.0 + random.nextDouble() * 0.6; // reachable height, e.g. between 0 and 0.6 
    powerUps.add(PowerUp(x: puX, y: puY));
  }
});

  }

  void applyPowerUpEffect() {
  // Example: increase score by bonus
  score += 100;

  // Or temporarily increase jump force or slow obstacles
  holdBoost += 0.05;

  // Schedule reverting effect after a few seconds
  Timer(const Duration(seconds: 5), () {
    holdBoost -= 0.05;
  });
}


  void updateGame() {
    setState(() {
      gameSpeed += 0.001;

      if (isHolding && velocity < jumpForce) {
        velocity += holdBoost;
      }

      velocity += gravity;
      playerY -= velocity * 0.02;

      if (playerY > 1) {
        playerY = 1;
        velocity = 0;
        isJumping = false;
      }

      else {
  isJumping = true;
}

      if (playerY < -1) {
        playerY = -1;
        velocity = 0;
      }

      for (var ob in obstacles) {
        ob.x -= 0.03 * gameSpeed;
      }

      obstacles.removeWhere((ob) => ob.x < -1.2);

      for (var ob in obstacles) {
        if (ob.x < 0.1 && ob.x > -0.1 && playerY >= 1 - ob.height) {
          isGameOver = true;
        }
      }
      for (var pu in powerUps) {
  pu.x -= 0.03 * gameSpeed;
}

// Remove power-ups that moved off-screen
powerUps.removeWhere((pu) => pu.x < -1.2 || !pu.isActive);

for (var pu in powerUps) {
  // Simple collision detection: close enough horizontally and vertically
  if ((pu.x - 0).abs() < 0.1 && (pu.y - playerY).abs() < 0.3 && pu.isActive) {
    pu.isActive = false;  // power-up collected
    applyPowerUpEffect();
  }
}


      score++;
    });
trailDots.add(
  TrailDot(
    x: 0, // push older dots to the left
 // The player always stays in center X in this version
    y: playerY,
    opacity: 1.0,
  ),
);

// Limit trail length
if (trailDots.length > maxTrailDots) {
  trailDots.removeAt(0);
}

// Fade out trail

for (int i = 0; i < trailDots.length; i++) {
  trailDots[i].x -= 0.02 * gameSpeed; // Move left with game speed
  trailDots[i].y += 0.001 * gameSpeed;      //Drift down slightly
  trailDots[i].opacity *= 0.95;       // Fade out gradually
};


  }

  void onTapDown() {
    if (isGameOver) return;

    if (!isJumping && playerY >= 1) {
      isJumping = true;
      isHolding = true;
      velocity = 5.0;
    }
  }

  void onTapUp() {
    isHolding = false;
  }

  void showGameOverDialog() {
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => Dialog(
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "GAME OVER",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: Color.fromARGB(255, 0, 255, 8),
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.greenAccent,
                  offset: Offset(0, 0),
                ),
              ],
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Score: $score",
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 2,
              color: Color.fromARGB(255, 0, 255, 8),
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: BorderSide(color: Colors.greenAccent, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadowColor: Colors.greenAccent,
                    elevation: 10,
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "RESTART",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 2,
                        color: Color.fromARGB(255, 0, 255, 8),
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainMenu()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: BorderSide(color: Colors.greenAccent, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadowColor: Colors.greenAccent,
                    elevation: 10,
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "BACK TO MENU",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 2,
                        color: Color.fromARGB(255, 0, 255, 8),
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

}


  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    obstacleSpawner?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Power-ups (e.g. glowing blue circles)
...powerUps.where((pu) => pu.isActive).map((pu) {
  return Positioned.fill(
    child: Align(
      alignment: Alignment(pu.x.clamp(-1.0, 1.0), pu.y.clamp(-1.0, 1.0)),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 204, 0, 255),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 255, 0, 85).withOpacity(0.7),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    ),
  );
}).toList(),

            // Neon trail that follows the player both vertically and over time
...trailDots.map((dot) {
  return Positioned.fill(
    child: Align(
      alignment: Alignment(dot.x, dot.y.clamp(-1.0, 1.0)),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Color.fromARGB((dot.opacity * 255).toInt(), 0, 255, 8),
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}).toList(),

            // Player (circle with neon effect)
            Positioned.fill(
              child: Align(
                alignment: Alignment(0, playerY.clamp(-1.0, 1.0)),
                child: AnimatedContainer(       //animation
  duration: const Duration(milliseconds: 100),
  width: isJumping ? 40 : 50,   // Stretch when jumping
  height: isJumping ? 60 : 50,
  decoration: const BoxDecoration(
    color: Color.fromARGB(255, 0, 255, 8),
    shape: BoxShape.circle,
  ),
),

              ),
            ),

            // Obstacles (blocky and bright)
            ...obstacles.map((ob) {
              return Positioned.fill(
                child: Align(
                  alignment: Alignment(ob.x, 1),
                  child: Container(
                    width: 40,
                    height: MediaQuery.of(context).size.height * ob.height * 0.5,
                    color: Colors.red, // Bright red for obstacles
                  ),
                ),
              );
            }),

            // Score Display (retro arcade style)
            Positioned(
              top: 50,
              left: 20,
              child: Text(
                'Distance: $score m',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2, // pixelated text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Obstacle {
  double x;
  double height;
  Obstacle({required this.x, required this.height});
}
class TrailDot {
  double x;
  double y;
  double opacity;

  TrailDot({required this.x, required this.y, required this.opacity});
}

class PowerUp {
  double x;      // horizontal position (-1 to 1 range)
  double y;      // vertical position (reachable range for player)
  bool isActive; // if power-up is still available to collect

  PowerUp({required this.x, required this.y, this.isActive = true});
}
class GroupInfoPage extends StatelessWidget {
  const GroupInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 255, 8)),
        title: const Text(
          "Group Info",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 255, 8),
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Group Title
              Text(
                'Group Members:',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 255, 8),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'Courier',
                  shadows: [
                    Shadow(
                      blurRadius: 12,
                      color: Colors.greenAccent,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Members List
              const SizedBox(height: 20),
              // List of Members
              Text(
                '• Rhica May Juan\n'
                '• Kimberly De Jesus\n'
                '• Norlito Del Monte\n'
                '• Neil Jabess Buscay\n'
                '• Neo Calalang\n'
                '• Jerome Pimentel',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 255, 8),
                  fontSize: 20,
                  fontFamily: 'Courier',
                  letterSpacing: 1.5,
                  height: 1.5,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.greenAccent,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

