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
    originalColor.apply(drawable.dice.color);
    
    AnimationLoop loop = new AnimationLoop();
    loop.addAnimation(new ColorTransition(drawable, white, 500));
    loop.addAnimation(new AnimationPause(drawable, 200));
    loop.addAnimation(new ColorTransition(drawable, originalColor, 500));
    loop.addAnimation(new AnimationPause(drawable, 2000));
    
    engine.contentLayer.drawables[d] = loop;
    print(engine.contentLayer.drawables);
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
  
  
  game.rollNewDices();
  
  lockButton.on.click.add((e)=> game.rollNewDices());
 
  window.requestAnimationFrame(engine.draw);
}


