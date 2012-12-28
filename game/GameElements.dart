part of game;

abstract class BoxedElement{
  Rectangle box;
  
  BoxedElement(Rectangle this.box);
  
}

class Dice extends BoxedElement{
  static final num MARGIN = 3;
  static final num DICE_WIDTH = Field.FIELD_WIDTH*0.8;

  
  static final int RED = 0;
  static final int BLUE = 1;
  static final int GREEN = 2;
  static final int YELLOW = 3;
  
  int value = 1;
  int color = RED;
  bool isDragged = false;
  Field field = null;
  
  Dice(int this.value, int this.color, Rectangle box): super(box);
  
  String getColor(){
    switch(color){
      case 0:
        return "#CC3300";       
      case 1:
        return "#0066FF";
      case 2: 
        return "#339900"; 
      case 3: 
      default:
        return "#FFCC33";        
    }
  }
}

class Field extends BoxedElement{

  static final num FIELD_HEIGHT = 70;
  static final num FIELD_WIDTH = FIELD_HEIGHT;
  
  static final defaultBackground = "white"; //"#99CCFF";
  static final selectedBackground = "#ffcccc";
  
  Field(Rectangle box): super(box);
  
  bool _selected = false;
  bool _diceLocked = false;
  Dice dice;
  
  String getColor(){
    if (_diceLocked){
      if (_selected){
        //locked and selected
        return selectedBackground;
      }else{
        //locked and not selected
        return "gray"; 
      }
    }else{
      if (_selected){
        //notLocked, selected
        return selectedBackground;
      }else{
        //notLocked, notSelected
        return "white";
      }
    }
  }
    
  void setSelected(bool s){
    _selected = s;
  }
  
  void setDice(Dice newDice){
    Rectangle diceBox = newDice.box;
    Rectangle fieldBox = box;
    diceBox.centerAbsoluteOver(fieldBox);
    dice = newDice;
    newDice.field = this;
  }
  
  void clearDice(){
    dice = null;
    _diceLocked = false;
  }
  
  void lockCurrentDice(){
    if (!isFree()){
      _diceLocked = true;
    }
  }
  
  bool isLocked(){
    return _diceLocked;
  }
  
  bool isFree(){
    return dice == null;
  }
}

class GameBoard extends BoxedElement{
  int _horizontalFields;
  int _verticalFields;
  List<Field> fields = new List<Field>();
  static final int MARGIN = 8;

  
  GameBoard(Rectangle box, GameElementsFactory factory, [int this._horizontalFields = 4, int this._verticalFields = 4]): super(box){
    for(num y=0; y<_verticalFields; y++){
      for(num x=0; x<_horizontalFields; x++){
        Point2D pos = new Point2D(x*(Field.FIELD_WIDTH+MARGIN), y*(Field.FIELD_HEIGHT+MARGIN));
        Rectangle rect = new Rectangle(pos, Field.FIELD_WIDTH, Field.FIELD_HEIGHT);
        Field field = factory.createField(rect);
        fields.add(field);
        //addDrawable(field);
        field.box.parentRectangle = this.box;
      }
    }
  }
  
  Field getField(int x, int y){
    return fields[y*_horizontalFields + x];
  }
  
  bool isEmpty() {
    for(int i=0; i<fields.length; i++){
      if (!fields[i].isFree()){
        return false; 
      }
    }
    return true;
  }
  
  void lockAllDices(){
    fields.forEach((field) => field.lockCurrentDice());
  }
}


typedef void Callback<T>(T element);
class GameElementsFactory{
    
  Random _random = new Random();
  Callback<Dice> onCreatedDice;
  Callback<Dice> onDisposeDice;
  
  Callback<Field> onCreatedField;
    
  int getRandomColor(){
    return _random.nextInt(4);
  }
  
  int getRandomValue(){
    return _random.nextInt(4)+1;
  }
  
  Dice createRandomDice(){
    Rectangle rect = new Rectangle(new Point2D(0,0),Dice.DICE_WIDTH,Dice.DICE_WIDTH);
    
    Dice d = new Dice(getRandomValue(), getRandomColor(), rect);
    
    if (onCreatedDice != null){
      onCreatedDice(d);
    }
    return d;
  }
  
  Field createField(Rectangle rect){
    Field field = new Field(rect);
    
    if (onCreatedField != null){
      onCreatedField(field);
    }
    return field;
  }

  void dispose(Dice dice) {
    if (onDisposeDice != null){
      onDisposeDice(dice);
    }
  }
}

typedef void updatePointsCallback(int points);

class Game{
  GameBoard _turnSlot;
  GameBoard _board;
  
  GameElementsFactory _diceFactory;
  Evaluator evaluator = new Evaluator();
  
  num _points = 0;
  
  updatePointsCallback onUpdatePoints;
  
  Game(GameBoard this._turnSlot, GameBoard this._board, GameElementsFactory this._diceFactory);
  
  bool canLock(){
    return _turnSlot.isEmpty();
  }
  
  void lockAllDices(){
    _board.lockAllDices();
  }
  
  void rollNewDices(){
    lockAllDices();
    evaluateAll();
    if (_turnSlot.isEmpty()){
      void setNewDice(Field f){
        if (f.isFree())
          f.setDice(_diceFactory.createRandomDice());
      }
      _turnSlot.fields.forEach(setNewDice);
    }
  }
  
  List<Field> getRow(int row){
    List<Field> fields = new List<Field>();
    for(int i=0; i<4; i++){
      fields.add(_board.getField(row, i));
    }
    return fields;
  }
  
  List<Field> getCol(int col){
    List<Field> fields = new List<Field>();
    for(int i=0; i<4; i++){
      fields.add(_board.getField(i, col));
    }
    return fields;
  }
  
  List<List<Field>> getDiagonals(){
    List<Field> firstDiagonal = [_board.getField(0, 0),
                                 _board.getField(1, 1),
                                 _board.getField(2, 2),
                                 _board.getField(3, 3),
                                 ];
    
    List<Field> secondDiagonal = [_board.getField(3, 0),
                                 _board.getField(2, 1),
                                 _board.getField(1, 2),
                                 _board.getField(0, 3),
                                 ];
    
    return [firstDiagonal, secondDiagonal];
  }
  
  List<List<Field>> getAllSquares() {
    List<List<Field>> squares = new List<List<Field>>();
    
    for(int y=0; y<3; y++){
      for(int x=0; x<3; x++){
        List<Field> square = [
                        _board.getField(x, y),
                        _board.getField(x+1, y),
                        _board.getField(x, y+1),
                        _board.getField(x+1, y+1),
                       ];        
        squares.add(square);
      }
    }
    return squares;
  }
  
  List<List<Field>> getAllCombinations(){
    List<List<Field>> fieldSets = new List<List<Field>>();
    for(int i=0; i<4; i++){
      fieldSets.add(getRow(i));
      fieldSets.add(getCol(i));
    }
    fieldSets.addAll(getDiagonals());
    fieldSets.addAll(getAllSquares());
    return fieldSets;
  }


  
  List<List<Field>> _fieldSets = null;
  void evaluateAll(){
    Set<Field> toRemove = new Set<Field>();
    
    if (_fieldSets == null){
      _fieldSets = getAllCombinations();
    }
    List<Dice> dices = new List<Dice>(4);
    void evaluateFieldSet(List<Field> fields){
      //import dices into dices-array
      for(int i=0; i<fields.length; i++){
        dices[i] = fields[i].dice;
      }
      
      num points = evaluator.getEvaluationFor(dices);
      if (points > 0){
        _points += points;
        toRemove.addAll(fields);
      }
    }
        
    _fieldSets.forEach(evaluateFieldSet);
    updatePoints();
    for(Field f in toRemove){
      if (!f.isFree()){
        Dice dice = f.dice;
        f.clearDice();
        _diceFactory.dispose(dice);
      }
    }
  }
  
  void updatePoints(){
    if (onUpdatePoints != null ){
      onUpdatePoints(_points);
    }
  }
}
