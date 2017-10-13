import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import controlP5.*;

UnfoldingMap map;
Location beijing = new Location(39.960985f, 116.360746f);
ControlP5 cp5;

float maxPanningDistance = 30;
PVector bound = new PVector(1800, 1000);
Table  traject;
int cx = 1200, cy = 900;
int radius = 100;
float secondsRadius;
float minutesRadius;
float hoursRadius;
float clockDiameter;

void setup() {
  size(int(bound.x), int(bound.y));
  //map = new UnfoldingMap(this, new OpenStreetMap.OpenStreetMapProvider());
  map = new UnfoldingMap(this, 20, 100, 1000, 780, new Google.GoogleMapProvider());
  MapUtils.createDefaultEventDispatcher(this, map);
  map.zoomAndPanTo(beijing, 12);
  map.setZoomRange(10, 20);
  map.setPanningRestriction(beijing, maxPanningDistance);
  traject = loadTable("20081024020959.csv","header");
  cp5 = new ControlP5(this);
  
     
    // create a few controllers
  cp5.addButton("play")
     .setBroadcast(true)
     .setPosition(1400,925)
     .setSize(80,30)
     .setValue(1)
     .setBroadcast(true)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
     
  cp5.addButton("pause")
     .setBroadcast(true)
     .setPosition(1600,925)
     .setSize(80,30)
     .setValue(2)
     .setBroadcast(true)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
  
  cp5.addSlider("time")
     .setPosition(1350,875)
     .setSize(400,30)
     .setRange(0,24)
     .setValue(0)
     .setNumberOfTickMarks(24)
     ;
     
  cp5.getController("time").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(-30);
  cp5.getController("time").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(-30);
}

void draw() {
  map.draw();
  fill(0, 0, 0);
  noStroke();
  rect(0, 0, bound.x, bound.y/10);
  rect(0, 0, bound.x/90, bound.y);
  rect(bound.x*3/5, 0, bound.x*2/5, bound.y);
  rect(0, bound.y*49/50, bound.x, bound.y/50);
 
  clock();
  
  fill(155,204,50);
  
  secondsRadius = radius * 0.72;
  minutesRadius = radius * 0.60;
  hoursRadius = radius * 0.50;
  clockDiameter = radius * 1.7;
  
  textSize(40);
  fill(255);
  textAlign(CENTER);
  text("Beijing Residents Trajectory", 900, 65);
}

void clock() {  
  // Draw the clock background
  fill(80);
  noStroke();
  ellipse(cx, cy, clockDiameter, clockDiameter);
  
  // Angles for sin() and cos() start at 3 o'clock;
  // subtract HALF_PI to make them start at the top
  float s = map(second(), 0, 60, 0, TWO_PI) - HALF_PI;
  float m = map(minute() + norm(second(), 0, 60), 0, 60, 0, TWO_PI) - HALF_PI; 
  float h = map(hour() + norm(minute(), 0, 60), 0, 24, 0, TWO_PI * 2) - HALF_PI;
  
  // Draw the hands of the clock
  stroke(255);
  strokeWeight(1);
  line(cx, cy, cx + cos(s) * secondsRadius, cy + sin(s) * secondsRadius);
  strokeWeight(2);
  line(cx, cy, cx + cos(m) * minutesRadius, cy + sin(m) * minutesRadius);
  strokeWeight(4);
  line(cx, cy, cx + cos(h) * hoursRadius, cy + sin(h) * hoursRadius);
  
  // Draw the minute ticks
  strokeWeight(2);
  beginShape(POINTS);
  for (int a = 0; a < 360; a+=30) {
    float angle = radians(a);
    float x = cx + cos(angle) * secondsRadius*1.1;
    float y = cy + sin(angle) * secondsRadius*1.1;
    vertex(x, y);
  }
  endShape();
}
