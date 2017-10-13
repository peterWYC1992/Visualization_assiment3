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
     .setPosition(1250,950)
     .setSize(80,30)
     .setValue(1)
     .setBroadcast(true)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
     
  cp5.addButton("pause")
     .setBroadcast(true)
     .setPosition(1550,950)
     .setSize(80,30)
     .setValue(2)
     .setBroadcast(true)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
  
  cp5.addSlider("time")
     .setPosition(1200,900)
     .setSize(500,30)
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
  
  fill(155,204,50);
  
  textSize(40);
  fill(255);
  textAlign(CENTER);
  text("Beijing Residents Trajectory", 900, 65);
}

