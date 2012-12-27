part of render;

class DrawableField extends BoxedDrawable{
  Field _field;
  
  DrawableField(Field field): super(field.box){
    _field = field;
  }
  
  void drawNormalized(CanvasRenderingContext2D context){   
    scaleContext(context);
    
    context.fillStyle = _field.getColor();
    
    context.strokeStyle = "black";
    context.lineWidth = 0.05;
    context.strokeRect(0, 0, 1, 1, 0.03);
    context.fillRect(0, 0, 1, 1);
  }
}

class DrawableDice extends BoxedDrawable{
  static final num TWO_PI = PI*2;
  Dice dice;
  
  DrawableDice(Dice dice): super(dice.box){
    this.dice = dice;
  }
  
  void _drawValue(CanvasRenderingContext2D context, int value){
    context.save();
    switch(value){
      case 1:
        context.translate(0.5, 0.5);
        _drawPoint(context);
        break;
      case 2:
        context.translate(0.2, 0.2);
        _drawPoint(context);
        context.translate(0.6, 0.6);
        _drawPoint(context);
        break;
      case 3:
        _drawValue(context, 1);
        _drawValue(context, 2);
        break;
      case 4:
        context.translate(0.2, 0.2);
        _drawPoint(context);
        context.translate(0.6, 0);
        _drawPoint(context);
        context.translate(-0.6, 0.6);
        _drawPoint(context);
        context.translate(0.6, 0);
        _drawPoint(context);
        break;
      default:
        //ignore
    }
    context.restore();
  }
  
  void _drawPoint(CanvasRenderingContext2D context){
    context.beginPath();
    context.arc(0, 0, 0.1, 0, TWO_PI, false);
    context.closePath();
    context.fill();
  }
  
  void drawNormalized(CanvasRenderingContext2D context){
    scaleContext(context);
    context.fillStyle = dice.getColor();
    context.strokeStyle = "black";
    context.lineWidth = 0.06;
    roundRect(context, 0, 0, 1, 1, 0.1, true, true);
    context.fillStyle = "black";
    _drawValue(context, dice.value);
  }
  
}

