import 'package:flutter/material.dart';
import 'package:custom_tooltip/custom_tooltip.dart';

void main() {
  runApp(const MyApp());
}

const tooltipBackgroundColor = Color(0xff333333);
const tooltipContentTextColor = Colors.white;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Tooltip Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Animated Tooltip Demo'),
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomTooltip(
                      backgroundColor: tooltipBackgroundColor,
                      content: Text(
                        'This is an inverted tooltip. awewefjwaoeifjewiafuhjweifewuhafweoiaufhweaifuhvoiahuveaiovuhavpijapvijwavwopaijvwapovijawopvij',
                        style: TextStyle(color: tooltipContentTextColor),
                      ),
                      child: Icon(Icons.info),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: CustomTooltip(
                        backgroundColor: tooltipBackgroundColor,
                        content: Text(
                          'Please enter alphanumeric characters (A-Z, 0-9)',
                          style: TextStyle(color: tooltipContentTextColor),
                        ),
                        child: Icon(Icons.info),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomTooltip(
                      backgroundColor: tooltipBackgroundColor,
                      content: Text(
                        'This is a right-aligned tooltip. awewefjwaoeifjewiafuhjweifewuhafweoiaufhweaifuhvoiahuveaiovuhavpijapvijwavwopaijvwapovijawopvij',
                        style: TextStyle(color: tooltipContentTextColor),
                      ),
                      child: Icon(Icons.info),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
