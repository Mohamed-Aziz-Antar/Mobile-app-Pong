import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pong/pages/menu.dart';

import 'databaseHandler.dart';


class AvatarSelectionApp extends StatelessWidget {
  final String email;

  const AvatarSelectionApp({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AvatarSelectionPage(email: email),
    );
  }
}

class AvatarSelectionPage extends StatefulWidget {
  final String email;

  const AvatarSelectionPage({Key? key, required this.email}) : super(key: key);

  @override
  _AvatarSelectionPageState createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  final Color backgroundColor = Color(0xFF24283B);
  final Color accentColor = Color(0xFF6C63FF);
  final Color borderColor = Colors.blueAccent;

  String selectedCategory = 'Default';
  String selectedAvatar = 'assetes/images/avatar1.png';
  File? _pickedAvatar;
  bool _isSaving = false;

  Map<String, List<String>> categoryAvatars = {
    'Default': [
      'assetes/images/def1.png',
      'assetes/images/def2.png',
      'assetes/images/def3.png',
      'assetes/images/def4.png',
      'assetes/images/def5.png',
      'assetes/images/def6.png',
    ],
    'Animals': [
      'assetes/images/animal1.png',
      'assetes/images/animal2.png',
      'assetes/images/animal3.png',
      'assetes/images/animal4.png',
      'assetes/images/animal5.png',
      'assetes/images/animal6.png',
    ],
    'Monsters': [
      'assetes/images/avatar1.png',
      'assetes/images/avatar2.png',
      'assetes/images/avatar3.png',
      'assetes/images/avatar4.png',
      'assetes/images/avatar5.png',
      'assetes/images/avatar6.png',
    ],
    'Heroes': [
      'assetes/images/hero1.png',
      'assetes/images/hero2.png',
      'assetes/images/hero3.png',
      'assetes/images/hero4.png',
      'assetes/images/hero5.png',
      'assetes/images/hero6.png',
    ],
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatarImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedAvatar = File(pickedFile.path);
        selectedAvatar = _pickedAvatar!.path;
      });
    }
  }

  Future<void> _saveAndNavigate() async {
    setState(() => _isSaving = true);

    try {
      Uint8List? avatarBytes;

      if (_pickedAvatar != null) {
        // Read bytes from picked file
        avatarBytes = await _pickedAvatar!.readAsBytes();
      } else {
        // Load bytes from asset
        final byteData = await rootBundle.load(selectedAvatar);
        avatarBytes = byteData.buffer.asUint8List();
      }

      await DatabaseHelper().updateUserAvatar(widget.email, avatarBytes!);

      Fluttertoast.showToast(
        msg: "Avatar saved successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        textColor: Colors.white,
        fontSize: 14.0,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PongScreen(email: widget.email)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving avatar: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Rest of your build methods remain unchanged
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: Icon(Icons.arrow_back, color: Colors.white),
        centerTitle: true,
        title: Text(
          'Choose Your Avatar',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: _isSaving ? null : _saveAndNavigate,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _pickedAvatar == null
                        ? AssetImage(selectedAvatar)
                        : FileImage(_pickedAvatar!) as ImageProvider,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap on avatar to preview',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton('Default'),
                _buildCategoryButton('Animals'),
                _buildCategoryButton('Monsters'),
                _buildCategoryButton('Heroes'),
              ],
            ),
            SizedBox(height: 4),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: categoryAvatars[selectedCategory]!
                    .map((avatar) => _buildAvatarItem(avatar))
                    .toList(),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionButton(Icons.image, 'Background', _pickAvatarImage),
                _buildOptionButton(Icons.crop_square, 'Frame', () {}),
                _buildOptionButton(Icons.style, 'Style', () {}),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: _isSaving ? null : _saveAndNavigate,
              child: _isSaving
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                'Confirm Selection',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rest of your UI building methods remain exactly the same
  Widget _buildCategoryButton(String label) {
    bool isSelected = label == selectedCategory;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
          selectedAvatar = categoryAvatars[label]![0];
          _pickedAvatar = null;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarItem(String avatarPath) {
    bool isSelected = avatarPath == selectedAvatar && _pickedAvatar == null;
    return GestureDetector(
      onTap: () {
        setState(() {
          _pickedAvatar = null;
          selectedAvatar = avatarPath;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: accentColor, width: 2) : null,
        ),
        child: CircleAvatar(
          backgroundImage: AssetImage(avatarPath),
          radius: 30,
        ),
      ),
    );
  }

  Widget _buildOptionButton(IconData icon, String label, Function onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 30),
          onPressed: () => onPressed(),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}