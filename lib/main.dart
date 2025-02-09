import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'dart:js' as js;

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Flutter Demo', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _imageUrl = '';
  final TextEditingController _urlController = TextEditingController();
  bool _isMenuOpen = false;

  void _updateImageUrl() {
    setState(() {
      _imageUrl = _urlController.text;
    });
  }

  void _toggleFullscreen() {
    js.context.callMethod('eval', ["""
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
      } else {
        document.exitFullscreen();
      }
    """]);
  }

  void _enterFullscreen() {
    js.context.callMethod('eval', ["document.documentElement.requestFullscreen();"]);
    _closeMenu();
  }

  void _exitFullscreen() {
    js.context.callMethod('eval', ["document.exitFullscreen();"]);
    _closeMenu();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onDoubleTap: _toggleFullscreen,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _imageUrl.isEmpty
                            ? const Center(
                                child: Text(
                                  'Enter a URL to load an image',
                                  style: TextStyle(color: Colors.purple),
                                ),
                              )
                            : HtmlWidget(
                                '<center><img src="$_imageUrl" alt="Loaded Image" style="border-radius: 12px;"/></center>',
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(hintText: 'Image URL'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _updateImageUrl,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),

          // Dimming background when menu is open
          if (_isMenuOpen)
            GestureDetector(
              onTap: _closeMenu,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // Context Menu
          Positioned(
            right: 16,
            bottom: 80,
            child: Visibility(
              visible: _isMenuOpen,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _enterFullscreen,
                      icon: const Icon(Icons.fullscreen, color: Colors.black),
                      label: const Text("Enter Fullscreen", style: TextStyle(color: Colors.black)),
                    ),
                    const Divider(height: 1),
                    TextButton.icon(
                      onPressed: _exitFullscreen,
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.black),
                      label: const Text("Exit Fullscreen", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
