// Networking variables
String server_ip = "192.168.1.65"; // the ip of the server computer
Connection con;

// starfield variables
int[][] star_coords;

void setup(){
  
  // setup the render
  //size(200,200);
  fullScreen();

  // connect
  con = new Connection();
  con.connect(server_ip);

  // setup stars
  star_coords = new int[1000][2];
  for(int i = 0; i < star_coords.length; i++) {
    star_coords[i][0] = (int)random(0,width);
    star_coords[i][1] = (int)random(0,height);
  }

}

void mousePressed() {
  // when the player touches the screen
  Message msg = new Message();
  msg.put("type", "turn");
  msg.put("cards_played", "Machanized Gunfire");
  con.send(msg);
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
