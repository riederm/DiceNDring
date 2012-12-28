part of tests;

List<int> differentColors = [G, G, R, Y];
List<int> differentValues = [1,2,4,4];

  List<Dice> createDices(List<int> colors, List<int> values){
    List<Dice> dices = new List<Dice>(4);
    for(int i=0; i<colors.length; i++){
      dices[i] = createDice(values[i], colors[i]);
    }
    return dices;
  }
  
  Dice createDice(int value, int color){
    Dice dice = new Dice(value, color, null);
    return dice;
  }
  
  num testSameColorEvaluation(List<int> colors){
    BoardEvaluation evaluator = new SameColorEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, differentValues));
    
    return evaluator.evaluate(stats);
  }
  
  num testSameValueEvaluation(List<int> values){
    BoardEvaluation evaluator = new SameValueEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(differentColors, values));
    
    return evaluator.evaluate(stats);
  }
  
  num testDifferentColorEvaluation(List<int> colors){
    BoardEvaluation evaluator = new DifferentColorEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, differentValues));
    
    return evaluator.evaluate(stats);
  }
  
  num testDifferentValuesEvaluation(List<int> values){
    BoardEvaluation evaluator = new DifferentValueEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(differentColors, values));
    
    return evaluator.evaluate(stats);
  }
  
  num testTwoFullpairEvaluation(List<int> values, List<int> colors){
    BoardEvaluation evaluator = new TwoFullPairEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, values));
    
    return evaluator.evaluate(stats);
  }
  
  num testSameValueSameColorEvaluation(List<int> values, List<int> colors){
    BoardEvaluation evaluator = new SameValueSameColorEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, values));
    
    return evaluator.evaluate(stats);
  }
  
  num testSameColorDifferentValuesEvaluation(List<int> values, List<int> colors){
    BoardEvaluation evaluator = new SameColorDifferentValuesEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, values));
    
    return evaluator.evaluate(stats);
  }
  
  num testDifferentColorSameValuesEvaluation(List<int> values, List<int> colors){
    BoardEvaluation evaluator = new DifferentColorSameValuesEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, values));
    
    return evaluator.evaluate(stats);
  }
  
  num testDifferentColorDifferentValuesEvaluation(List<int> values,List<int> colors){
    BoardEvaluation evaluator = new DifferentColorDifferentValuesEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, values));
    
    return evaluator.evaluate(stats);    
  }
  
  num testPairColorPairNumberEvaluation(List<int> values,List<int> colors){
    BoardEvaluation evaluator = new PairColorPairNumberEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, values));
    
    return evaluator.evaluate(stats);    
  }
  
  num testPairColorOnlyEvaluation(List<int> values,List<int> colors){
    BoardEvaluation evaluator = new PairColorOnlyEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, values));
    
    return evaluator.evaluate(stats);    
  }
  
  num testPairValueOnlyEvaluation(List<int> values, List<int> colors){
    BoardEvaluation evaluator = new PairValueOnlyEvaluation(10, false);
    FieldSetStats stats = new FieldSetStats();
    stats.updateStats(createDices(colors, values));
    
    return evaluator.evaluate(stats);    
  }
  
  
  
int R = Dice.RED;
int G = Dice.GREEN;
int B = Dice.BLUE;
int Y = Dice.YELLOW; 
  
void evaluationTests() {
  group("SameColorEvaluation: ", () {
    test('with BBBB', () => expect(testSameColorEvaluation([B, B, B, B]), greaterThan(0)));
    test('with RRRR', () => expect(testSameColorEvaluation([R, R, R, R]), greaterThan(0)));
    test('with GGGG', () => expect(testSameColorEvaluation([G, G, G, G]), greaterThan(0)));
    test('with YYYY', () => expect(testSameColorEvaluation([Y, Y, Y, Y]), greaterThan(0)));
    test('with different Color dices', () =>  expect(testSameColorEvaluation([B, G, Y, R]), isZero));
  });
  
  group("SameValueEvaluation: ", () {
    test('with 1111', () => expect(testSameValueEvaluation([1, 1, 1, 1]), greaterThan(0)));
    test('with 2222', () => expect(testSameValueEvaluation([2, 2, 2, 2]), greaterThan(0)));
    test('with 3333', () => expect(testSameValueEvaluation([3, 3, 3, 3]), greaterThan(0)));
    test('with 4444', () => expect(testSameValueEvaluation([4, 4, 4, 4]), greaterThan(0)));
    test('with 1234', () => expect(testSameValueEvaluation([1, 2, 3, 4]), isZero));
    test('with 1114', () => expect(testSameValueEvaluation([1, 1, 1, 4]), isZero));
  });
  
  group("DifferentColorEvaluation: ", () {
    test('with RGBY', () => expect(testDifferentColorEvaluation([R, G, B, Y]), greaterThan(0)));
    test('with YBGR', () => expect(testDifferentColorEvaluation([Y, B, G, R]), greaterThan(0)));
    test('with RRGY', () => expect(testDifferentColorEvaluation([R, R, G, Y]), isZero));
    test('with YYYY', () => expect(testDifferentColorEvaluation([Y, Y, Y, Y]), isZero));
  });
  
  group("DifferentValueEvaluation: ", () {
    test('with 1234', () => expect(testDifferentValuesEvaluation([1,2,3,4]), greaterThan(0)));
    test('with 4321', () => expect(testDifferentValuesEvaluation([4,3,2,1]), greaterThan(0)));
    test('with 1134', () => expect(testDifferentValuesEvaluation([1,1,3,4]), isZero));
    test('with 3333', () => expect(testDifferentValuesEvaluation([3,3,3,3]), isZero));
  });
  
  group("TwoFullpairEvaluation: ", () {
    test('with 2B 2B 4R 4R', () => expect(testTwoFullpairEvaluation([2,2,4,4], [B, B, R, R]), greaterThan(0)));
    test('with 1G 3Y 1G 3Y', () => expect(testTwoFullpairEvaluation([1,3,1,3], [G, Y, G, Y]), greaterThan(0)));
    test('with 2B 2B 4R 3R', () => expect(testTwoFullpairEvaluation([2,2,4,3], [B, B, R, R]), isZero));
    test('with 2B 2B 4R 4B', () => expect(testTwoFullpairEvaluation([2,2,4,4], [B, B, R, B]), isZero));
    test('with 1B 2B 3R 4R', () => expect(testTwoFullpairEvaluation([1,2,3,4], [B, B, R, R]), isZero));
  });
  
  group("SameValueSameColorEvaluation: ", () {
    test('with 1Y1Y1Y1Y', () => expect(testSameValueSameColorEvaluation([1,1,1,1], [Y,Y,Y,Y]), greaterThan(0)));
    test('with 2G2G2G2G', () => expect(testSameValueSameColorEvaluation([2,2,2,2], [G,G,G,G]), greaterThan(0)));
    test('with 3R3R3R3R', () => expect(testSameValueSameColorEvaluation([3,3,3,3], [R,R,R,R]), greaterThan(0)));
    test('with 4B4B4B4B', () => expect(testSameValueSameColorEvaluation([4,4,4,4], [B,B,B,B]), greaterThan(0)));
    test('with 1R1R1R2R', () => expect(testSameValueSameColorEvaluation([1,1,1,2], [R,R,R,R]), isZero));
    test('with 1G1R1R1R', () => expect(testSameValueSameColorEvaluation([1,1,1,1], [G,R,R,R]), isZero));
  });
  
  group("SameColorDifferentValuesEvaluation: ", () {
    test('with 1R2R3R4R', () => expect(testSameColorDifferentValuesEvaluation([1,2,3,4],[R,R,R,R]), greaterThan(0)));
    test('with 1Y2Y3Y4Y', () => expect(testSameColorDifferentValuesEvaluation([1,2,3,4],[Y,Y,Y,Y]), greaterThan(0)));
    test('with 1R2R3R1R', () => expect(testSameColorDifferentValuesEvaluation([1,2,3,1],[R,R,R,R]), isZero));
    test('with 1G2G3G4Y', () => expect(testSameColorDifferentValuesEvaluation([1,2,3,4],[G,G,G,Y]), isZero));
  });
  
  group("DifferentColorSameValuesEvaluation: ", () {
    test('with 1R1G1B1Y', () => expect(testDifferentColorSameValuesEvaluation([1,1,1,1],[R,G,B,Y]), greaterThan(0)));
    test('with 4G4R4Y4B', () => expect(testDifferentColorSameValuesEvaluation([4,4,4,4],[G,R,Y,B]), greaterThan(0)));
    test('with 1R1G2B1Y', () => expect(testDifferentColorSameValuesEvaluation([1,1,2,1],[R,G,B,Y]), isZero));
    test('with 1R1G1Y1Y', () => expect(testDifferentColorSameValuesEvaluation([1,1,1,1],[R,G,Y,Y]), isZero));
  });
  
  group("DifferentColorDifferentValuesEvaluation: ", (){
    test('with 1R2G3B4Y', () => expect(testDifferentColorDifferentValuesEvaluation([1,2,3,4],[R,G,B,Y]), greaterThan(0)));
    test('with 4R3G2B1Y', () => expect(testDifferentColorDifferentValuesEvaluation([4,3,2,1],[R,G,B,Y]), greaterThan(0)));
    test('with 1Y3R2G4B', () => expect(testDifferentColorDifferentValuesEvaluation([1,2,3,4],[Y,R,G,B]), greaterThan(0)));
    test('with 1R2R3B4Y', () => expect(testDifferentColorDifferentValuesEvaluation([1,2,3,4],[R,R,B,Y]), isZero));
    test('with 3R3G2B1Y', () => expect(testDifferentColorDifferentValuesEvaluation([3,3,2,1],[R,G,B,Y]), isZero));
    test('with 2Y2R2G2B', () => expect(testDifferentColorDifferentValuesEvaluation([2,2,2,2],[Y,R,G,B]), isZero));
  });
  
  group("PairColorPairNumberEvaluation: ", (){
    test('with [1G][2G][1R][2R]', () => expect(testPairColorPairNumberEvaluation([1,2,1,2],[G,G,R,R]), greaterThan(0)));
    test('with [4Y][2B][2Y][4B]', () => expect(testPairColorPairNumberEvaluation([4,2,2,4],[Y,B,Y,B]), greaterThan(0)));
    test('with [4Y][4B][2Y][4B]', () => expect(testPairColorPairNumberEvaluation([4,4,2,4],[Y,B,Y,B]), isZero));
    test('with [2Y][4B][2G][4B]', () => expect(testPairColorPairNumberEvaluation([2,4,2,4],[Y,B,G,B]), isZero));
  });
  
  group("PairColorOnlyEvaluation: ", (){
    test('with [1R][2R][1G][3G]', () => expect(testPairColorOnlyEvaluation([1,2,1,3],[R,R,G,G]), greaterThan(0)));
    test('with [1R][1R][1G][3G]', () => expect(testPairColorOnlyEvaluation([1,1,1,3],[R,R,G,G]), greaterThan(0)));
    test('with [1Y][1R][1Y][3R]', () => expect(testPairColorOnlyEvaluation([1,1,1,3],[R,R,G,G]), greaterThan(0)));
    test('with [1Y][2Y][4G][3G]', () => expect(testPairColorOnlyEvaluation([1,2,4,3],[Y,Y,G,G]), isZero));
    test('with [3B][2B][2Y][3Y]', () => expect(testPairColorOnlyEvaluation([3,2,2,3],[B,B,Y,Y]), isZero));
    
    test('with [1R][2R][1G][3G]', () => expect(testPairColorOnlyEvaluation([1,2,1,3],[R,R,R,G]), isZero));
    test('with [1R][1R][1G][3G]', () => expect(testPairColorOnlyEvaluation([1,1,1,3],[R,R,Y,G]), isZero));
    test('with [1Y][1R][1Y][3R]', () => expect(testPairColorOnlyEvaluation([1,1,1,3],[R,R,R,R]), isZero));
  });
  
  group("PairValueOnlyEvaluation: ", (){
    test('with [1R][2R][1Y][2G]', () => expect(testPairValueOnlyEvaluation([1,2,1,2],[R,R,Y,G]), greaterThan(0)));
    test('with [3R][3B][1B][1G]', () => expect(testPairValueOnlyEvaluation([3,3,1,1],[R,B,B,G]), greaterThan(0)));
    test('with [4R][2R][2R][4B]', () => expect(testPairValueOnlyEvaluation([4,2,2,4],[R,R,R,B]), greaterThan(0)));
    test('with [1Y][2Y][4G][3G]', () => expect(testPairValueOnlyEvaluation([1,2,4,3],[Y,Y,G,G]), isZero));
    test('with [3B][2B][2Y][3Y]', () => expect(testPairValueOnlyEvaluation([3,2,2,3],[B,B,Y,Y]), isZero));
    test('with [1R][2R][1G][3G]', () => expect(testPairValueOnlyEvaluation([1,2,1,3],[R,R,G,G]), isZero));
    test('with [1R][1R][1G][3G]', () => expect(testPairValueOnlyEvaluation([1,1,1,3],[R,R,G,G]), isZero));
    test('with [1Y][1R][1Y][1R]', () => expect(testPairValueOnlyEvaluation([1,1,1,1],[Y,R,Y,R]), isZero));
  });
}
