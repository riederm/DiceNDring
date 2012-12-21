part of DiceNDring;

class MouseHandler {
  
  CanvasElement canvas;
  ButtonElement lockButton;

  Field diceOrigin = null;
  Dice draggingDice = null;
  Field droppingField = null;
  
  Layer topLayer;
  Layer dragLayer;
  
  List<Field> _fields = new List<Field>();
  Set<Dice> _dices = new Set<Dice>();
  
  MouseHandler(CanvasElement this.canvas, ButtonElement this.lockButton, Layer this.topLayer, Layer this.dragLayer){
    initListeners(canvas, lockButton);
  }
  
  void addField(Field f){
    _fields.add(f);
  }
  
  bool skipNext = false;
  void onMouseMove(MouseEvent event){
      updateSelected(event.offsetX, event.offsetY);
      
      if (draggingDice != null){
        draggingDice.box.centerAbsoluteOverPoint(event.offsetX, event.offsetY);
        draggingDice.box.clearParentRectangle();
      }

  }
  
  void initListeners(CanvasElement canvas, ButtonElement lockButton){
    bool useCapture = true;
    
    canvas.on.mouseMove.add((e) => onMouseMove(e), useCapture);
    canvas.on.mouseDown.add((e) => onDragStart(e), useCapture);
    canvas.on.mouseUp.add((e) => onDragEnd(e), useCapture);
    
    lockButton.on.click.add((e) => onLockClicked(e));
  }

  void onLockClicked(e) {
    
  }

  void onDragStart(MouseEvent e) {
    e.preventDefault();
    for(Dice d in _dices){
      if (d.box.isInsideAbs(e.offsetX, e.offsetY) && !d._field.isLocked()){
        draggingDice = d;
        d.isDragged = true;
        diceOrigin = d._field;
        
        draggingDice.box.centerAbsoluteOverPoint(e.offsetX, e.offsetY);
        
        dragLayer.drawables.remove(draggingDice);
        topLayer.drawables.add(draggingDice);
        break;
      }
    }
  }
  
  void onDragEnd(MouseEvent e){
    if (draggingDice != null && draggingDice.isDragged){
      draggingDice.isDragged = false;
      
      dragLayer.drawables.add(draggingDice);
      topLayer.drawables.remove(draggingDice);
      
      if (droppingField != null && droppingField.isFree()){
          draggingDice._field.clearDice();
          droppingField.setDice(draggingDice);
      }else{
        draggingDice._field.setDice(draggingDice);        
      }
      draggingDice = null;
    }
  }
  
  
  void updateSelected(num offsetX, num offsetY){
    for(int i = 0; i<_fields.length; i++){
      Field field = _fields[i];
      if (field.box.isInsideAbs(offsetX, offsetY)){
        field.setSelected(true);
        droppingField = field;
        return;
      }else{
        field.setSelected(false);
      }
    }
    
    if (droppingField != null){
      droppingField.setSelected(false);
    }
    droppingField = null;

  }
}
