part of tests;

void fillRow(GameBoard board, GameElementsFactory factory, int row){
  int y = row;
  for(int x=0; x<4; x++){
    board.getField(x, y).setDice(factory.createRandomDice());
  }
}

bool testContainsDice(List<Dice> dices, int x, int y){
  test('result doesnt contain ${x},${y}', () => expect(dices.some((Dice d) => d.field.x == x && d.field.y == y), true));
}

void testEvaluationResult(){
  evaluateFirstAndThierdRows();
}

void evaluateFirstAndThierdRows() {
  GameElementsFactory factory = new GameElementsFactory();
  GameBoard board = new GameBoard(new Rectangle(new Point2D(0,0), 0,0), factory);
  fillRow(board, factory, 0);
  fillRow(board, factory, 2);
  
  Game game = new Game(new GameBoard(null, factory), board, factory);
  
  //check against the dicess    
  List<EvaluationResult> results = game.evaluateAll();
  
  test('too much EvaluationResults', () => expect(results.length, 2));
  
  List<Dice> dices = results[0].dices;
  
  testContainsDice(dices,0,0);
  testContainsDice(dices,1,0);
  testContainsDice(dices,2,0);
  testContainsDice(dices,3,0);
  
  dices = results[1].dices;
  
  testContainsDice(dices,0,2);
  testContainsDice(dices,1,2);
  testContainsDice(dices,2,2);
  testContainsDice(dices,3,2);
  
  
}