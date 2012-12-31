

part of render;
typedef void Callback();

abstract class Animation extends Drawable{
  num animationLen = 0;
  num animationStart = -1;
  bool isActive = true;
  
  Animation(num this.animationLen);
  
  void draw(CanvasRenderingContext2D context, num time){
    if (animationStart == -1){
      animationStart = time;
    }
    
    num t = time - animationStart;
    if (t<animationLen){
      calcNextAnimationFrame(time, t);
    }else{
      calcEndFrame(time, t);
    }
    drawAnimation(context, time);
  }
  
  void reset(){
    animationStart = -1;
  }
  
  void drawAnimation(CanvasRenderingContext2D context, num absT);
  void calcNextAnimationFrame(num absT, num t);
  void calcEndFrame(num absT, num t);
}

class AnimationLoop extends AnimationChain{
  
  void calcEndFrame(num absT, num t){
    super.calcEndFrame(absT, t);
    //reset to first animation
    currentAnimationIndex = 0;
    animationStart = absT;
    currentAnimationStart = -1;
    _animations.forEach((Animation a) => a.reset());
  }
  
}

class AnimationChain extends Animation{
  List<Animation> _animations = new List<Animation>();
  bool _canAddAnimations = true;
  int currentAnimationIndex = 0;
  num currentAnimationStart = -1;
  
  AnimationChain(): super(0);
  
  AnimationChain addAnimation(Animation a){
    if (_canAddAnimations){
      _animations.addLast(a);
      animationLen += a.animationLen;
    }
    return this;
  }
  
  
  void drawAnimation(CanvasRenderingContext2D context, num absT){
    _animations[currentAnimationIndex].drawAnimation(context, absT);
  }
  
  void calcNextAnimationFrame(num absT, num t){
    num relT = absT-currentAnimationStart;
    currentAnimationIndex = moveToNextAnimation(relT, absT);
    relT = absT-currentAnimationStart; //maybe we moved currentAnimationStart
    _animations[currentAnimationIndex].calcNextAnimationFrame(absT, relT);
  }
  
  void calcEndFrame(num absT, num t){
    //_animations.last.calcEndFrame(absT, absT-currentAnimationStart);
  }
  
  int moveToNextAnimation(num t, num absT){
    if (currentAnimationStart == -1){
      currentAnimationStart = absT;
    }
    
    int index = currentAnimationIndex;
    num runningTime = absT - currentAnimationStart;
    Animation animation = _animations[index];
    
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
      Animation animation = _animations[currentIndex];
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

abstract class AnimationAdapter<T extends Drawable> extends Animation {
  T delegate;
  
  AnimationAdapter(T this.delegate, num animationLen): super(animationLen);
  
  void drawAnimation(CanvasRenderingContext2D context, num absT){
    delegate.draw(context, absT);
  }
  
}

class AnimationPause<T extends Drawable> extends AnimationAdapter<T>{
  AnimationPause(T delegate, num animationLen): super(delegate, animationLen);
  
  void calcNextAnimationFrame(num absT, num t){}
  void calcEndFrame(num absT, num t){}
}


class ColorTransition extends AnimationAdapter<DrawableDice> {
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
    
    void calcEndFrame(num absT, num t){
      delegate.dice.color.apply(targetColor);
    }
    
    void reset(){
      super.reset();
      initialized = false;
    }
}