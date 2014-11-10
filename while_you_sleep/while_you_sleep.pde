/**
 * oscP5broadcastClient by andreas schlegel
 * an osc broadcast client.
 * an example for broadcast server is located in the oscP5broadcaster exmaple.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
import pbox2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import oscP5.*;
import netP5.*;
import deadpixel.keystone.*;

Keystone ks;
PGraphics offscreen;
CornerPinSurface surface;
int offscreenW = 640; 
int offscreenH = 480; 

int xspacing = 20;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave

float theta = 0.0;  // Start angle at 0
float amplitude = 75.0;  // Height of wave
float period = 500.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues;  // Using an array to store height values for the wave

float oldxrot = 0;
float oldzrot = 0; 
float oldorientation = 0;
float xrot = 0;
float zrot = 0; 
float orientation = 0;

// tolerance for the value changes 
// because iphone accelerometers are too sensitive :/
float threshold = 1.5;

boolean moving; 
boolean sleeping = false; 
int mpm;  //movements per minute

float starttime = 0; 
float waittime = 0; 

//timestamp for when person stops moving
int stillness = 0; 

OscP5 oscP5;
/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 

PImage letter;

// BOX 2D STUFF
PBox2D box2d;
ArrayList<letterZ> Zs;

Boundary topbound;
Boundary leftbound;
Boundary rightbound;

int prevSecond; 
int zIndex = -1; 
int dropped;

boolean test = false; 

void setup() {
  size(800, 600); 
  letter = loadImage("Z.png");
  prevSecond = millis(); 
  //noodle = loadFont("BigNoodleTitling.vlw");
  
  // initializing box2d
  box2d = new PBox2D(this); 
  box2d.createWorld(); 
  box2d.setGravity(0, 10);
  
  //creating arraylists
  Zs = new ArrayList<letterZ>();
  topbound = new Boundary(width/2, 0, width, 2);
  leftbound = new Boundary(0, height/2, 2, height);
  rightbound = new Boundary(width, height/2, 2, height);
  
  // listens for OSC messages on port 8000
  oscP5 = new OscP5(this,8000); 
  // broadcasts OSC messages on port 9000
  myBroadcastLocation = new NetAddress("128.237.209.107",9000);
  
  w = height+30; 
  dx = (TWO_PI / period) * xspacing;
  yvalues = new float[w / xspacing]; 
  
  starttime = millis() * 0.001;
  waittime = starttime;
  
} 

void draw() {
  box2d.step(); 
  background(255); 
  
  topbound.display(); 
  leftbound.display();
  rightbound.display();  
  
  boolean xmoved = abs(xrot - oldxrot) > threshold; 
  boolean zmoved = abs(zrot - oldzrot) > threshold; 
  boolean changeori = abs(orientation - oldorientation) > threshold;
  
  //when a person moves
  if(xmoved || zmoved || changeori) { 
    stillness = 0; 
    moving = true; 
    mpm += 1; 
    
    oldxrot = xrot; 
    oldzrot = zrot; 
    oldorientation = orientation;  
    
  }
  //when a person begins to stay still
  else if(moving) {
    stillness = millis()/1000; 
    moving = false; 
  }
  
  // get elapsed time;
  waittime = (millis() * 0.001) - starttime;
  if (waittime > 60) {
    mpm = 0;
    
    // reset counter
    starttime = millis() * 0.001;
    waittime -= starttime;
  }
  
  //if they have not moved for 2 minutes...
  if (millis()/(1000*60) - stillness/60 > 1) { 
    //person is sleeping!
    sleeping = true;  
  }
  
  //println(mpm);
  if (sleeping && millis() - prevSecond >= 1000 && mpm < 30) {
    prevSecond = millis(); 
    //println("here"); 
    letterZ p = new letterZ(width/2, height);
    box2d.setGravity(0, 10);
    Zs.add(p);
    zIndex = Zs.size()-1;
  }
  
  else if (mpm >= 30) {
    sleeping = false;  
    saveFrame("boxes-######.png");
    for (letterZ z: Zs) {
      //int grav = (int)random(-15,-5); 
      box2d.setGravity(0, -10);
      z.drop(); 
    }
    
  }  
  
  for (letterZ z: Zs) {
    z.display(); 
  }
  
  //removes any boxes outside the boundaries
  for (int i = Zs.size()-1; i >= 0; i--) {
    letterZ n = Zs.get(i);
    if (n.done()) {
      Zs.remove(i);
    }
  }
  
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  xrot = (theOscMessage.get(0).floatValue()*90);
  zrot = (theOscMessage.get(1).floatValue()*90)*-1;
  orientation = theOscMessage.get(2).floatValue();
  //println("xrot is"+xrot);
}

void delay(int delay)
{
  int time = millis();
  while(millis() - time <= delay);
}

void mousePressed() {
  sleeping = true;
  /*
  letterZ p = new letterZ(width/2, height);
   box2d.setGravity(0, 10);
   Zs.add(p);
   zIndex = Zs.size()-1; */
}

void keyPressed() {
  sleeping = false; 
  saveFrame("boxes-######.png");
  /*
  box2d.setGravity(0, -10);
  letterZ n = Zs.get(zIndex);
  n.drop();
  zIndex--; */
  
}
 
