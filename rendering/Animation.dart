

part of render;
typedef void Callback();

abstract class DrawableAnimation<T>{
  num animationLen = 0;
  num animationStart = -1;
  bool isActive = true;
  List<Callback> onEnded = new List<Callback>();
  
  DrawableAnimation(num this.animationLen);
  
  void prepareAnimationFrame(num time){
    
    if (animationStart == -1){
      animationStart = time;
    }
    
    num t = time - animationStart;
    if (t<animationLen){
      calcNextAnimationFrame(time, t);
    }else{
      calcEndFrame(time, t);
      onEnded.forEach((Callback c) => c());
    }
    //drawAnimation(context, time);
  }
  void preDelegateDraw(CanvasRenderingContext2D context, T delegate, num time){}
  void postDelegateDraw(CanvasRenderingContext2D context, T delegate, num time){}
  
  void reset(){
    animationStart = -1;
  }
  
  void calcNextAnimationFrame(num absT, num t);
  void calcEndFrame(num absT, num t);
}

class AnimationLoop<T> extends AnimationChain<T>{
  
  void calcEndFrame(num absT, num t){
    super.calcEndFrame(absT, t);
    //reset to first animation
    currentAnimationIndex = 0;
    animationStart = absT;
    currentAnimationStart = -1;
    _animations.forEach((DrawableAnimation a) => a.reset());
  }
  
}

class AnimationChain<T> extends DrawableAnimation<T>{
  List<DrawableAnimation> _animations = new List<DrawableAnimation>();
  bool _canAddAnimations = true;
  int currentAnimationIndex = 0;
  num currentAnimationStart = -1;
  
  AnimationChain(): super(0);
  
  AnimationChain addAnimation(DrawableAnimation a){
    if (_canAddAnimations){
      _animations.addLast(a);
      animationLen += a.animationLen;
    }
    return this;
  }

  void calcNextAnimationFrame(num absT, num t){
    num relT = absT-currentAnimationStart;
    currentAnimationIndex = moveToNextAnimation(relT, absT);
    relT = absT-currentAnimationStart; //maybe we moved currentAnimationStart
    _animations[currentAnimationIndex].calcNextAnimationFrame(absT, relT);
  }
  
  void calcEndFrame(num absT, num t){
    _animations.last.calcEndFrame(absT, absT-currentAnimationStart);
  }
  
  void preDelegateDraw(CanvasRenderingContext2D context, T delegate, num time){
    _animations[currentAnimationIndex].preDelegateDraw(context, delegate, time);
  }
  
  void postDelegateDraw(CanvasRenderingContext2D context, T delegate, num time){
    _animations[currentAnimationIndex].postDelegateDraw(context, delegate, time);
  }
  
  int moveToNextAnimation(num t, num absT){
    if (currentAnimationStart == -1){
      currentAnimationStart = absT;
    }
    
    int index = currentAnimationIndex;
    num runningTime = absT - currentAnimationStart;
    DrawableAnimation animation = _animations[index];
    
    num timeLeft = animation.animationLen - runningTime;
    if (timeLeft > 0){
      return index;
    }else{
      //move to next frame
      num skipTime = timeLeft.abs();
      index = moveIndex(index+1, skipTime, absT);
    }
    
    return index;
  }

  int moveIndex(int currentIndex, num skipTime, num absTime) {
    while(currentIndex < _animations.length){
      DrawableAnimation animation = _animations[currentIndex];
      //does current animation fit into the skipTime-window?
      if (animation.animationLen > skipTime){
        //yes we found the animation
        currentAnimationStart = absTime - skipTime;
        animation.animationStart = currentAnimationStart;
        return currentIndex;
      }else{
        // skip this animation
        currentIndex ++;
        skipTime -= animation.animationLen;
        animation.calcEndFrame(absTime, 0);
        //return currentIndex;
      }
    }
    return -1;
  }
}

class AnimationPause extends DrawableAnimation<Drawable>{
  AnimationPause(num animationLen): super(animationLen);
  
  void preDelegateDraw(CanvasRenderingContext2D context, Drawable delegate, num time){}
  void postDelegateDraw(CanvasRenderingContext2D context, Drawable delegate, num time){}
  
  void calcNextAnimationFrame(num absT, num t){}
  void calcEndFrame(num absT, num t){}
}

/*class Rotation<T extends Drawable> extends DrawableAnimation<T>{
  Rotation(num animationLen): super(animationLen){
    deltaRotation = 2*math.PI / animationLen;
  }
  num deltaRotation;
  num rotation;
  
  void calcNextAnimationFrame(num absT, num t){
    rotation = deltaRotation*t;
  }
  
  void drawAnimation(CanvasRenderingContext2D context, num absT){
    context.save();
    context.rotate(rotation);
    super.drawAnimation(context, absT);
    context.restore();
  }
  
  void calcEndFrame(num absT, num t){
    rotation = 0;
  }
}*/

class AlphaTransition<T> extends DrawableAnimation<T>{
  num alpha = 1;
  num deltaAlpha = 1;
  num targetAlpha;
  num startAlpha;
  
  AlphaTransition(num animationLen, num this.startAlpha, num this.targetAlpha): 
    super(animationLen){
    deltaAlpha = (targetAlpha - startAlpha)/animationLen;    
  }
  
  void calcNextAnimationFrame(num absT, num t){
    alpha = deltaAlpha*t + startAlpha;
  }
  
  void calcEndFrame(num absT, num t){
    alpha = targetAlpha;
  }
  
  void preDelegateDraw(CanvasRenderingContext2D context, T delegate, num time){
    context.save();
    context.setAlpha(alpha);
  }
  
  void postDelegateDraw(CanvasRenderingContext2D context, T delegate, num time){
    context.restore();
  }
  
  void reset(){
    alpha = 1;
  }
}

class PositionTransition<T> extends DrawableAnimation<T>{
  Vector2D delta;
  
  Vector2D nextPoint;
  Vector2D endPoint;
  
  PositionTransition(num animationLen, Vector2D startPoint, Vector2D this.endPoint): 
    super(animationLen){
    delta = (endPoint - startPoint);
    delta.scale(1/animationLen);
    nextPoint = startPoint;
  }
  
  void calcNextAnimationFrame(num absT, num t){
    nextPoint.moveBy(delta.x * t, delta.y * t);
  }
  
  void calcEndFrame(num absT, num t){
   nextPoint = endPoint;
  }
  
}

/*class ColorTransition extends AnimationAdapter<DrawableDice> {
    RGBColor targetColor;
    double _deltaR=0.0;
    double _deltaG=0.0;
    double _deltaB=0.0;
    bool initialized = false;
    
    RGBColor initialColor = new RGBColor(0,0,0);
    ColorTransition(DrawableDice delegate, RGBColor this.targetColor, num animationLen) : super(delegate, animationLen);
    
    void calcNextAnimationFrame(num absT, num t){
      if (!initialized){
         initialColor.apply(delegate.dice.color);
        _deltaR = (targetColor.R - initialColor.R)/animationLen;
        _deltaG = (targetColor.G - initialColor.G)/animationLen;
        _deltaB = (targetColor.B - initialColor.B)/animationLen;
        initialized = true;
      }
      t = math.max(1, t); //min 1
      RGBColor color = delegate.dice.color;
      color.R = (initialColor.R + (_deltaR*t)).round().toInt();
      color.G = (initialColor.G + (_deltaG*t)).round().toInt();
      color.B = (initialColor.B + (_deltaB*t)).round().toInt();
    }
    
    void preDelegateDraw(CanvasRenderingContext2D context, T delegate, num time){
      
    }
    
    void calcEndFrame(num absT, num t){
      delegate.dice.color.apply(targetColor);
    }
    
    void reset(){
      super.reset();
      initialized = false;
    }
}*/