import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CardHiddenAnimationPage());
}

class CardHiddenAnimationPage extends StatefulWidget {
  const CardHiddenAnimationPage({super.key});

  @override
  State<CardHiddenAnimationPage> createState() =>
      CardHiddenAnimationPageState();
}

class CardHiddenAnimationPageState extends State<CardHiddenAnimationPage>
    with TickerProviderStateMixin {
  final cardSize = 200.0;

  late final holeSizeTween = Tween<double>(
    begin: 0,
    end: 1.5 * cardSize,
  );
  late final holeAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  double get holeSize => holeSizeTween.evaluate(holeAnimationController);
  late final cardOffsetAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  late final cardOffsetTween = Tween<double>(
    begin: 0,
    end: 2 * cardSize,
  ).chain(CurveTween(curve: Curves.easeInBack));
  late final cardRotationTween = Tween<double>(
    begin: 0,
    end: 0.5,
  ).chain(CurveTween(curve: Curves.easeInBack));
  late final cardElevationTween = Tween<double>(
    begin: 2,
    end: 20,
  );

  double get cardOffset =>
      cardOffsetTween.evaluate(cardOffsetAnimationController);
  double get cardRotation =>
      cardRotationTween.evaluate(cardOffsetAnimationController);
  double get cardElevation =>
      cardElevationTween.evaluate(cardOffsetAnimationController);

  @override
  void initState() {
    _controller = ConfettiController(duration: const Duration(seconds: 4));
    holeAnimationController.addListener(() => setState(() {}));
    cardOffsetAnimationController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    holeAnimationController.dispose();
    cardOffsetAnimationController.dispose();
    super.dispose();
  }

  late ConfettiController _controller; //Confetti controller
  bool _isPressed = false;
  bool _onTap = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //debug red line close
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: cardSize * 1.25,
                width: double.infinity,
                child: ClipPath(
                  clipper: BlackHoleClipper(),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      ConfettiWidget(//Confetti Widget
                        confettiController: _controller,
                        blastDirectionality: BlastDirectionality.explosive,
                        particleDrag: 0.02,
                        emissionFrequency: 0.09,
                        numberOfParticles: 50,
                        gravity: 0.6,
                        colors: const [
                          Color.fromARGB(255, 189, 88, 122),
                          Colors.pink,
                          Color.fromARGB(255, 233, 230, 196),
                          Color.fromARGB(255, 159, 196, 226),
                          Colors.pinkAccent
                        ], // Confetti Colors
                      ),
                      Container(
                        //Hole Container
                        height: 20,
                        width: holeSize,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      Positioned(//Question Card Widget
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(0, cardOffset),
                            child: Transform.rotate(
                              //Container rotate widget
                              angle: cardRotation,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: HelloWorldCard(
                                  size: cardSize,
                                  elevation: cardElevation,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 200,
            ),
            Row(//Yes and No Button Widget
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    _onTap = !_onTap;
                    holeAnimationController.forward();
                    await cardOffsetAnimationController.forward();
                    Future.delayed(const Duration(milliseconds: 200),
                        () => holeAnimationController.reverse());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    width: _onTap ? 150 : 100,
                    height: _onTap ? 80 : 50,
                    decoration: BoxDecoration(
                        color: _onTap
                            ? const Color.fromARGB(255, 162, 193, 218)
                            : const Color.fromARGB(255, 210, 133, 159),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('NO')),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPressed = !_isPressed;
                      _controller.play(); //confetti play function
                      cardOffsetAnimationController.reverse();
                      holeAnimationController.reverse();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    width: _isPressed ? 150 : 100,
                    height: _isPressed ? 80 : 50,
                    decoration: BoxDecoration(
                      color: _isPressed
                          ? const Color.fromARGB(255, 210, 133, 159)
                          : const Color.fromARGB(255, 162, 193, 218),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('YES')),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BlackHoleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.arcTo(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height,
      ),
      0,
      pi,
      true,
    );
    // Using -1000 guarantees the card won't be clipped at the top, regardless of its height
    path.lineTo(0, -1000);
    path.lineTo(size.width, -1000);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(BlackHoleClipper oldClipper) => false;
}

class HelloWorldCard extends StatelessWidget {
  const HelloWorldCard({
    Key? key,
    required this.size,
    required this.elevation,
  }) : super(key: key);

  final double size;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: size,
        child: Image.asset(
          'assets/1.png',
          fit: BoxFit.cover,
        ),
        // child: DecoratedBox(
        //   // decoration: BoxDecoration(
        //   //   borderRadius: BorderRadius.circular(10),
        //   //   color: Colors.blue,
        //   // ),
        //   // child: const Center(
        //   //   child: Text(
        //   //     'Would you like to go out with me',
        //   //     textAlign: TextAlign.center,
        //   //     style: TextStyle(
        //   //         fontWeight: FontWeight.bold,
        //   //         color: Colors.white,
        //   //         fontSize: 14),
        //   //   ),
        //   // ),
        // ),
      ),
    );
  }
}
