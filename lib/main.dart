import 'package:flutter/material.dart';

/**
 * Entry point
 */
void main() {
  runApp(MyApp());
}

/**
 * Main app class
 */
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foldable Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Foldable Demo Home Page'),
    );
  }
}

/**
 * Main page
 */
class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/**
 * Main page state
 */
class _MyHomePageState extends State<MyHomePage> {
  static const int ANIM_DURATION_IN_SECS = 2;
  static const double ANIM_FOLD_ANGLE = 3.141592;

  static const int NO_FOLDING = 0;
  static const int FOLDING_HORIZONTAL = 1;
  static const int FOLDING_VERTICAL = 2;

  Tween<double> _tweenRotaX;
  Tween<double> _tweenRotaY;
  int _numFolds = 0;

  @override
  void initState() {
    this._initAnim();

    super.initState();
  }

  void _initAnim() {
    //XXX: always better NOT to store tweens on props, so we do not hold to their refs and avoid using them when not allowed
    this._tweenRotaX = Tween<double>(begin: 0.0, end: ANIM_FOLD_ANGLE);
    this._tweenRotaY = Tween<double>(begin: 0.0, end: ANIM_FOLD_ANGLE);
  }

  void _stopMotion() {
    this._updateFolds(NO_FOLDING);
  }

  void _startMotion() {
    this._updateFolds(FOLDING_HORIZONTAL);
  }

  void _updateFolds(int folds) {
    this.setState(() {
      this._numFolds = folds;
    });
  }

  Matrix4 _getTransformForHorizontalRotation(double value) {
    print("Current tween value on X: $value");

    // RUNNING! so apply transformation
    if (this._isFoldingOnX()) {
      return Matrix4.identity()..rotateX(value);

      // IDLE! so no transform at all
    } else {
      return Matrix4.identity();
    }
  }

  Matrix4 _getTransformForVerticalRotation(double value) {
    print("Current tween value on Y: $value");

    if (this._isFoldingOnY()) {
      return Matrix4.identity()
        ..setEntry(3, 2,
            0.03) //XXX: this one tilts the axis so we get a sort of side perspective
        ..rotateY(value);
    } else {
      return Matrix4.identity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(child: this._buildFoldableContainer()),
          Padding(
            padding: const EdgeInsets.all(_Dimens.MID_SPACING),
            child: RaisedButton(
              onPressed: this._stopMotion,
              child: Text("Reset transformation"),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: this._startMotion,
        child: Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildFoldableContainer() {
    return this._buildFoldableContent();
  }

  Widget _buildFoldableContent() {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          this._buildUpperFoldableContent(),
          Visibility(
              visible: this._numFolds <=
                  FOLDING_HORIZONTAL, //XXX: hide part lower once it is completely folded over X
              child: this._buildLowerFoldableContent()),
        ]);
  }

  Widget _buildUpperFoldableContent() {
    //XXX: still folding over X (or idle too, since we check folds <= 1...)
    if (this._isFoldingOnX()) {
      return this._buildPartialContainer(Colors.red, Alignment.topCenter,
          wFactor: 1.0);

      //XXX: done on X, folding over Y...
    } else {
      return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LEFT
            this._buildPartialContainer(Colors.red, Alignment.topLeft),

            // RIGHT
            TweenAnimationBuilder(
                duration: Duration(seconds: ANIM_DURATION_IN_SECS),
                tween: this._tweenRotaY,
                builder: (cntxt, value, child) {
                  return Transform(
                      transform: this._getTransformForVerticalRotation(value),
                      child: this._buildPartialContainer(
                          Colors.red, Alignment.topRight));
                })
          ]);
    }
  }

  Widget _buildLowerFoldableContent() {
    //XXX: no operation
    if (this._isIdle()) {
      return this._buildPartialContainer(Colors.red, Alignment.bottomCenter,
          wFactor: 1.0);

      //XXX: folding over X...
    } else {
      return TweenAnimationBuilder(
        onEnd: () {
          this._updateFolds(FOLDING_VERTICAL);
        },
        tween: this._tweenRotaX,
        duration: Duration(seconds: ANIM_DURATION_IN_SECS),
        builder: (cntxt, value, child) {
          return Transform(
            transform: this._getTransformForHorizontalRotation(value),
            child: this._buildPartialContainer(
                Colors.red, Alignment.bottomCenter,
                wFactor: 1.0),
          );
        },
      );
    }
  }

  Widget _buildPartialContainer(Color color, Alignment alignment,
      {double wFactor = 0.5, double hFactor = 0.5}) {
    return Container(
      color: color,
      child: ClipRect(
        child: Align(
          alignment: alignment,
          heightFactor: hFactor,
          widthFactor: wFactor,
          child: this._buildMoreContent(),
        ),
      ),
    );
  }

  Widget _buildMoreContent() => Image.network(
        "https://flutter.dev/assets/dash/Dash-ac778c1736b6859410c8989c8d8e010d90b844b5df10f73b6d97fa1b7f0563f7.png",
        width: 300,
        fit: BoxFit.fill,
      );

  Widget _buildSomeContent() {
    return Text('A', style: Theme.of(context).textTheme.headline1);
  }

  bool _isIdle() => this._numFolds == NO_FOLDING;

  bool _isFoldingOnX() => this._numFolds <= FOLDING_HORIZONTAL;

  bool _isFoldingOnY() => this._numFolds >= FOLDING_VERTICAL;
}

abstract class _Dimens {
  static const MID_SPACING = 16.0;
}
