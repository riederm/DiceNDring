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

  diceFactory.onCreatedDice = (Dice d){
    handler.addDice(d);
    engine.contentLayer.drawables[d] = new DrawableDice(d);
  };
  
  diceFactory.onDisposeDice = (Dice d){
    handler._dices.remove(d);
    engine.removeFromAllLayers(d);
  };
  
  Rectangle r = new Rectangle(new Vector2D(40,40), 4*Field.FIELD_WIDTH, Field.FIELD_HEIGHT);

  CompositeBoxDrawable turnDrawable = new CompositeBoxDrawable(r);
  GameElementsFactory turnFactory = new GameElementsFactory();
  turnFactory.onCreatedField = (Field field){
    turnDrawable.addDrawable(new DrawableField(field));
    handler.addField(field);
  };

  GameBoard turnSlot = new GameBoard(r, turnFactory, 4, 1);
  engine.backgroundLayer.drawables[turnSlot] = turnDrawable;
  
  Rectangle boardRect = new Rectangle(new Vector2D(40,140), 250, 250);
  GameElementsFactory boardFactory = new GameElementsFactory();
  CompositeBoxDrawable boardDrawable = new CompositeBoxDrawable(boardRect);
  
  boardFactory.onCreatedField = (Field field){
    boardDrawable.addDrawable(new DrawableField(field));
    handler.addField(field);
  };
  
  ScoreDrawable score = createScore();
  score.setVisible(false);
  engine.foregroundLayer.drawables[new Object()] = score;
  
  GameBoard board = new GameBoard(boardRect, boardFactory, 4, 4);
  engine.backgroundLayer.drawables[board] = boardDrawable;

  Game game = new Game(turnSlot, board, diceFactory);
  game.onUpdatePoints = (int points) => query("#points").text = "${points} points";
  
  
  game.evaluateAll();
  
  lockButton.on.click.add((e){ 
    lockButton.disabled = true;
    game.lockAllDices();
    List<EvaluationResult> results = game.evaluateAll();
    
    Dice contains(List<Dice> dices, int x, int y){
      for(Dice d in dices){
        if (d.field.x == x && d.field.y == y){
          return d;
        }
      }
      return null;
    }
    
    String getCoordinates(List<Dice> dices){
      StringBuffer buffer = new StringBuffer();
      for(int y=0; y<4; y++){
        for(int x=0; x<4; x++){
          Dice d = contains(dices, x,y);
          if (d != null){
            buffer.add("[${d}]");
          }else{
            buffer.add("[  ]");
          }
        }
        buffer.add(new String.fromCharCodes([0x000A]));
      }
      return buffer.toString();
      //return dices.reduce("", (String prev, Dice d) => "${prev} (${d.field.x},${d.field.y})" );
    }
    
    print("evaluate ... ");
    for(EvaluationResult result in results){
      print("result: ${result.points} - ${result.name}");
      print( "${getCoordinates(result.dices)}");
      print("");
    }
    
    DrawableAnimation animation = createAnimation(results, engine, score);
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

ScoreDrawable createScore(){
  ScoreDrawable sd = new ScoreDrawable(
                        new Score(new RGBColor(255,229,204),
                            new Rectangle(new Vector2D(10, 10), 80, 50)));
  
  return sd;
  
  
  
}

DrawableAnimation createAnimation(List<EvaluationResult> results, RenderingEngine engine, ScoreDrawable score) {
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
    
    
      AnimationChain scoreChain = new AnimationChain();
      scoreChain.addAnimation(new AnimationPause(lastLen));
      scoreChain.addAnimation(new MakeVisible(true));
      scoreChain.addAnimation(new AnimationPause(2*alphaLen));
      scoreChain.addAnimation(new MakeVisible(false));
      
      score.addAnimation(scoreChain);
      
      lastLen = animation.animationLen;
  }
  
  return animation;
}


