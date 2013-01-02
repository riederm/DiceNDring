library DiceNDring;

import 'dart:html';
import 'dart:math';
import '../geo/Geo.dart';
import '../game/game.dart';
import '../rendering/render.dart';

part 'MouseHandler.dart';



  
void main() {
  CanvasElement canvas = query("#container");
  ButtonElement lockButton = query("#lockButton");
  
  RenderingEngine engine = new RenderingEngine(canvas, canvas.clientWidth, canvas.clientHeight);
  MouseHandler handler = new MouseHandler(canvas, lockButton, engine.foregroundLayer, engine.contentLayer);
  
  GameElementsFactory diceFactory = new GameElementsFactory();

  void diceAdded(Dice d){
    handler.addDice(d);
    
    DrawableDice drawable = new DrawableDice(d);
    RGBColor white = new RGBColor(0xff, 0xff, 0xff);
    RGBColor originalColor = new RGBColor(0,0,0);
    originalColor.apply(drawable.delegate.color);
    
    /*AnimationLoop<DrawableDice> loop = new AnimationLoop<DrawableDice>();
    loop.addAnimation(new AnimationPause(1000));
    loop.addAnimation(new AlphaTransition<DrawableDice>(350, 1, 0.3));
    loop.addAnimation(new AlphaTransition<DrawableDice>(350, 0.3, 1));
    
    drawable.animations.add(loop);*/
    engine.contentLayer.drawables[d] = drawable;
  };
  
  void diceDispose(Dice d){
    handler._dices.remove(d);
    engine.removeFromAllLayers(d);
  }        
  
  diceFactory.onCreatedDice = diceAdded;
  diceFactory.onDisposeDice = diceDispose;
  
  void fieldCreated(CompositeBoxDrawable drawable, Field field){
    drawable.addDrawable(new DrawableField(field));
    handler.addField(field);
  }
  
  Rectangle r = new Rectangle(new Point2D(40,40), 4*Field.FIELD_WIDTH, Field.FIELD_HEIGHT);
  GameElementsFactory turnFactory = new GameElementsFactory();
  CompositeBoxDrawable turnDrawable = new CompositeBoxDrawable(r);
  turnFactory.onCreatedField = (Field f) => fieldCreated(turnDrawable, f);
  GameBoard turnSlot = new GameBoard(r, turnFactory, 4, 1);
  engine.backgroundLayer.drawables[turnSlot] = turnDrawable;
  
  Rectangle boardRect = new Rectangle(new Point2D(40,140), 250, 250);
  GameElementsFactory boardFactory = new GameElementsFactory();
  CompositeBoxDrawable boardDrawable = new CompositeBoxDrawable(boardRect);
  boardFactory.onCreatedField = (Field f) => fieldCreated(boardDrawable, f);
  GameBoard board = new GameBoard(boardRect, boardFactory, 4, 4);
  
  engine.backgroundLayer.drawables[board] = boardDrawable;
  
  Game game = new Game(turnSlot, board, diceFactory);
  game.onUpdatePoints = (int points) => query("#points").text = "${points} points";
  
  
  game.evaluateAll();
  
  lockButton.on.click.add((e){ 
    lockButton.disabled = true;
    game.lockAllDices();
    List<EvaluationResult> results = game.evaluateAll();
    
    DrawableAnimation animation = createAnimation(results, engine);
    if (animation != null){
      animation.onEnded.add((){
        game.fillTurnSlot();
        lockButton.disabled = false;
      });
    }else{
      game.fillTurnSlot();
      lockButton.disabled = false;
    }
  });
 
  window.requestAnimationFrame(engine.draw);
}

DrawableAnimation createAnimation(List<EvaluationResult> results, RenderingEngine engine) {
  final double originalAlpha = 1.0;
  final double destAlpha = 0.4;
  final num alphaLen = 350;
  
  final num delay = 0;
  
  num lastLen = 0;
  
  AnimationChain animation = null;
  for(EvaluationResult result in results){
    for(Dice dice in result.dices){
      Drawable drawableDice = engine.contentLayer.drawables[dice];
      
      if (drawableDice is BoxedAnimatable){
        BoxedAnimatable animatable = drawableDice;
        
        animation = new AnimationChain();
        animation.addAnimation(new AnimationPause(lastLen));
        animation.addAnimation(new AlphaTransition<Drawable>(alphaLen, originalAlpha, destAlpha));
        animation.addAnimation(new AlphaTransition<Drawable>(alphaLen, destAlpha, originalAlpha));
        
        animatable.addAnimation(animation);
      }
    }
    lastLen = animation.animationLen;
  }
  return animation;
}


