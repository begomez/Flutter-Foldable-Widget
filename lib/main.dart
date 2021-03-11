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
  int _folds = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    this._initAnim();

    super.initState();
  }

  void _initAnim() {
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
      this._folds = folds;
    });
  }

  Matrix4 _getMatrixForHorizontalRotation(double value) {
    print("Current tween value on X: $value");

    // RUNNING! so apply transformation
    if (this._folds >= FOLDING_HORIZONTAL) {
      return Matrix4.identity()
        ..setEntry(3, 2, 0.03) //XXX: this one tilts the axis so we get a sort of side perspective
        ..rotateX(value);

      // IDLE! so no transform at all
    } else {
      return Matrix4.identity();
    }
  }

  Matrix4 _getMatrixForVerticalRotation(double value) {
    print("Current tween value on Y: $value");

    if (this._folds >= FOLDING_VERTICAL) {
      return Matrix4.identity()
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
          this._buildFoldableContainer(),
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

  Widget _buildSomeContent() {
    return Text('A', style: Theme.of(context).textTheme.headline1);
  }

  Widget _buildFoldableContainer() {
    return this._buildDynamicContainer();
  }

  Widget _buildUpperDynamicContainer() {
    if (this._folds <= 1) {
      return this._buildPartialContainer(Colors.red, Alignment.topCenter, wFactor: 1.0);

    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(flex: 1,child: this._buildPartialContainer(Colors.red, Alignment.topCenter)),
          //Flexible(flex: 1, child: this._buildPartialContainer(Colors.green, Alignment.topRight)),
        ],
      );
    }
  }

  Widget _buildLowerDynamicContainer() {
    if (this._folds == 0) {
      return this._buildPartialContainer(Colors.yellow, Alignment.bottomCenter, wFactor: 1.0);

    } else {
      return TweenAnimationBuilder(
        tween: this._tweenRotaX,
        duration: Duration(seconds: ANIM_DURATION_IN_SECS),
        builder: (cntxt, value, child) {
          return Transform(
            transform: this._getMatrixForHorizontalRotation(value),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(flex: 1,child: this._buildPartialContainer(Colors.blue, Alignment.bottomCenter)),
                //Flexible(flex: 1, child: this._buildPartialContainer(Colors.yellow, Alignment.bottomRight))
              ]),
          ); 
          },
      );
    }
  }

  Widget _buildDynamicContainer() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          this._buildUpperDynamicContainer(),

          this._buildLowerDynamicContainer(),
        ]
    );
  }

  Widget _buildPartialContainer(Color color, Alignment alignment, {double wFactor = 0.5, double hFactor = 0.5}) {
    return Container(
      width: double.maxFinite,
      color: color,
      child: ClipRect(
        child: Align(
          alignment: alignment,
          heightFactor: hFactor,
          widthFactor: wFactor,
          child: this._buildSomeContent(),
        ),
      ),
    );
  }

  Widget _buildStaticContainer() {
    return Container(
        width: double.maxFinite,
        alignment: Alignment.topCenter,
        color: Colors.blue,
        child: this._buildSomeContent());
  }
}

abstract class _Dimens {
  static const MID_SPACING = 16.0;
}
