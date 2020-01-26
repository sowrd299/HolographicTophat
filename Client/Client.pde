import oscP5.*; // the OscP5 library must be installed in processing/libraries
import netP5.*;

int socket = 5006;
String server_ip = "196.168.1.65"; // the ip of the server computer

public OscP5 oscP5;
public NetAddress server_addr;

int[][] star_coords;

void setup(){
  
  // setup the render
  fullScreen();

  // setup stars
  star_coords = new int[1000][2];
  for(int i = 0; i < star_coords.length; i++) {
    star_coords[i][0] = (int)random(0,width);
    star_coords[i][1] = (int)random(0,height);
  }

  // setup tcp
  //oscP5 = new OscP5(this, server_ip, socket, OscP5.TCP);
}

void mousePressed() {
  // when the player touches the screen
  //oscP5.send("/test", new Object[]{new Integer(1)});
}

void draw() {
  // wipe the screen
  background(30,30,40);
  // draw some stars
  stroke(255);
  for(int i = 0; i < 1000; i++){
    strokeWeight(random(1,4));
    point(star_coords[i][0], star_coords[i][1]);
  }
}
