part of game;

class Dice{
  static final num MARGIN = 3;
  static final num DICE_WIDTH = Field.FIELD_WIDTH*0.8;
  static final num TWO_PI = PI*2;
  
  static final int RED = 0;
  static final int BLUE = 1;
  static final int GREEN = 2;
  static final int YELLOW = 3;
  
  Rectangle box;
  int value = 1;
  int color = RED;
  bool isDragged = false;
  Field _field = null;
  
  Dice(Rectangle this.box, int this.value, int this.color);
  
  void drawPoint(CanvasRenderingContext2D context){
    context.beginPath();
    context.arc(0, 0, 0.1, 0, TWO_PI, false);
    context.closePath();
    context.fill();
  }
  
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
  
  void drawValue(CanvasRenderingContext2D context, int value){
    context.save();
    switch(value){
      case 1:
        context.translate(0.5, 0.5);
        drawPoint(context);
        break;
      case 2:
        context.translate(0.2, 0.2);
        drawPoint(context);
        context.translate(0.6, 0.6);
        drawPoint(context);
        break;
      case 3:
        drawValue(context, 1);
        drawValue(context, 2);
        break;
      case 4:
        context.translate(0.2, 0.2);
        drawPoint(context);
        context.translate(0.6, 0);
        drawPoint(context);
        context.translate(-0.6, 0.6);
        drawPoint(context);
        context.translate(0.6, 0);
        drawPoint(context);
        break;
      default:
        //ignore
    }
    context.restore();
  }
  
  void drawNormalized(CanvasRenderingContext2D context){
    scaleContext(context);
    context.fillStyle = getColor();
    context.strokeStyle = "black";
    context.lineWidth = 0.06;
    roundRect(context, 0, 0, 1, 1, 0.1, true, true);
    context.fillStyle = "black";
    drawValue(context, value);
  }
  
}

class Field{

  static final num FIELD_HEIGHT = 70;
  static final num FIELD_WIDTH = FIELD_HEIGHT;
  
  static final defaultBackground = "white"; //"#99CCFF";
  static final selectedBackground = "#ffcccc";
  
  Field(Rectangle this.box);
  
  bool _selected = false;
  bool _diceLocked = false;
  Dice dice;
  Rectangle box;
  
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
  
  void drawNormalized(CanvasRenderingContext2D context){   
    //centerContext(context);
    scaleContext(context);
    
    context.fillStyle = getColor();
    
    context.strokeStyle = "black";
    context.lineWidth = 0.05;
    context.strokeRect(0, 0, 1, 1, 0.03);
    context.fillRect(0, 0, 1, 1);
  }
  
  void setSelected(bool s){
    _selected = s;
  }
  
  void setDice(Dice newDice){
    Rectangle diceBox = newDice.box;
    Rectangle fieldBox = box;
    diceBox.centerAbsoluteOver(fieldBox);
    dice = newDice;
    newDice._field = this;
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

class GameBoard {
  int _horizontalFields;
  int _verticalFields;
  List<Field> _fields = new List<Field>();
  static final int MARGIN = 8;
  Rectangle box;
  
  GameBoard(Rectangle this.box, [int this._horizontalFields = 4, int this._verticalFields = 4]){
    for(num y=0; y<_verticalFields; y++){
      for(num x=0; x<_horizontalFields; x++){
        Point2D pos = new Point2D(x*(Field.FIELD_WIDTH+MARGIN), y*(Field.FIELD_HEIGHT+MARGIN));
        Rectangle rect = new Rectangle(pos, Field.FIELD_WIDTH, Field.FIELD_HEIGHT);
        Field field = new Field(rect);
        _fields.add(field);
        //addDrawable(field);
        field.box.parentRectangle = this.box;
      }
    }
  }
  
  Field getField(int x, int y){
    return _fields[y*_horizontalFields + x];
  }
  
  void addFieldsToLayer(Layer layer){
    _fields.forEach((field) => layer.drawables.add(field));    
  }

  bool isEmpty() {
    for(int i=0; i<_fields.length; i++){
      if (!_fields[i].isFree()){
        return false; 
      }
    }
    return true;
  }
  
  void lockAllDices(){
    _fields.forEach((field) => field.lockCurrentDice());
  }
}


typedef void DiceCallback(Dice dice);
class DiceFactory{
    
  Random _random = new Random();
  DiceCallback onCreatedDice;
  DiceCallback onDisposeDice;
    
  int getRandomColor(){
    return _random.nextInt(4);
  }
  
  int getRandomValue(){
    return _random.nextInt(4)+1;
  }
  
  Dice createRandomDice(){
    Rectangle rect = new Rectangle(new Point2D(0,0),Dice.DICE_WIDTH,Dice.DICE_WIDTH);
    
    Dice d = new Dice(rect, getRandomValue(), getRandomColor());
    
    if (onCreatedDice != null){
      onCreatedDice(d);
    }
    return d;
  }

  void dispose(Dice dice) {
    if (onDisposeDice != null){
      onDisposeDice(dice);
    }
  }
}

class Game{
  GameBoard _turnSlot;
  GameBoard _board;
  
  DiceFactory _diceFactory;
  Evaluator evaluator = new Evaluator();
  
  num _points = 0;
  
  Game(GameBoard this._turnSlot, GameBoard this._board, DiceFactory this._diceFactory);
  
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
      _turnSlot._fields.forEach(setNewDice);
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
    
    void evaluateFieldSet(List<Field> fields){
      num points = evaluator.getEvaluationFor(fields);
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
    query("#points").text = "${_points} points";
  }
}
