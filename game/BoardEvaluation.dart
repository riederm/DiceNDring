part of game;

class FieldSetStats{
  List<Dice> dices = new List<Dice>(4);
  List<int> colors = [0,0,0,0];
  List<int> values =[0,0,0,0]; 
  
  void clear(){
    for(int i=0; i<4; i++){
      colors[i] = 0;
      values[i] = 0;
      dices[i] = null;
    }
  }
}

abstract class BoardEvaluation {
  num points;
  bool removesDices;
  BoardEvaluation(num this.points, [this.removesDices = false]);
  
  num evaluate(FieldSetStats stats);
  
  int isThis(int element, int expected){
    if (element == expected){
      return 1;
    }
    return 0;
  }

}

class And extends BoardEvaluation{
  BoardEvaluation first;
  BoardEvaluation second;
  
  And(num value, bool removesDices, BoardEvaluation this.first, BoardEvaluation this.second)
      :super(value, removesDices);
  
  num evaluate(FieldSetStats stats){ 
    if (first.evaluate(stats) > 0 && second.evaluate(stats) > 0){    
      return points;
    }
    return 0;
  } 
}

class SameValueEvaluation extends BoardEvaluation{
  SameValueEvaluation(num evalPoints, [bool removesDices = false]): super(evalPoints, removesDices);
  
  num evaluate(FieldSetStats stats){    
    if (stats.values.contains(4)){
      return points;
    }
    return 0;
  } 
}


class SameColorEvaluation extends BoardEvaluation{
  
  SameColorEvaluation(num evalPoints, [bool removesDices = false]): super(evalPoints, removesDices);
  
  num evaluate(FieldSetStats stats){    
    if (stats.colors.contains(4)){
      return points;
    }
    return 0;
  }    
}

class DifferentColorEvaluation extends BoardEvaluation{
  
  DifferentColorEvaluation(num evalPoints, [bool removesDices = false]): super(evalPoints, removesDices);
  
  num evaluate(FieldSetStats stats){    
    if (stats.colors.every((v) => v == 1)){
      return points;
    }
    return 0;
  }    
}

class DifferentValueEvaluation extends BoardEvaluation{
  
  DifferentValueEvaluation(num evalPoints, [bool removesDices = false]): super(evalPoints, removesDices);
  
  num evaluate(FieldSetStats stats){    
    if (stats.values.every((v) => v == 1)){
      return points;
    }
    return 0;
  }
}

class TwoFullPairEvaluation extends BoardEvaluation{
  
  TwoFullPairEvaluation(num evalPoints, [bool removesDices = false]): super(evalPoints, removesDices);
  
  num evaluate(FieldSetStats stats){
    //check if we found 2 different colors
    int numberOfTwoColors = stats.colors.reduce(0, (int prev, int element) => isThis(2, element));
    int numberOfTwoValues = stats.colors.reduce(0, (int prev, int element) => isThis(2, element));
    
    int firstColorIndex = 0;
    if (numberOfTwoColors == 2 && numberOfTwoValues == 2){
      //check if the two's have the same color
      Dice firstDice = stats.dices[0];
      //find the second dice with this color and check if the number matches (the other 2 must match automatically!)
      bool secondDiceFound = stats.dices.some((d) => d != firstDice && d.value == firstDice.value && d.color == firstDice.color);
      
      if (secondDiceFound){
        return points; 
      }
      return 0;
    }
  }
}



class Evaluator{
  List<BoardEvaluation> evaluators = new List<BoardEvaluation>();
  FieldSetStats stats = new FieldSetStats();
  
  Evaluator(){
    // same color, same values 
    evaluators.add(new And(400, true, new SameColorEvaluation(1, false), new SameValueEvaluation(1, false)));
    // same color, different values
    evaluators.add(new And(200, true, new SameColorEvaluation(1, false), new DifferentValueEvaluation(1, false)));
    // different color, same value
    evaluators.add(new And(200, true, new DifferentColorEvaluation(1, false), new SameValueEvaluation(1, false)));
    // different color, different values
    evaluators.add(new And(100, true, new DifferentColorEvaluation(1, false), new DifferentValueEvaluation(1, false)));

    // Two Pair (e.g. 2x 1blue, 2x3red)
    evaluators.add(new TwoFullPairEvaluation(60));
    //Same color only (e.g. 1,2,4,1 green)
    evaluators.add(new SameColorEvaluation(40, false));
    //Same number only (1g 1r 1g 1b)
    evaluators.add(new SameValueEvaluation(40, false));
    //pair color, pair number (1g1r2g2r)
    //evaluators.add(new PairColorPairNumber(20));
    //each color only (1r2b1y1g)
    evaluators.add(new DifferentColorEvaluation(10, false));
    //each number only (1r2b3y4g)
    evaluators.add(new DifferentValueEvaluation(10, false));
    //pair color only (1r3r4y1y)
    //evaluators.add(new TwoColorPair(5, false));
    //pair number only (4g4b1r1r)
    //evaluators.add(new TwoNumberPair(5, false));
    
    evaluators.sort((BoardEvaluation a, BoardEvaluation b) => a.points.compareTo(b.points));
  }
  
  num getEvaluationFor(List<Field> fields){
    num points = 0;
    
    FieldSetStats myStats = stats;
    stats.clear();
    
    for(int i=0; i<fields.length; i++){
      Field f = fields[i];      
      if (!f.isFree()){
        stats.dices[i] = f.dice;
      }else{
        return 0; //empty field! don't analyze
      }
    }
    _updateColorStats(fields);
    _updateValueStats(fields);
    
    for(BoardEvaluation e in evaluators){
      num p = e.evaluate(stats);
      if (p != null && p > 0){
        points += p;
      }
    }
    return points;
  }
  
  void _updateColorStats(List<Field> fields){
    for(Field f in fields){
      if (!f.isFree()){
        stats.colors[f.dice.color] += 1;
      }
    }
  }
  
  void _updateValueStats(List<Field> fields){
    for(Field f in fields){
      if (!f.isFree()){
        stats.values[f.dice.value-1] += 1;
      }
    }
  }
}