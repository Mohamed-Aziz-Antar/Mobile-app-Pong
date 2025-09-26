import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

void showDifficultyPopup(BuildContext context) {
  double gameSpeed = 0.5;
  String selectedPaddle = "Medium";

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF11141B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Container(
              width: 320, // Slightly increased width
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Close Button
                  Row(
                    children: [
                      const Icon(LucideIcons.gamepad2, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        "Difficulty Settings",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Game Speed Section
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

                  // Paddle Size Section
                  const Text("Paddle Size", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),

                  // Three Buttons for Paddle Size Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPaddle == "Small" ? Colors.blue : Colors.grey[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedPaddle = "Small";
                          });
                        },
                        child: const Text("Small", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPaddle == "Medium" ? Colors.blue : Colors.grey[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedPaddle = "Medium";
                          });
                        },
                        child: const Text("Medim", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPaddle == "Large" ? Colors.blue : Colors.grey[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedPaddle = "Large";
                          });
                        },
                        child: const Text("Large", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Apply Settings Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () => Navigator.pop(context),
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
