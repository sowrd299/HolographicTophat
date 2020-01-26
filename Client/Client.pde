// Networking variables
String server_ip = "192.168.1.65"; // the ip of the server computer
Connection con;

// graphics variables
StarFieldBG bg;
Button button;

void setup(){
  
  // setup the render
  fullScreen();
  //size(520,920);

  bg = new StarFieldBG();

  // connect
  con = new Connection();
  con.connect(server_ip);

  // setup the test button
  Rect r = new Rect(32,100,width-64,124);
  button = new Button(r, "Send a Message", color(240,60,60), 5, 32);

}

// when the player touches the screen
void mousePressed() {

  // send a message
  if(button.clicked_by(mouseX,mouseY)){
    Message msg = new Message();
    msg.put("type", "turn");
    msg.put("cards_played", "Machanized Gunfire");
    con.send(msg);
  }

}

void draw() {
  bg.draw();
  button.draw();

  // check for incoming messages
  Message resp = con.recieve();
  if(resp != null) {
    System.out.println("Recieved message: "+resp.to_string());
  }
}
