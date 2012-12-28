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

  void updateStats(List<Dice> newDices) {
    for(int i=0; i<newDices.length; i++){
      dices[i] == null;
      Dice dice = newDices[i];
      if (dice != null){
        dices[i] = dice;
        colors[dice.color] += 1;
        values[dice.value-1] += 1;
      }
    }
  }
  
  int isThis(int element, int expected){
    if (element == expected){
      return 1;
    }
    return 0;
  }

  num getColorFrequencyOf(int targetColor){
    return colors.reduce(0, (int prev, int element) => prev + isThis(targetColor, element));
  }
  
  num getValueFrequencyOf(int targetValue){
    return values.reduce(0, (int prev, int element) => prev + isThis(targetValue, element));
  }
}

abstract class BoardEvaluation {
  num points;
  bool removesDices;
  BoardEvaluation(num this.points, [this.removesDices = false]);
  
  num evaluate(FieldSetStats stats);
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
    int numberOfTwoColors = stats.getColorFrequencyOf(2);
    int numberOfTwoValues = stats.getValueFrequencyOf(2);
    
    int firstColorIndex = 0;
    if (numberOfTwoColors == 2 && numberOfTwoValues == 2){
      //check if the two's have the same color
      Dice firstDice = stats.dices[0];
      //find the second dice with this color and check if the number matches (the other 2 must match automatically!)
      bool secondDiceFound = stats.dices.some((d) => d != firstDice && d.value == firstDice.value && d.color == firstDice.color);
      
      if (secondDiceFound){
        return points; 
      }
    }
    return 0;
  }
}

class SameValueSameColorEvaluation extends And{
  SameValueSameColorEvaluation(num points, bool removesDices): 
    super(points, removesDices, new SameColorEvaluation(1, false), 
                                new SameValueEvaluation(1, false));
}

class SameColorDifferentValuesEvaluation extends And{
  SameColorDifferentValuesEvaluation(num points, bool removesDices):
    super(points, removesDices, new SameColorEvaluation(1, false), 
                                new DifferentValueEvaluation(1, false));
}

class DifferentColorSameValuesEvaluation extends And{
  DifferentColorSameValuesEvaluation(num points, bool removesDices):
    super(points, removesDices, new DifferentColorEvaluation(1, false), 
                                new SameValueEvaluation(1, false));
}

class DifferentColorDifferentValuesEvaluation extends And{
  DifferentColorDifferentValuesEvaluation(num points, bool removesDices):
      super(points, removesDices, new DifferentColorEvaluation(1, false), 
                                  new DifferentValueEvaluation(1, false));
  
}

class PairColorPairNumberEvaluation extends BoardEvaluation{
  PairColorPairNumberEvaluation(num evalPoints, [bool removesDices = false]): super(evalPoints, removesDices);
  
  num evaluate(FieldSetStats stats){
    num numberOfTwoColors = stats.getColorFrequencyOf(2);
    num numberOfTwoValues = stats.getValueFrequencyOf(2);
    
    if (numberOfTwoColors == 2 && numberOfTwoValues == 2){
      Dice firstDice = stats.dices[0];

      //find the second dice with this color and check if the numbers DON'T matches 
      //(the other two must automatically share the same condition)
      bool secondDiceFound = stats.dices.some((Dice d) => d != firstDice && d.value != firstDice.value && d.color == firstDice.color);
      if (secondDiceFound){
        return points;
      }
    }
    return 0;
  }
}

class PairColorOnlyEvaluation extends BoardEvaluation{
  PairColorOnlyEvaluation(num evalPoints, [bool removesDices = false]) : super(evalPoints, removesDices);
  
  num evaluate(FieldSetStats stats){
    num numberOfTwoColors = stats.getColorFrequencyOf(2);
    
    if (numberOfTwoColors == 2){
      if (stats.getValueFrequencyOf(2) != 2 && //not 1,1,2,2
          stats.getValueFrequencyOf(1) != 4 && //not 1,2,3,4
          stats.getValueFrequencyOf(4) != 1){  //not 1,1,1,1
        return points;
      }
    }
    return 0;
  }
}

class PairValueOnlyEvaluation extends BoardEvaluation{
  PairValueOnlyEvaluation(num evalPoints, [bool removesDices = false]) : super(evalPoints, removesDices);
  
  num evaluate(FieldSetStats stats){
    num numberOfTwoValues = stats.getValueFrequencyOf(2);
    
    if (numberOfTwoValues == 2){
      if (stats.getColorFrequencyOf(2) != 2 && //not R,R,G,G
          stats.getColorFrequencyOf(1) != 4 && //not R,G,B,Y
          stats.getColorFrequencyOf(4) != 1){  //not B,B,B,B
        return points;
      }
    }
    return 0;
  }
}

class Evaluator{
  List<BoardEvaluation> evaluators = new List<BoardEvaluation>();
  FieldSetStats stats = new FieldSetStats();
  
  Evaluator(){
    //
    // same color, same values 
    evaluators.add(new SameValueSameColorEvaluation(400, true));
    // same color, different values
    evaluators.add(new SameColorDifferentValuesEvaluation(200, true));
    // different color, same value
    evaluators.add(new DifferentColorSameValuesEvaluation(200, true));
    // different color, different values
    evaluators.add(new DifferentColorDifferentValuesEvaluation(100, true));

    // Two Pair (e.g. 2x 1blue, 2x3red)
    evaluators.add(new TwoFullPairEvaluation(60));
    //Same color only (e.g. 1,2,4,1 green)
    evaluators.add(new SameColorEvaluation(40, false));
    //Same number only (1g 1r 1g 1b)
    evaluators.add(new SameValueEvaluation(40, false));
    //pair color, pair number (1g1r2g2r)
    evaluators.add(new PairColorPairNumberEvaluation(20, false));
    //each color only (1r2b1y1g)
    evaluators.add(new DifferentColorEvaluation(10, false));
    //each number only (1r2b3y4g)
    evaluators.add(new DifferentValueEvaluation(10, false));
    //pair color only (1r3r4y1y)
    evaluators.add(new PairColorOnlyEvaluation(5, false));
    //pair number only (4g4b1r1r)
    evaluators.add(new PairValueOnlyEvaluation(5, false));
    
    evaluators.sort((BoardEvaluation a, BoardEvaluation b) => a.points.compareTo(b.points));
  }
  
  num getEvaluationFor(List<Dice> dices){
    num points = 0;
    
    FieldSetStats myStats = stats;
    
    stats.updateStats(dices);
    
    for(BoardEvaluation e in evaluators){
      num p = e.evaluate(stats);
      if (p != null && p > 0){
        points += p;
      }
    }
    return points;
  }
  
}