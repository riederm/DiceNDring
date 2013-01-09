library geo;

class Vector2D{
  num x, y;
  
  Vector2D(num this.x, num this.y);
  
  operator +(Vector2D other) => new Vector2D(x+other.x, y+other.y); 
  operator -(Vector2D other) => new Vector2D(x-other.x, y-other.y);
  
  void move(Vector2D p){
    moveBy(p.x,p.y);
  }
  
  void moveBy(num x, num y){
    this.x+=x;
    this.y+=y;
  }
  
  void moveTo(Vector2D p){
    this.x = p.x;
    this.y = p.y;
  }
  
  void scale(num factor){
    this.x *= factor;
    this.y *= factor;
  }
}

class Rectangle {
  Vector2D pos;
  Rectangle parentRectangle; 
  num width;
  num height;
  
  Rectangle(Vector2D this.pos, num this.width, num this.height);
  
  num get right   => pos.x + width;
  num get bottom  => pos.y + height;
  num get left    => pos.x;
  num get top     => pos.y;
  
  Vector2D absPos(){
    if (parentRectangle != null){
      return pos + parentRectangle.absPos();
    }
    return pos;
  }
  
  bool isPointInside(Vector2D p){
    return isInside(p.x, p.y);
  }
  
  bool isInside(num x, num y){
    return (x >= pos.x && y >= pos.y
        && x <= right && y <= bottom);
  }
  
  bool isInsideAbs(num x, num y){
    if (parentRectangle != null){
      num absX = x - parentRectangle.left;
      num absY = y - parentRectangle.top;
      return isInside(absX, absY);
    }else{
      return isInside(x, y);
    }
  }
  
  bool numersects(Rectangle other){
    return !(other.left > right 
            || other.right < left
            || other.top > bottom
            || other.bottom < top);
  }
  
  void centerOver(Rectangle rect){
    pos.x = rect.left + (rect.width / 2 - (width/2)); 
    pos.y = rect.top + (rect.height / 2 - (height/2)); 
  }
  
  void centerAbsoluteOver(Rectangle rect){
    centerOver(rect);
    pos.move(rect.parentRectangle.absPos());  
  }
  
  void centerAbsoluteOverPoint(num x, num y){
    pos.x = x - width/2;
    pos.y = y - height/2;
  }
  
  void clearParentRectangle(){
    parentRectangle = null;
  }
}



