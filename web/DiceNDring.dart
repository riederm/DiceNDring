library DiceNDring;

import 'dart:html';
import 'dart:math';

part 'Geo.dart';
part 'Rendering.dart';
part 'GameElements.dart';
part 'MouseHandler.dart';
part 'BoardEvaluation.dart';

void main() {

  CanvasElement canvas = query("#container");
  ButtonElement lockButton = query("#lockButton");
  
  RenderingEngine engine = new RenderingEngine(canvas, canvas.clientWidth, canvas.clientHeight);
  MouseHandler handler = new MouseHandler(canvas, lockButton, engine.foregroundLayer, engine.contentLayer);
  
  Rectangle r = new Rectangle(new Point(40,40), 4*Field.FIELD_WIDTH, Field.FIELD_HEIGHT);
  
  GameBoard turnSlot = new GameBoard(r, 4, 1);
  engine.backgroundLayer.drawables.add(turnSlot);
  
  GameBoard board = new GameBoard(new Rectangle(new Point(40,140), 250, 250), 4, 4);
  engine.backgroundLayer.drawables.add(board);
  

  DiceFactory diceFactory = new DiceFactory();
  void diceAdded(Dice d){
    handler._dices.add(d);
    engine.contentLayer.drawables.add(d);
  };
  
  diceFactory.onCreatedDice = diceAdded;
  
  void diceDispose(Dice d){
    handler._dices.remove(d);
    engine.removeFromAllLayers(d);
  }
  diceFactory.onDisposeDice = diceDispose;
  
  Game game = new Game(turnSlot, board, diceFactory);
  
  game.rollNewDices();
  
  lockButton.on.click.add((e)=> game.rollNewDices());
  turnSlot._drawables.forEach((e) => handler.addField(e));
  board._drawables.forEach((e) => handler.addField(e));
 
  window.requestAnimationFrame(engine.draw);
}


