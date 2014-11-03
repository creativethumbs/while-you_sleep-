class letterZ  {
  Body body;
  float w;
  float h;

  letterZ(float x, float y) { 
    w = 10;
    h = 10;  
    makeBody(new Vec2(x, y + h/2), w,h);
  }

  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    noStroke();
    fill(255); 
   
    pushMatrix();
    translate(pos.x, pos.y); 
    rotate(-a);  
    //image(letter, 0, 0);
    rect(0,0,w,h);  
    popMatrix();  
  }
  
  void killBody() {
    box2d.destroyBody(body);
  }
  
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height+w*h) {
      killBody();
      return true;
    }
    return false;
  }
  
  void drop() { 
    Vec2 pos = body.getWorldCenter();
    //THAT'S BS
    body.applyForce(new Vec2(0, 0),pos); 
  }
  
  void makeBody(Vec2 center, float w, float h) {
    
    //center is the position on screen
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.1;
    fd.restitution = 0.2;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    bd.angle = radians(random(-30,30)); 

    body = box2d.createBody(bd);
    body.createFixture(fd);
    

  }
  
}
