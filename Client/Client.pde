import java.util.HashMap;
import java.util.HashSet;
import java.util.ArrayList;
import java.lang.Iterable;

// Networking variables
String server_ip = "108.88.231.121"; //"192.168.1.65"; // the ip of the server computer
Connection con;
GameplaySender gp_sender;

// the UI text for the connecting menus
String welcome_text = ":AEH 41.06.54:\nWelcome .Agent. to:\n\nVITIUM\n\n";
String not_connected_text = welcome_text+"Connecting to insterstellar coms relay...\n\n:brief:\n"+
    "This is not a glorious age. The Last Golden Age of Humanity, an era of unmatched prosperity,"+
    " has ended. Civilization is waning, governments crumbling, and the rule of crime rising. "+
    "Powerful underworld factions, known as déod·Hüs·set—the Houses, have come to power. "+
    "The once mighty Senate of Jupitov and Monarchy of Cïjang are puppets in the House's twisted games. "+
    "The poor are destitute and the wealthy are corrupt. Technology and learning exist only to advance the agendas of those in power. "+
    "Wars are fought in back alleys and secret apartments by leaders of industry and crime, and their soldiers die in gutters.\n"+
    "Thus is the world of the Eleven Systems, at the dawn of the so-called Era of the Houses.";
String waiting_text = welcome_text+"Relay located. Link secured.\nAwaiting handshake from foreign parties...";
String connected_text = welcome_text+"Relay located. Link secured. Foreign parties identified. Comsnet established. The game is afoot .Agent.. Best of luck.";
String lockin_text = "Options locked in. Anticipating enemy countermeasures.";
String nothing_happened_text = "Nothing happened. All agents chose to remain passive.";

Menu connecting_menu;

// graphics and UI variables
StarFieldBG bg;
color holo_color;
MainMenu main_menu;
JobMenu job_menu;
MenuSwitcher switcher;

// general gameplay variables
GameManager gm;

// gameplay variables for players
// TODO: this is a bit redundent
PlayerUI[] opponents;
LocalPlayerUI local_player;
HashMap<String,Player> players; // the players, by ID

// gameplay variables for cards
CardLoader cl;

// gameplay variables for jobs
PlayPosition job_position; // TODO: maybe this should get rolled into local player ui?

// playtesting variables
Deck test_deck;
Hand test_job_hand; // TODO: this should get rolled into player



// TOP-LEVEL CONTROL FUNCTIONS

void setup(){
  
  // setup the render
  //fullScreen();
  size(520,920);

  // connect
  con = new Connection();

  // setup the GUI
  holo_color = new color[]{ // TODO: random color for testing
    color(240,60,60), //haro
    color(60,240,60), //grim
    color(80,60,240), //avond
    color(240,240,60), //calitus
    color(60,120,180) //malitus
  }[int(random(4))];
  bg = new StarFieldBG();
  switcher = new MenuSwitcher();

  connecting_menu = new AlertMenu(not_connected_text, holo_color, null);

  // setup gameplay
  cl = new CardLoader();
  job_position = new PlayPosition();

  // testing job hand
  test_job_hand = new Hand();
  test_job_hand.add_card(cl.load_card("Patient Stalking"));
  test_job_hand.add_card(cl.load_card("Club Infiltration"));
  test_job_hand.add_card(cl.load_card("Rocketeering"));
  test_job_hand.add_card(cl.load_card("Assassination in Nightlife"));

  // testing deck
  test_deck = new Deck();
  test_deck.add_card(cl.load_card("Relay Access"),2);
  test_deck.add_card(cl.load_card("Tampering Ghast"),2);
  test_deck.add_card(cl.load_card("Raw Muscle"),3);
  test_deck.add_card(cl.load_card("The Arcus 2's Aid"),3);
  test_deck.add_card(cl.load_card("Dreadfleat's Aid"),1);
  test_deck.add_card(cl.load_card("Supressive Fire"),2);
  test_deck.add_card(cl.load_card("Heavy Fire"),2);
  test_deck.add_card(cl.load_card("Turret Fire"),2);
  test_deck.add_card(cl.load_card("Embargo"),3);
  test_deck.add_card(cl.load_card("Boarding"),3);
  test_deck.add_card(cl.load_card("Alert DJNF"),1);

}

/**
Handle the player clicking the screen
*/
void mousePressed() {
  switcher.click(mouseX, mouseY);
}

/**
THE MAIN LOOP
*/
void draw() {

  // RECIEVE AND PROCESS MESSAGES
  if(con.is_connected()) {

    // check for incoming messages
    Message resp = con.recieve();
    if(resp != null) {
      System.out.println("Recieved message: "+resp.to_string());
      switch (resp.get("type")) {

        // WHEN TOLD TO LOGIN BY THE SERVER:
        case "please_login":
          switcher.switch_menu(new LoginMenu(con, holo_color));
          break;

        // WHEN TOLD TO WAIT BY THE SERVER:
        case "wait":
          switcher.switch_menu(new AlertMenu(waiting_text, holo_color, null));
          break;

        // SETS UP THE GAME 
        case "setup":

          randomSeed(int(resp.get("rand_seed")));

          String local_id = resp.get("you_are");
          String[] player_ids = resp.get("all_players").split(",",0);
          int turn = int(resp.get("turn"));
          setup_game(local_id, player_ids, turn);

          // go into the game menu; currently starts with a welcome menu followed by choosing your first job
          switcher.switch_menu(new AlertMenu(connected_text, holo_color, switcher.create_button_handler(job_menu)));
          break;

        // TELL THE CLIENT CARDS HAVE BEEN PLAYED 
        case "card_play":
          play_cards(resp);
          clear_play_positions();
          // increment the turn count
          gp_sender.inc_turn();
          break;
        
      }

    }

  }else{ // if !con.is_connected();

    switcher.switch_menu(connecting_menu);
    con.connect(server_ip);

  }

  // RENDER 
  bg.draw();
  switcher.draw();

}



// OTHER FUNCTIONS

/**
Returns what to call the given player in text
*/
// TODO: REALLY Should probably be rolled into the PlayerUI class
// TODO:    ... the problem with that is that it is always getting ref's from players, not PlayerUI's
String player_name(String player_id){
  return player_id.equals(local_player.get_id()) ? "You" : player_id;
}


/**
Initializes the local player
And adds them to the list of players
*/
void setup_local_player(String local_id, Deck deck, Hand job_hand){
  LocalPlayer lp = new LocalPlayer(deck, job_hand);
  players.put(local_id, lp);
  local_player = new LocalPlayerUI(local_id, lp);
}

/**
Initializes all players who are not the local player
and adds them the list of players
*/
void setup_opponents(String local_id, String[] player_ids){
  ArrayList<PlayerUI> new_opponents = new ArrayList<PlayerUI>();
  
  for(int i = 0; i < player_ids.length; i++){
    if(!player_ids[i].equals(local_id)){
      Player player = new Player();
      players.put(player_ids[i], player);
      new_opponents.add(new PlayerUI(player_ids[i], player));
    }
  }

  this.opponents = new PlayerUI[0];
  this.opponents = new_opponents.toArray(this.opponents);
}

/**
Initializes everything that must be setup for a new game
*/
void setup_game(String local_id, String[] player_ids, int turn){

  // setup the players
  players = new HashMap<String, Player>();
  setup_local_player(local_id, test_deck, test_job_hand);
  setup_opponents(local_id, player_ids);

  // setup the gm
  // give players in order id's recieved, so turn order matches up
  Player[] ps = new Player[player_ids.length];
  for(int i = 0; i < player_ids.length; i++){
    ps[i] = players.get(player_ids[i]);
  }
  gm = new GameManager(ps);
  
  // start the game
  gm.start_game();
  print_active_players();

  // gameplay connection
  gp_sender = new GameplaySender(con, local_id, opponents, turn);
  
  // create the main menu
  main_menu = new MainMenu(
    opponents,
    local_player,
    local_player.get_local_player().get_hand(),
    switcher,
    new ButtonHandler(){
      public void on_click(){
        gp_sender.on_click();
        switcher.switch_menu(new AlertMenu(lockin_text, holo_color, null));
      }
    },
    holo_color
  );
  
  // create the jobs menu
  job_menu = new JobMenu(
    local_player.get_local_player().get_job_hand(),
    local_player.get_player(),
    job_position,
    new ButtonHandler() { // when_done
      public void on_click(){
        switcher.switch_menu(new AlertMenu(lockin_text, holo_color, null));
        gp_sender.send_job_message(true);
      }
    },
    new ButtonHandler() { // when_do_nothing
      public void on_click(){
        gp_sender.send_basic_message(true);
      }
    },
    holo_color
  );
}


/**
Resolves all maneuver card plays encoded in the given message
Returns a text representation of the outcome of those plays
*/
String play_maneuver_cards(Message resp){

  String alert = "";
  HashMap<CardPlay, String> card_plays_text = new HashMap<CardPlay, String>();

  ArrayList<CardPlay> card_plays = new ArrayList<CardPlay>();

  // PARSE PLAYING MANEUVERS AS DEFENSE
  for(String id : players.keySet()){
    String card_id = resp.get(id + "_defense");
    if(card_id != null){
      Card c = cl.load_card(card_id);
      CardPlay cp = new DefenseCardPlay(players.get(id), c);
      card_plays.add(cp);
      card_plays_text.put(cp, player_name(id) + " defended with " + c.get_id() + ".\n");
    }
  }

  // PARSE PLAYING MANEUVERS AGAINST OTHER PLAYERS
  // TODO: parsing should probably get rolled in with gp_sender
  for(String k : resp.regex_get_keys(".*_to_.*")){
    // get the player ids for who played the card on who
    String[] ids = k.split("_to_",0);
    // get the card played
    Card c = cl.load_card(resp.get(k));
    // actually play the card
    CardPlay cp = new PlayAgainstCardPlay(players.get(ids[0]), players.get(ids[1]), c);
    card_plays.add(cp);
    // tell the player what happened
    card_plays_text.put(cp, player_name(ids[0]) + " played " + c.get_id() + " against " + player_name(ids[1]) + ".\n");
  }

  // RESOLVE CARD PLAYS
  HashSet<Player> failed_players = gm.play_cards(card_plays);

  // UI STUFF
  // add the outcome to the alert
  for(String id : players.keySet()){
    if(failed_players.contains(players.get(id))){
      alert += player_name(id) + " assigned too many agents and failed.\n";
    }
  }

  for(CardPlay cp : card_plays){
    if(!cp.is_failed()){
      alert += card_plays_text.get(cp) + "(" + cp.get_resault().toString() + ")\n";
    }
  }

  return alert;
}

/**
Resolves all job cards played or continued in the given message
Returns a text representation of the outcome
*/
// TODO: Fork out the UI stuff and message parsing from here
// TODO: May error is not all players have continue statements....
String play_job_cards(Message resp){

  String alert = "";

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
        players.get(id).played_from_job_hand(card);
        alert += player_name(id) + " began the job " + players.get(id).get_job().get_id() + ".\n";
      }
    }
  }

  return alert;

}

/**
Printing all player's currently active
*/
void print_active_players(){
  for(String id : players.keySet()){ // TODO: currently doing all options for testing
    if(players.get(id).is_active()){
      print("Starting "+id+"'s turn!\n");
    }
  }
}

/**
Handles the start of each turn
*/
void start_turn(){
  gm.start_turn();
  print_active_players();
  main_menu.start_turn();
}

/**
Handles messages for playing cards
Switches to a menu explaining the resaults of the card plays
*/ 
// TODO: Probably shouldn't change menu
void play_cards(Message resp){

  String maneuver_alert = play_maneuver_cards(resp);
  String job_alert = play_job_cards(resp);

  // leave any current menu
  Menu next_menu = main_menu;

  // Hand the start of a new round
  // TODO: this "if" is SO hacky; it will be better once we have any conception of UI vs. Message parsing vs. Gameplay handling
  if(job_alert.equals("")){
    start_turn();
    next_menu = job_menu;
  }

  // alert the user to what happened
  // TODO: this can preserve a menu that shouldn't be preverved sometimes
  // TODO:      .... WHEN?
  // NOTE: This (weirdly) is where only getting a job menu on your turn is implemented
  String alert = maneuver_alert + job_alert;
  switcher.switch_menu(new AlertMenu(
    (alert).equals("") ? nothing_happened_text : alert, 
    holo_color,
    switcher.create_button_handler(next_menu)
  ));

}

/**
Clears all cards from all card positions
*/
void clear_play_positions(){
  // TODO: doing this exhaustively is annoying
  for(PlayerUI o : opponents){
    o.get_played_against().clear();
  }
  local_player.get_played_against().clear();
  job_position.clear();
}
