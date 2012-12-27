part of DiceNDring;

class MouseHandler {
  
  CanvasElement canvas;
  ButtonElement lockButton;

  Field diceOrigin = null;
  Dice draggingDice = null;
  Field droppingField = null;
  
  Layer topLayer;
  Layer dragLayer;
  

  Set<Field> _fields = new Set<Field>();
  Set<Dice> _dices = new Set<Dice>();
  
  MouseHandler(CanvasElement this.canvas, ButtonElement this.lockButton, Layer this.topLayer, Layer this.dragLayer){
    initListeners(canvas, lockButton);
  }
  
  void addField(Field f){
    _fields.add(f); 
  }
  
  void addDice(Dice d){
  _dices.add(d);
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
      if (d.box.isInsideAbs(e.offsetX, e.offsetY) && !d.field.isLocked()){
        draggingDice = d;
        d.isDragged = true;
        diceOrigin = d.field;
        
        draggingDice.box.centerAbsoluteOverPoint(e.offsetX, e.offsetY);
        
        Drawable drawable = dragLayer.drawables.remove(draggingDice);
        topLayer.drawables[draggingDice]= drawable;
        break;
      }
    }
  }
  
  void onDragEnd(MouseEvent e){
    if (draggingDice != null && draggingDice.isDragged){
      Dice dice = draggingDice;
      dice.isDragged = false;
      
      Drawable drawable = topLayer.drawables.remove(draggingDice);
      dragLayer.drawables[draggingDice] = drawable;
      
      if (droppingField != null && droppingField.isFree()){
          draggingDice.field.clearDice();
          droppingField.setDice(draggingDice);
      }else{
        draggingDice.field.setDice(draggingDice);        
      }
      draggingDice = null;
    }
  }
  
  
  void updateSelected(num offsetX, num offsetY){
    for(Field field in _fields){
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
