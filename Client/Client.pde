// Networking variables
String server_ip = "192.168.1.65"; // the ip of the server computer
Connection con;

// graphics variables
StarFieldBG bg;

void setup(){
  
  // setup the render
  //size(200,200);
  fullScreen();
  bg = new StarFieldBG();

  // connect
  con = new Connection();
  con.connect(server_ip);

}

// when the player touches the screen
void mousePressed() {

  // send a message
  Message msg = new Message();
  msg.put("type", "turn");
  msg.put("cards_played", "Machanized Gunfire");
  con.send(msg);

}

void draw() {
  bg.draw();

  // check for incoming messages
  Message resp = con.recieve();
  if(resp != null) {
    System.out.println("Recieved message: "+resp.to_string());
  }
}
