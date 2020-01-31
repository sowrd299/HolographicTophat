import java.util.HashMap;

// Networking variables
String server_ip = "192.168.1.65"; // the ip of the server computer
Connection con;
GameplaySender gp_sender;

// graphics and UI variables
StarFieldBG bg;
color holo_color;
Menu menu;
Menu main_menu;
MenuSwitcher switcher;

// gameplay variables for players
// TODO: this is a bit redundent
PlayerUI[] opponents;
PlayerUI local_player;
String local_id; // DEPRICATED
HashMap<String,Player> players; // the players, by ID

// gameplay variables for cards
Hand hand;
Hand job_hand;
CardLoader cl;

// gameplay variables for jobs
PlayPosition job_position;

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
  job_position = new PlayPosition();

  // testing hand
  hand = new Hand();
  hand.add_card(cl.load_card("Do as Mantis"));
  hand.add_card(cl.load_card("Relay Access"));
  hand.add_card(cl.load_card("Arcus Ar"));
  hand.add_card(cl.load_card("Call the Navosc"));

  // testing job hand
  job_hand = new Hand();
  job_hand.add_card(cl.load_card("Patient Stalking"));
  job_hand.add_card(cl.load_card("Club Infiltration"));
  job_hand.add_card(cl.load_card("Assassination in Nightlife"));

}

/**
Handle the player clicking the screen
*/
void mousePressed() {
  menu.click(mouseX, mouseY);
}

/**
Returns what to call the given player in text
*/
// TODO: Should probably be rolled into the PlayerUI class
String player_name(String player_id){
  return player_id.equals(local_id) ? "You" : player_id;
}

/**
switches to a new jobs menu
*/
void switch_to_jobs_menu(){
  switcher.switch_menu( new JobMenu(
    job_hand,
    players.get(local_id).get_job(),
    job_position,
    new ButtonHandler() {
      public void on_click(){
        switcher.switch_menu(main_menu);
        gp_sender.send_job_message(true);
      }
    },
    holo_color
  ) );
}

/**
THE MAIN LOOP
*/
void draw() {

  // render onto the screen
  bg.draw();
  menu.draw();

  // check for incoming messages
  Message resp = con.recieve();
  if(resp != null) {
    System.out.println("Recieved message: "+resp.to_string());
    switch (resp.get("type")) {

      // SETS UP THE GAME 
      case "setup":

        players = new HashMap<String, Player>();

        // get the local id
        local_id = resp.get("you_are");
        Player lp = new Player();
        players.put(local_id, lp);
        local_player = new PlayerUI(local_id, lp);

        // setup opponents
        String[] player_ids = resp.get("other_players").split(",",0);
        opponents = new PlayerUI[player_ids.length];
        for(int i = 0; i < player_ids.length; i++){
          Player player = new Player();
          players.put(player_ids[i], player);
          if(player_ids[i] != local_id){
            opponents[i] = new PlayerUI(player_ids[i], player);
          }
        }

        // draw starting hands
        for(String id : players.keySet()){
          players.get(id).draw_cards(6);
        }

        // gameplay connection
        gp_sender = new GameplaySender(con, local_id, opponents, int(resp.get("turn")));
        
        // go into the game menu; currently starts by choosing your first job
        main_menu = new MainMenu(opponents, local_player, hand, switcher, gp_sender, holo_color);
        switch_to_jobs_menu();
        break;

      // TELL THE CLIENT CARDS HAVE BEEN PLAYED 
      case "card_play":

        String alert = "";
        boolean jobs_next = false; // if the next thing to happen is playing jobs

        // HANDLE PLAYING MANEUVERS AS DEFENSE
        // for the rules to work, this must happen before playing maneuvers
        for(String id : players.keySet()){
          String card_id = resp.get(id + "_defense");
          if(card_id != null){
            Card c = cl.load_card(card_id);
            players.get(id).play_defense(c);
            players.get(id).played_from_hand(c);
            alert += player_name(id) + " defended with " + c.get_id() + ".\n";
            jobs_next = true;
          }
        }

        // HANDLE PLAYING MANEUVERS AGAINST OTHER PLAYERS
        // TODO: parsing should probably get rolled in with gp_sender
        for(String k : resp.regex_get_keys(".*_to_.*")){
          // get the player ids for who played the card on who
          String[] ids = k.split("_to_",0);
          // get the card played
          Card c = cl.load_card(resp.get(k));
          // actually play the card
          players.get(ids[1]).play_card_against(players.get(ids[0]), c);
          players.get(ids[0]).played_from_hand(c);
          // we now know the next step will be playing jobs
          jobs_next = true;
          // tell the player what happened
          alert += player_name(ids[0]) + " played " + c.get_id() + " against " + player_name(ids[1]) + ".\n";
        }

        // NOW THAT WE DON'T NEED DEFENSE ANYMORE, CLEAR THEM
        for(String id : players.keySet()){
          players.get(id).clear_defense();
        }

        // HANDLE PLAYING AND CONTINUING JOBS
        for(String id : players.keySet()){
          // continuing jobs
          if("true".equals(resp.get(id + "_continue_job"))){
            players.get(id).continue_job();
            alert += player_name(id) + " continued the job " + players.get(id).get_job().get_id() + ".\n";
          }
          // playing new jobs
          String card_id = resp.get(id + "_job");
          if(card_id != null){
            Card card = cl.load_card(card_id);
            if(card != null){
              // wrap up the last job
              boolean success = players.get(id).finish_job();
              if(players.get(id).get_job() != null){
                alert += player_name(id) + (success ? " successfully compleated " : " failed ") + " the job " + players.get(id).get_job().get_id() + ".\n";
              }
              // actually play the new job
              players.get(id).play_job(card);
              alert += player_name(id) + " began the job " + players.get(id).get_job().get_id() + ".\n";
            }
          }
        }

        // leave any current menu
        switcher.switch_menu(main_menu);

        // HAND THE START OF A NEW ROUND
        // draw cards and go to the jobs menu
        if(jobs_next){
          for(String id : players.keySet()){
            players.get(id).draw_cards(3);
          }
          switch_to_jobs_menu();
        }

        // alert the user to what happened
        // TODO: this can preserve a menu that shouldn't be preverve sometimes
        switcher.switch_menu(new AlertMenu(alert, holo_color, switcher.create_button_handler(menu)));

        // clear all card positions
        // TODO: doing this exhaustively is annoying
        for(PlayerUI o : opponents){
          o.get_played_against().clear();
        }
        local_player.get_played_against().clear();
        job_position.clear();

        // increment the turn count
        gp_sender.inc_turn();

        break;
      
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
    System.out.println("Switching menu...");
    menu = m;
    menu.init();
    System.out.println("...switched!");
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
  PlayerUI[] opponents;
  String local_id;
  int turn;

  GameplaySender(Connection con, String local_id, PlayerUI[] opponents, int starting_turn){
    this.turn = starting_turn;
    this.con = con;
    this.opponents = opponents;
    this.local_id = local_id;
  }

  Message populate_basic_message(Message r, boolean lockin){
    r.put("turn",str(turn));
    r.put("lockin",str(lockin));
    return r;
  }

  Message populate_play_message(Message r){
    // cards played against opponents
    for(PlayerUI o : opponents){
      Card c = o.get_played_against().get();
      if(c != null) {
        r.put(local_id + "_to_" + o.get_id(),c.get_id());
      }
    }
    // the defense cards
    Card defense = local_player.get_played_against().get();
    if(defense != null){
      r.put(local_id + "_defense", defense.get_id());
    }
    // cleanup
    return r;
  }

  /**
  Sends a message to the server about cards you have played
  takes if the player is locking in their turn
  returns the success state
  */
  boolean send_play_message(boolean lockin){
    Message r = populate_play_message(new Message("card_play"));
    populate_basic_message(r, lockin);
    return con.send(r);
  }


  Message populate_job_message(Message r){
    Card job = job_position.get();
    r.put(local_id + "_job", job != null ? job.get_id() : "");
    r.put(local_id + "_continue_job", str(job == null));
    return r;
  }

  /**
  Sends a message to the server about cards you have played
  takes if the player is locking in their turn
  returns the success state
  */
  boolean send_job_message(boolean lockin){
    Message r = populate_job_message(new Message("card_play"));
    populate_basic_message(r, lockin);
    return con.send(r);
  }

  /**
  Allows this to be used a a button handler
  */
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