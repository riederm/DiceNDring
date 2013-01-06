library tests;

import '../packages/unittest/unittest.dart';
import '../game/game.dart';
import '../geo/Geo.dart';

part 'EvaluationTests.dart';
part 'GameBoardTest.dart';
part 'GameEvaluationTests.dart';



void main(){
  evaluationTests();
  fieldSetTests();
  //testEvaluationResult();
}