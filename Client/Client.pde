// Networking variables
String server_ip = "192.168.1.65"; // the ip of the server computer
Connection con;
GameplaySender gp_sender;

// graphics and UI variables
StarFieldBG bg;
color holo_color;
Menu menu;

// gameplay variables
Opponent[] opponents;

// TOP-LEVEL CONTROL FUNCTIONS

void setup(){
  
  // setup the render
  fullScreen();
  //size(520,920);


  // connect
  con = new Connection();
  con.connect(server_ip);

  // testing content
  opponents = new Opponent[]{
    new Opponent("Micu"),
    new Opponent("Jarli")
  };

  // gameplay connection
  gp_sender = new GameplaySender(con, "Sayngos", opponents);

  // setup the GUI
  holo_color = color(240,60,60);
  bg = new StarFieldBG();
  menu = new MainMenu(opponents, new MenuSwitcher(), gp_sender, holo_color);
  menu.init();

}

// when the player touches the screen
void mousePressed() {

  for(Button button : menu.get_buttons()){
    if(button.click(mouseX,mouseY)){
      // once we've clicked a button, break
      break;
    }
  }

}

void draw() {
  bg.draw();
  menu.draw();

  // check for incoming messages
  Message resp = con.recieve();
  if(resp != null) {
    System.out.println("Recieved message: "+resp.to_string());
  }
}

// OTHER CONTROL FUNCTIONS, WHICH CAN BE CALLED

/**
Provides a callback for switching the menu
*/
class MenuSwitcher{

  class MenuSwitcherHandler implements ButtonHandler{

    private Menu menu;
    private MenuSwitcher switcher;

    MenuSwitcherHandler(Menu menu, MenuSwitcher switcher){
      this.menu = menu;
      this.switcher = switcher;
    }

    void on_click(){
      switcher.switch_menu(menu);
    }

  }

  void switch_menu(Menu m) {
    menu = m;
    menu.init();
  }

  /**
  Creates a button handler that switches the menu
  */
  MenuSwitcherHandler create_button_handler(Menu m){
    return new MenuSwitcherHandler(m, this);
  }

}

/**
A class to handle sending gameplay related messages to the surver
Doubles as a handler for "lock-in" buttons
*/
class GameplaySender implements ButtonHandler{

  Connection con;
  Opponent[] opponents;
  String local_id;
  int turn;

  GameplaySender(Connection con, String local_id, Opponent[] opponents){
    this.turn = 0;
    this.con = con;
    this.opponents = opponents;
    this.local_id = local_id;
  }

  Message create_play_message(){
    Message r = new Message("card_play");
    r.put("turn",str(turn));
    for(Opponent o : opponents){
      Card c = o.get_played_against().get();
      if(c != null) {
        r.put(local_id + "_to_" + o.get_id(),c.get_id());
      }
    }
    return r;
  }

  /**
  Sends a message to the server about cards you have played
  takes if the player is locking in their turn
  returns the success state
  */
  boolean send_play_message(boolean lockin){
    Message r = create_play_message();
    r.put("lockin",str(lockin));
    return con.send(r);
  }

  void on_click(){
    send_play_message(true);
  }

  /**
  Called at the start of each turn to track the turn count
  */
  void inc_turn(){
    turn++;
  }

}