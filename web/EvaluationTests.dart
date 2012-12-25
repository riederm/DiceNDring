import '../packages/unittest/unittest.dart';
import 'dart:html';
import 'DiceNDring.dart';
  /**
   *  SameColorEvaluation
      DifferentColorEvaluation
      DifferentValueEvaluation
      TwoFullPair
*/
  
  Field createField(int value, int color){
    Field f = new Field(null);
    f.dice = new Dice(null, value, color);
    return f;
  }
  
  void testSameColor(){
    Evaluator evaluator = new Evaluator();
    List<Field> fields = [  createField(0,1),
                            createField(0,1),
                            createField(0,1),
                            createField(0,1)
                          ];
    
    expect(evaluator.getEvaluationFor(fields), greaterThan(0));
  }
  


void main() {
  test('SameColor with same Color dices', () => testSameColor());
}
