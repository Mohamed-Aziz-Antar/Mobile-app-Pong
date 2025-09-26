import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sensors_plus/sensors_plus.dart';


class ClassicMode extends StatefulWidget {
  const ClassicMode({Key? key}) : super(key: key);

  @override
  State<ClassicMode> createState() => _ClassicModeState();
}

class _ClassicModeState extends State<ClassicMode> with WidgetsBindingObserver {
  double playerPaddleY = 175.0; // Initial position for player paddle
  double aiPaddleY = 175.0; // Initial position for AI paddle
  double ballX = 175.0; // Ball X position
  double ballY = 195.0; // Ball Y position
  double ballSpeedX = 3.0; // Ball horizontal speed
  double ballSpeedY = 3.0; // Ball vertical speed
  int playerScore = 0; // Player score
  int aiScore = 0; // AI score
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  double _targetPaddleY = 175.0; // Target position for smooth movement
  final double _smoothingFactor = 0.2; // Smoothing factor for paddle movement
  final double _accelerometerSensitivity = 10.0; // Sensitivity for accelerometer input
  bool _isGamePaused = true; // Start with game paused until settings are chosen
  bool _gameOver = false; // Flag to track if game is over

  // Game settings
  double _gameSpeedMultiplier = 1.0; // Default speed multiplier
  double _aiPaddleSpeed = 2.0; // Default AI paddle speed
  int _pointsToWin = 5; // Default points to win

  @override
  void initState() {
    super.initState();
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    // Listen to accelerometer events
    _accelSubscription = accelerometerEvents.listen((event) {
      if (!_isGamePaused) {
        _targetPaddleY = (playerPaddleY + event.y * _accelerometerSensitivity).clamp(0.0, 350.0);
      }
    });
    // Start game loop
    _startGameLoop();

    // Show the difficulty popup after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDifficultyPopup(
        context,
        _gameSpeedMultiplier - 0.5, // Convert back to 0-1 range
        _aiPaddleSpeed == 2.0 ? "Easy" : _aiPaddleSpeed == 3.0 ? "Medium" : "Hard",
        _pointsToWin,
        _updateGameSettings, // Pass callback function
      ).then((_) {
        _resumeGame(); // Resume the game when popup is closed
      });
    });
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    _accelSubscription?.cancel();
    super.dispose();
  }

  // Handle app lifecycle events
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Pause the game when the app goes into the background
      _pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      // Resume the game when the app comes back to the foreground
      _resumeGame();
    }
  }

  void _startGameLoop() {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (mounted && !_isGamePaused && !_gameOver) {
        _updateGame();
      }
      if (mounted) {
        _startGameLoop();
      }
    });
  }

  void _updateGame() {
    // Smoothly interpolate paddle position towards the target
    setState(() {
      playerPaddleY += (_targetPaddleY - playerPaddleY) * _smoothingFactor;
    });

    // Update ball position with speed multiplier
    setState(() {
      ballX += ballSpeedX * _gameSpeedMultiplier;
      ballY += ballSpeedY * _gameSpeedMultiplier;
    });

    // Ball collision with top and bottom walls
    if (ballY <= 0 || ballY >= 392) {
      setState(() {
        ballSpeedY = -ballSpeedY;
      });
    }

    // Ball collision with player paddle (right side)
    if (ballX >= 330 && ballY >= playerPaddleY && ballY <= playerPaddleY + 50) {
      setState(() {
        ballSpeedX = -ballSpeedX;
      });
    }

    // Ball collision with AI paddle (left side)
    if (ballX <= 20 && ballY >= aiPaddleY && ballY <= aiPaddleY + 50) {
      setState(() {
        ballSpeedX = -ballSpeedX;
      });
    }

    // Ball out of bounds (left side - AI scores)
    if (ballX <= 0) {
      setState(() {
        playerScore++;
        _checkGameOver();
        _resetBall();
      });
    }

    // Ball out of bounds (right side - Player scores)
    if (ballX >= 350) {
      setState(() {
        aiScore++;
        _checkGameOver();
        _resetBall();
      });
    }

    // AI paddle movement (simple tracking of ball) with adjusted speed based on difficulty
    setState(() {
      if (aiPaddleY + 25 < ballY) {
        aiPaddleY += _aiPaddleSpeed;
      } else if (aiPaddleY + 25 > ballY) {
        aiPaddleY -= _aiPaddleSpeed;
      }
      aiPaddleY = aiPaddleY.clamp(0.0, 350.0);
    });
  }

  void _resetBall() {
    setState(() {
      ballX = 175.0; // Reset ball to the center
      ballY = 195.0; // Reset ball to the center
      // Reset ball speed to its initial direction
      ballSpeedX = ballSpeedX.abs() * (ballX <= 0 ? 1 : -1); // Ensure correct direction
      ballSpeedY = ballSpeedY.abs() * (ballY <= 0 ? 1 : -1); // Ensure correct direction
    });
  }

  void _checkGameOver() {
    if (playerScore >= _pointsToWin || aiScore >= _pointsToWin) {
      setState(() {
        _gameOver = true;
        _isGamePaused = true;
      });

      final bool playerWins = playerScore >= _pointsToWin;

      // Show game over dialog with appropriate styling based on winner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF171B2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: playerWins ? const Color(0xFF3A69F3) : const Color(0xFFFF494C),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _restartGame();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white60,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Trophy/Robot icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: playerWins ? const Color(0xFF1C2347) : const Color(0xFF291C1C),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        playerWins ? Icons.emoji_events : LucideIcons.bot,
                        color: playerWins ? Colors.amber : const Color(0xFFFF494C),
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Win/Lose text
                  Text(
                    playerWins ? "YOU WIN!" : "AI WINS!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Final score
                  Text(
                    playerWins
                        ? "Final Score: You ${playerScore} - AI ${aiScore}"
                        : "Final Score: AI ${aiScore} - You ${playerScore}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Message
                  Text(
                    playerWins ? "Congratulations!" : "Better luck next time!",
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Play/Try Again button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: playerWins ? const Color(0xFF3A69F3) : const Color(0xFFFF494C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _restartGame();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            playerWins ? "Play Again" : "Try Again",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _restartGame() {
    setState(() {
      playerScore = 0;
      aiScore = 0;
      _resetBall();
      _gameOver = false;
      _resumeGame();
    });
  }

  void _pauseGame() {
    setState(() {
      _isGamePaused = true;
    });
  }

  void _resumeGame() {
    setState(() {
      _isGamePaused = false;
    });
  }

  // Method to update game settings from difficulty popup
  void _updateGameSettings(double speed, String difficulty, int pointsToWin) {
    setState(() {
      _gameSpeedMultiplier = 0.5 + speed; // Scale from 0.5 to 1.5
      _pointsToWin = pointsToWin;

      // Set AI paddle speed based on difficulty
      switch (difficulty) {
        case "Easy":
          _aiPaddleSpeed = 4.0;
          break;
        case "Medium":
          _aiPaddleSpeed = 6.0;
          break;
        case "Hard":
          _aiPaddleSpeed = 7;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SCOREBOARD
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI: $aiScore',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'First to $_pointsToWin wins',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    'You: $playerScore',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // GAME AREA
            Container(
              width: 350,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1122),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center Line
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CenterLinePainter(),
                    ),
                  ),
                  // AI Paddle (Left)
                  Positioned(
                    left: 12,
                    top: aiPaddleY,
                    child: Container(
                      width: 8,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Player Paddle (Right)
                  Positioned(
                    right: 12,
                    top: playerPaddleY,
                    child: Container(
                      width: 8,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Ball
                  Positioned(
                    left: ballX,
                    top: ballY,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Pause overlay
                  if (_isGamePaused && !_gameOver)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black54,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(LucideIcons.play, size: 48, color: Colors.white),
                          onPressed: _resumeGame,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8.0),

            // DIFFICULTY SETTINGS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.gauge, color: Colors.blueAccent),
                    const SizedBox(width: 8.0),
                    Text(
                      'Difficulty Settings',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.settings, color: Colors.white70),
                      onPressed: () {
                        _pauseGame(); // Pause the game
                        showDifficultyPopup(
                          context,
                          _gameSpeedMultiplier - 0.5, // Convert back to 0-1 range
                          _aiPaddleSpeed == 2.0
                              ? "Easy"
                              : _aiPaddleSpeed == 3.0
                              ? "Medium"
                              : "Hard",
                          _pointsToWin,
                          _updateGameSettings, // Pass callback function
                        ).then((_) {
                          _resumeGame(); // Resume the game when popup is closed
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8.0),

            // INSTRUCTIONS
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Tilt device to move paddle',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CenterLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    double dashHeight = 8, dashSpace = 6, startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

Future<void> showDifficultyPopup(
    BuildContext context,
    double initialGameSpeed,
    String initialDifficulty,
    int initialPointsToWin,
    Function(double, String, int) onSettingsChanged,
    ) {
  double gameSpeed = initialGameSpeed;
  String selectedPaddle = initialDifficulty;
  int pointsToWin = initialPointsToWin;

  return showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF11141B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.gamepad2, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        "Difficulty Settings",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      // Only show close button if not initial popup
                      if (!ModalRoute.of(context)!.isCurrent)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Game Speed", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Slider(
                    value: gameSpeed,
                    min: 0,
                    max: 1,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.white30,
                    onChanged: (value) {
                      setState(() {
                        gameSpeed = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Slow", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text("Fast", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("AI Difficulty", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252A34),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: ["Easy", "Medium", "Hard"].map((option) {
                        bool isSelected = selectedPaddle == option;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedPaddle = option;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.all(2),
                              child: Center(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Points to Win", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252A34),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [5, 10, 15].map((option) {
                        bool isSelected = pointsToWin == option;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                pointsToWin = option;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.all(2),
                              child: Center(
                                child: Text(
                                  option.toString(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      // Apply the settings before closing
                      onSettingsChanged(gameSpeed, selectedPaddle, pointsToWin);
                      Navigator.pop(context);
                    },
                    child: const Text("Apply Settings", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

