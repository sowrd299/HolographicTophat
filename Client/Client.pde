import oscP5.*; // the OscP5 library must be installed in processing/libraries
import netP5.*;

int socket = 5006;
String server_ip = "196.168.1.65"; // the ip of the server computer

public OscP5 oscP5;
public NetAddress server_addr;

void setup(){
  
  // setup the render
  fullScreen();

  // setup tcp
  oscP5 = new OscP5(this, server_ip, socket, OscP5.TCP);
}

void draw() {
  // wipe the screen
  background(5);
}
