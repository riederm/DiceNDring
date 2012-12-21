part of DiceNDring;

abstract class Drawable{
  bool _visible = true;
  
  bool isVisible(){
    return _visible;
  }
  
  void setVisible(bool visible){
    _visible = visible; 
  }
  
  void draw(CanvasRenderingContext2D context);
  
  /**
   * Draws a rounded rectangle using the current state of the canvas. 
   * If you omit the last three params, it will draw a rectangle 
   * outline with a 5 pixel border radius 
   * @param {CanvasRenderingContext2D} ctx
   * @param {Number} x The top left x coordinate
   * @param {Number} y The top left y coordinate 
   * @param {Number} width The width of the rectangle 
   * @param {Number} height The height of the rectangle
   * @param {Number} radius The corner radius. Defaults to 5;
   * @param {Boolean} fill Whether to fill the rectangle. Defaults to false.
   * @param {Boolean} stroke Whether to stroke the rectangle. Defaults to true.
   */
  void roundRect(CanvasRenderingContext2D ctx, num x, num y, num width, num height, num radius, bool fill, bool stroke) {

    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height - radius);
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    ctx.lineTo(x + radius, y + height);
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
    if (stroke) {
      ctx.stroke();
    }
    if (fill) {
      ctx.fill();
    }        
  }
}


abstract class BoxedDrawable extends Drawable{
 
  Rectangle box;

  bool _alreadyCentered = false;
  bool _alreadyScaled = false;

  BoxedDrawable(this.box);
  
  void drawNormalized(CanvasRenderingContext2D context);
  
  void adaptContext(CanvasRenderingContext2D context, bool translate, bool scale){
    if (translate){
      context.translate(box.left, box.top);
    }
    
    if (scale){
      context.scale(box.width, box.height);
    }
  }
  
  void centerContext(CanvasRenderingContext2D context){
    if (!_alreadyCentered){
      if (_alreadyScaled){
        context.translate(0.5, 0.5); 
      }else{
        context.translate(box.width/2, box.height/2);
      }
    }
  }
  
  void scaleContext(CanvasRenderingContext2D context){
    if (!_alreadyScaled){
      context.scale(box.width, box.height);
    }
  }

  void draw(CanvasRenderingContext2D context){
    context.save();
    try{
      context.translate(box.left, box.top);
      drawNormalized(context);
    }finally{
      context.restore();
    }
  }
}

abstract class CompositeBoxDrawable extends BoxedDrawable{
  List<Drawable> _drawables = new List<Drawable>();
  
  CompositeBoxDrawable(Rectangle box) : super(box);
  
  void drawNormalized(CanvasRenderingContext2D context){
    _drawables.forEach((drawable) => drawable.draw(context));
  }
  
  void addDrawable(Drawable drawable){
    _drawables.add(drawable);
  }
}



class BoxedLayer extends BoxedDrawable{
  BoxedLayer(Rectangle box, [bool shouldScale = true, bool shouldTranslate = true]): super(box);
  List<Drawable> drawables = new List<Drawable>();
  
  void drawNormalized(CanvasRenderingContext2D context){
    drawables.forEach((d) { 
      if(d.isVisible()){  
        d.draw(context);
      }
    });
  }
}

class Layer extends Drawable {
  Set<Drawable> drawables = new Set<Drawable>();
  
  void draw(CanvasRenderingContext2D context){
    drawables.forEach((d) { 
          if(d.isVisible()){  
            d.draw(context);
          }
        });
  }
}

class RenderingEngine{
  
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  
  Layer backgroundLayer = new Layer();
  Layer contentLayer = new Layer();
  Layer foregroundLayer = new Layer();
  
  num _width;
  num _height;
  
  RenderingEngine(this._canvas, num this._width, num this._height){
    _context = _canvas.context2d;
  }
  
  num renderTime;
  
  void draw(num time){
    
    num time = new Date.now().millisecondsSinceEpoch;

    if (renderTime != null) {
      showFps((1000 / (time - renderTime)).round());
    }

    renderTime = time;
    _context.clearRect(0, 0, _width, _height);
    _drawLayer(backgroundLayer);
    _drawLayer(contentLayer);
    _drawLayer(foregroundLayer);
    window.requestAnimationFrame(draw);
  }
  
  void _drawLayer(Layer layer){
    if (layer.isVisible()){
      layer.draw(_context);
    }
  }
  
  double fpsAverage;

  /**
   * Display the animation's FPS in a div.
   */
  void showFps(num fps) {
    if (fpsAverage == null) {
      fpsAverage = fps;
    }

    fpsAverage = fps * 0.05 + fpsAverage * 0.95;

    query("#notes").text = "${fpsAverage.round().toInt()} fps";
  }

  void removeFromAllLayers(Dice d) {
    backgroundLayer.drawables.remove(d);
    contentLayer.drawables.remove(d);
    foregroundLayer.drawables.remove(d);
  }
}