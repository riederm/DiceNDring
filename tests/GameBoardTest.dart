part of tests;

bool contains(List<Field> fieldSet, int x, int y){
  return fieldSet.some((Field f) => f.x == x && f.y == y);
}

void fieldSetTests() {
  GameBoard board = new GameBoard(null, new GameElementsFactory(), 4, 4);
  FieldSetSelector selector = new FieldSetSelector(board);
  
  int row = 0;
  group("rows: ", () {
    for(int row=0; row<4; row++){
      for(int i=0; i<4; i++){
        test('row ${row} - (${i},${row})', () => expect(contains(selector.getRow(row), i,row), true));
      }
    }
  });
  
  group("cols: ", () {
    for(int col=0; col<4; col++){
      for(int i=0; i<4; i++){
        test('col ${col} - (${col},${i})', () => expect(contains(selector.getCol(col), col, i), true));
      }
    }
  });
  
  group("diagonals1: ", (){
    List<Field> diagonal1 = selector.getDiagonals()[0];
    test('diagonal: LT-RB 0,0', () => expect(contains(diagonal1, 0,0), true));
    test('diagonal: LT-RB 1,1', () => expect(contains(diagonal1, 1,1), true));
    test('diagonal: LT-RB 2,2', () => expect(contains(diagonal1, 2,2), true));
    test('diagonal: LT-RB 3,3', () => expect(contains(diagonal1, 3,3), true));
  });
 
  group("diagonals2: ", (){
    List<Field> diagonal1 = selector.getDiagonals()[1];
    test('diagonal: RT-LB 3,0', () => expect(contains(diagonal1, 3,0), true));
    test('diagonal: RT-LB 2,1', () => expect(contains(diagonal1, 2,1), true));
    test('diagonal: RT-LB 1,2', () => expect(contains(diagonal1, 1,2), true));
    test('diagonal: RT-LB 0,3', () => expect(contains(diagonal1, 0,3), true));
  });
}