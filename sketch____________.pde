import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.providers.StamenMapProvider;
import de.fhpotsdam.unfolding.providers.ThunderforestProvider;
import de.fhpotsdam.unfolding.providers.Google;
import de.fhpotsdam.unfolding.providers.EsriProvider;
import de.fhpotsdam.unfolding.providers.GeoMapApp;
import de.fhpotsdam.unfolding.events.EventDispatcher;
import de.fhpotsdam.unfolding.events.MapEvent;
import de.fhpotsdam.unfolding.events.PanMapEvent;
import de.fhpotsdam.unfolding.events.ZoomMapEvent;
import de.fhpotsdam.unfolding.interactions.MouseHandler;
import de.fhpotsdam.unfolding.ui.BarScaleUI;
import de.fhpotsdam.unfolding.ui.CompassUI;
import controlP5.*;
import java.awt.*;
import java.util.List;
import javax.swing.JFrame;
import java.util.Arrays;
import java.awt.*;
import java.awt.event.*;
import java.util.Arrays;
import java.io.*;
import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.text.ParseException; 
import java.util.Date;
import java.text.SimpleDateFormat; 

//***********************************parameters of movement analysis************************************//
UnfoldingMap mapwd;
UnfoldingMap mapwk;
UnfoldingMap map1;
UnfoldingMap map2;
List<Marker> Trajectorywd = new ArrayList<Marker>();
List<Marker> Trajectorywk = new ArrayList<Marker>();
List<Marker> Trajectory = new ArrayList<Marker>();
Location BeijingLocation = new Location(39.9459631, 116.391248);

int [] colorset = {161, 255, 0, 41, 235, 255, 255, 72, 0, 27, 134, 228, 136, 142, 226, 255, 44, 161, 255, 147, 141};
boolean [] tm = {false, false, false, false, false, false, false}; //transport mode selection, false means selected, true means unselected
int t1 = 1; //ID of trajectory, 1 means trajectory in weekday, 2 means trajectory in weekend
int t2 = 2;
int runtimes = 0; //time since sketch started
int runtimep; //previous run time s
int speed=100; //speed of trajectory display
int timeh=0; //current time of trajectory in hours
int timem=0;//current time of trajectory in minutes
boolean s = false; // s = true, time is runing, s = false, paused
boolean modeswitch = false; //modeswitch = false, in movement analysis mode, modeswitch = true, in stay point mode

//parameters for the timeslider
ControlP5 controlP5;
Toggle switchButton;
controlP5.Slider sliderbutton;
controlP5.Button backwardsbutton;
controlP5.Button forwardsbutton;
controlP5.Button playbutton;
controlP5.Button speeddownbutton;
controlP5.Button speedupbutton;

SimpleDateFormat sdftime = new SimpleDateFormat("HH:mm:ss");
UnfoldingMap map; 
EventDispatcher eventDispatcher; 
MouseHandler mouseHandler; 
MarkerManager<Marker> markerManager;
public static int interval = 80000000; // the time interval for showing data, in seconds


void setup() 
{
  size(1600, 1000, P2D);  

  List<Feature> trwd = GeoJSONReader.loadData(this, "Weekday.geojson");
  Trajectorywd = MapUtils.createSimpleMarkers(trwd);

  List<Feature> trwk = GeoJSONReader.loadData(this, "Weekend.geojson");
  Trajectorywk = MapUtils.createSimpleMarkers(trwk);

  //map displaying weekday and weekend data with StamenMap as a basemap
  map1 = new UnfoldingMap(this, "Weekday", 40, 100, 670, 600, true, false, new StamenMapProvider.TonerLite());
  map1.zoomAndPanTo(BeijingLocation, 12);
  map1.addMarkers(Trajectorywd); 
  
  map2 = new UnfoldingMap(this, "Weekend", 900, 100, 670, 600, true, false, new StamenMapProvider.TonerLite());
  map2.zoomAndPanTo(BeijingLocation, 12);  
  map2.addMarkers(Trajectorywk);

  mapwd = map1;
  mapwk = map2;
  MapUtils.createDefaultEventDispatcher(this, mapwd, mapwk, map1, map2);
  drawslider();
}  
  void draw() 
{
  background(250, 243, 225);
  timer(); //control timing of the program
  mapwd.draw(); //visualize weekday trajectory
  shadeTra(t1); 
  mapwk.draw(); //visualize weekend trajectory
  shadeTra(t2);  
  //transport(); //draw the transport legend
  //infoDisplay(); //display almost text information
  

  //stroke(0);
    
    //gweekend();
    //gweekday();
    //frame();
    //graduation();
   // piechart();
    
    //stroke(0);
    //arrow();
}


/********************************************************************
Description: control the timing during program running
********************************************************************/
void timer()
{
  textSize(13);
  controlP5.getController("time").setValue(runtimes);
  line(400, 748, 1192, 748);
  fill(255,0,0);
  for (int i =0; i<25; i++)
  {
    line(400+i*33, 743, 400+i*33, 753);
    text(i, 395 +i*33, 768);
  }
  if ((runtimes < 1 || runtimes > 28800) && s == true)
  {
    //origint = 0;
    runtimes = 1;
    //pausets = 0;
    runtimep = 0;
  } else if (runtimes > 0 && runtimes < 28800 && s == true)
  {
    runtimep = runtimes;
    runtimes = runtimes + speed;
  }
  timeh= runtimes/1200;
  timem= (runtimes%1200)/20;
}

/********************************************************************
Description: Shade the trajectory
********************************************************************/
void shadeTra(int n)
{
  switch(n) //select trajectory which needs to be shaded
  {
  case 1: 
    Trajectory = Trajectorywd;
    break; 

  case 2: 
    Trajectory = Trajectorywk;
    break;
  }
  shadePoint();
}

void shadePoint()
{
  for (Marker marker : Trajectory) 
  {
    Object tmode = marker.getProperty("Tmode");
    String ID = "" + tmode; //get trajectory transport info  
    int id = Integer.parseInt(ID);
    if (tm[id-1] != true) //if false, means this type of transport is selected, need to be shaded
    {
      Object times = marker.getProperty("time");
      String secs = "" + times; 
      Float sec = Float.parseFloat(secs);
      if (sec > runtimep*2 && sec < runtimep*2+(runtimes-runtimep)*2)  //only shade point within a time phrase
      {
        marker.setHidden(false);
        float transp = map(sec, runtimep*2, runtimep*2+(runtimes-runtimep)*2, 0, 230); //transfer the time of trajectory point into transparency
        if (sec > runtimep*2+(runtimes-runtimep)*2-21)//only point at current time will be shaded with stroke 
        {
          marker.setStrokeColor(50);
          marker.setStrokeWeight(2);
          marker.setColor(color(colorset[3*(id-1)], colorset[3*(id-1)+1], colorset[3*(id-1)+2], transp)); //, transp
        } else
        {
          marker.setStrokeWeight(0);
          marker.setColor(color(colorset[3*(id-1)], colorset[3*(id-1)+1], colorset[3*(id-1)+2], transp)); //, transp
        }
      } else //if the point is without a time phrase, do not need to be shade
      {
        marker.setHidden(true);
      }
    } else //if true, means this type of transport is unselected, do not need to be shaded
    {
      marker.setHidden(true);
    }
  }
}

/********************************************************************
Description: Control trajectory displaying
********************************************************************/
void play() 
{
  s = !s; 
  if (s == false)
  {
    //pausets = millis()/4;
    controlP5.getController("play").setLabel("Play");
  } else if (s == true)
  {
    //origint = origint + millis()/4 - pausets;
    controlP5.getController("play").setLabel("Pause");
  }
} // toggle
/********************************************************************
Description: Slider Functions 
********************************************************************/
void time(int value) 
{
  runtimes = value;
}

void forwards()
{
  runtimes = runtimes + 300;
}

void backwards()
{
  runtimes = runtimes - 300;
}

void speedup()
{
  if (speed <= 300 && speed >=100)
  {
    speed = speed+100;
  } else if (speed <100)
  {
    speed = speed + 25;
  }
}

void speeddown()
{
  if (speed > 100)
  {
    speed = speed - 100;
  } else if (speed <= 100&& speed >25)
  {
    speed = speed - 25;
  }
}
//set up buttons for the time slider
void drawslider()
{
  controlP5 = new ControlP5(this);
  sliderbutton = controlP5.addSlider("time", 0, 28800, 400, 710, 792, 30).setSliderMode(Slider.FLEXIBLE).setLabel("");
  backwardsbutton =controlP5.addButton("backwards", 0, 1245, 710, 30, 30).setLabel("<");
  forwardsbutton =controlP5.addButton("forwards", 0, 1325, 710, 30, 30).setLabel(">");
  playbutton = controlP5.addButton("play", 0, 1280, 710, 40, 30);
  speeddownbutton = controlP5.addButton("speeddown", 0, 1210, 710, 30, 30).setLabel("<<");
  speedupbutton = controlP5.addButton("speedup", 0, 1360, 710, 30, 30).setLabel(">>");
  controlP5.getController("time").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
}

