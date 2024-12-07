import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class NetworkGauge extends StatelessWidget {
  final double downloadValue;
  final double uploadValue;
  final Color downloadColor;
  final Color uploadColor;
  final Color backgroundColor;

  const NetworkGauge({
    required this.downloadValue,
    required this.uploadValue,
    required this.downloadColor,
    required this.uploadColor,
    required this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Increased size for better layout
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            startAngle: 130,
            endAngle: 50,
            minimum: 0,
            maximum: 100, // Adjust maximum based on your speed range
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 0.15,
              cornerStyle: CornerStyle.bothCurve,
              color: backgroundColor,
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: downloadValue,
                cornerStyle: CornerStyle.bothCurve,
                width: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
                color: downloadColor,
              ),
              /*RangePointer(
                value: uploadValue,
                cornerStyle: CornerStyle.bothCurve,
                width: 0.15, // Slightly thinner for contrast
                sizeUnit: GaugeSizeUnit.factor,
                color: uploadColor,
              ),*/
            ],
            annotations: const <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 2), 
                    // const Text(
                    //   'Download',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                    // Text(
                    //   '${downloadValue.toStringAsFixed(2)} Mbps',
                    //   style: const TextStyle(
                    //     fontSize: 28,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.black,
                    //   ),
                    // ),
                    SizedBox(height: 20), // Add spacing
                    // const Text(
                    //   'Upload',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                    // Text(
                    //   '${uploadValue.toStringAsFixed(2)} Mbps',
                    //   style: const TextStyle(
                    //     fontSize: 24,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.black,
                    //   ),
                    // ),
                  ],
                ),
                angle: 90,
                positionFactor: 0.1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
