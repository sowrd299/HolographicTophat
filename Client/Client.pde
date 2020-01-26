import oscP5.*; // the OscP5 library must be installed in processing/libraries
import netP5.*;
import java.net.*;

int port = 5006;
String server_ip = "192.168.1.65"; // the ip of the server computer

/*
public TcpServer

public TcpClient con; // the connection to the server
public NetAddress server_addr;
*/
Socket soc;

// starfield variables
int[][] star_coords;

void setup(){
  
  // setup the render
  //size(200,200);
  fullScreen();

  // setup stars
  star_coords = new int[1000][2];
  for(int i = 0; i < star_coords.length; i++) {
    star_coords[i][0] = (int)random(0,width);
    star_coords[i][1] = (int)random(0,height);
  }

  // setup tcp
  System.out.println("Connecting...");
  try{
    soc = new Socket(server_ip, port);
    System.out.println("Connected!");
  }catch(UnknownHostException e){
    System.out.println("UnkownHostException");
  }catch(IOException e){
    System.out.println("IOException");
  }
  /*
  con = new TcpClient(this, server_ip, port, TcpClient.MODE_STREAM);
  if(con.)
  */
}

void mousePressed() {
  // when the player touches the screen
  
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
