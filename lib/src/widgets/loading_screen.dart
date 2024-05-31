import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          color: Colors.blue.shade900.withOpacity(0.3),
          dismissible: false,
        ),
        Center(
          child: SpinKitCubeGrid(
            color: Colors.blue.shade900,
            size: 50.0,
          ),
        ),
      ],
    );
  }
}
