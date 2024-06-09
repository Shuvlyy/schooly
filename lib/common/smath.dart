import 'dart:math';

class SMath {
  static List<double> calculateTrendLine(List<double> x, List<double> y) {
    double xMean = (x.length + 1) / 2;
    double yMean = 0;

    for (double number in y) {
      yMean += number;
    }

    yMean /= y.length;

    List<double> deltaX = List<double>.generate(x.length, (int index) => x[index] - xMean);
    List<double> deltaY = List<double>.generate(y.length, (int index) => y[index] - yMean);

    double xySum = 0;
    double xSquaredSum = 0;

    for (int k = 0; k < x.length; k++) {
      xySum += deltaX[k] * deltaY[k];
      xSquaredSum += pow(deltaX[k], 2);
    }

    double gradesTrendLineCoefficient = xySum / xSquaredSum;
    double yAtX0 = yMean - (gradesTrendLineCoefficient * xMean);

    return [yAtX0, gradesTrendLineCoefficient];
    //        p               m              //
    //---------------------------------------//
    //             y = m * x + p             //
    ///////////////////////////////////////////
  }

  static String formatSignificantFigures(double number) {
    if (number.isNaN) {
      return '-1';
    }

    if (number == number.round()) {
      return number.toStringAsFixed(0);
    }

    String formattedNumber = number.toStringAsFixed(2);
    int length = formattedNumber.length;
    while (length > 1 && formattedNumber[length - 1] == '0') {
      length--;
    }
    if (formattedNumber[length - 1] == '.') {
      length--;
    }
    return formattedNumber.substring(0, length);
  }
}
