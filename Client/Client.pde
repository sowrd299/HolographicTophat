import java.util.HashMap;

// Networking variables
String server_ip = "192.168.1.65"; // the ip of the server computer
Connection con;
GameplaySender gp_sender;

// graphics and UI variables
StarFieldBG bg;
color holo_color;
Menu menu;
MenuSwitcher switcher;

// gameplay variables
Opponent[] opponents;
HashMap<String,Player> players; // the players, by ID
CardLoader cl;

// TOP-LEVEL CONTROL FUNCTIONS

void setup(){
  
  // setup the render
  fullScreen();
  //size(520,920);

  // connect
  con = new Connection();
  con.connect(server_ip);

  // setup the GUI
  holo_color = color(240,60,60);
  bg = new StarFieldBG();
  switcher = new MenuSwitcher();
  switcher.switch_menu(new Menu()); // placeholder loading menu

  // setup gameplay
  cl = new CardLoader();

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

  // actually draw the game
  bg.draw();
  menu.draw();

  // check for incoming messages
  Message resp = con.recieve();
  if(resp != null) {
    System.out.println("Recieved message: "+resp.to_string());
    switch (resp.get("type")) {

      // setups the game
      case "setup":

        players = new HashMap<String, Player>();

        // get the local id
        String local_id = resp.get("you_are");
        players.put(local_id, new Player());

        // setup opponents
        String[] player_ids = resp.get("other_players").split(",",0);
        opponents = new Opponent[player_ids.length];
        for(int i = 0; i < player_ids.length; i++){
          Player player = new Player();
          players.put(player_ids[i], player);
          if(player_ids[i] != local_id){
            opponents[i] = new Opponent(player_ids[i]);
          }
        }

        // gameplay connection
        gp_sender = new GameplaySender(con, local_id, opponents, int(resp.get("turn")));
        
        // go into the game menu
        switcher.switch_menu(new MainMenu(opponents, switcher, gp_sender, holo_color));
        break;

      // tells the clients cards have been played
      case "card_play":

        switcher.switch_menu(new AlertMenu(resp.to_string(), holo_color, switcher.create_button_handler(menu)));

        // handle all the played card entries
        for(String k : resp.regex_get_keys(".*_to_.*")){
          // get the player ids
          String[] ids = k.split("_to_",0);
          // get the card played
          Card c = cl.load_card(resp.get(k));
          // where the magic happens
          players.get(ids[1]).play_card_against(players.get(ids[0]), c);
        }

        gp_sender.inc_turn();
      
    }
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

  GameplaySender(Connection con, String local_id, Opponent[] opponents, int starting_turn){
    this.turn = starting_turn;
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