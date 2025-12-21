import 'package:equatable/equatable.dart';

class TimeSignature extends Equatable {
  final int numerator;
  final int denominator;

  const TimeSignature(this.numerator, this.denominator);

  @override
  List<Object?> get props => [numerator, denominator];

  @override
  String toString() => '$numerator/$denominator';

  static const TimeSignature fourFour = TimeSignature(4, 4);
}
