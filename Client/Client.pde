import java.util.HashMap;
import java.util.HashSet;
import java.util.ArrayList;
import java.lang.Iterable;

// Networking variables
String server_ip = "108.88.231.121"; //"192.168.1.65"; // the ip of the server computer
Connection con;
GameplaySender gp_sender;

// graphics and UI variables
String welcome_text = ":AEH 41.06.54:\nWelcome .Agent. to:\n\nVITIUM\n\n";

StarFieldBG bg;
color holo_color;
MainMenu main_menu;
MenuSwitcher switcher;

// gameplay variables for players
// TODO: this is a bit redundent
PlayerUI[] opponents;
PlayerUI local_player;
HashMap<String,Player> players; // the players, by ID

// gameplay variables for cards
Hand hand;
Hand job_hand;
CardLoader cl;

// gameplay variables for jobs
PlayPosition job_position;

// playtesting variables
Deck test_deck;

// TOP-LEVEL CONTROL FUNCTIONS

void setup(){
  
  // setup the render
  //fullScreen();
  size(520,920);

  // connect
  con = new Connection();

  // setup the GUI
  holo_color = color(240,60,60);
  bg = new StarFieldBG();
  switcher = new MenuSwitcher();
  switcher.switch_menu(new AlertMenu(
    welcome_text+"Connecting to insterstellar coms relay...\n\n:brief:\n"+
    "This is not a glorious age. The Last Golden Age of Humanity, an era of unmatched prosperity,"+
    " has ended. Civilization is waning, governments crumbling, and the rule of crime rising. "+
    "Powerful underworld factions, known as déod·Hüs·set—the Houses, have come to power. "+
    "The once mighty Senate of Jupitov and Monarchy of Cïjang are puppets in the House's twisted games. "+
    "The poor are destitute and the wealthy are corrupt. Technology and learning exist only to advance the agendas of those in power. "+
    "Wars are fought in back alleys and secret apartments by leaders of industry and crime, and their soldiers die in gutters.\n"+
    "Thus is the world of the Eleven Systems, at the dawn of the so-called Era of the Houses.",
    holo_color, null
  ));

  // setup gameplay
  cl = new CardLoader();
  job_position = new PlayPosition();

  // testing job hand
  job_hand = new Hand();
  job_hand.add_card(cl.load_card("Patient Stalking"));
  job_hand.add_card(cl.load_card("Club Infiltration"));
  job_hand.add_card(cl.load_card("Rocketeering"));
  job_hand.add_card(cl.load_card("Assassination in Nightlife"));

  // testing deck
  test_deck = new Deck();
  test_deck.add_card(cl.load_card("Do as Mantis"),2);
  test_deck.add_card(cl.load_card("Relay Access"),2);
  test_deck.add_card(cl.load_card("The Arcus 2's Aid"),3);
  test_deck.add_card(cl.load_card("Supressive Fire"),2);
  test_deck.add_card(cl.load_card("Heavy Fire"),2);
  test_deck.add_card(cl.load_card("Turret Fire"),2);
  test_deck.add_card(cl.load_card("Boarding"),2);
  test_deck.add_card(cl.load_card("Alert DJNF"),1);

}

/**
Handle the player clicking the screen
*/
void mousePressed() {
  switcher.click(mouseX, mouseY);
}

/**
Returns what to call the given player in text
*/
// TODO: REALLY Should probably be rolled into the PlayerUI class
String player_name(String player_id){
  return player_id.equals(local_player.get_id()) ? "You" : player_id;
}

/**
Returns an up-to-date jobs menu
*/
Menu get_jobs_menu(){
  return new JobMenu(
    job_hand,
    local_player.get_player(),
    job_position,
    new ButtonHandler() {
      public void on_click(){
        switcher.switch_menu(main_menu);
        gp_sender.send_job_message(true);
      }
    },
    holo_color
  );
}

/**
switches to a new jobs menu
*/
void switch_to_jobs_menu(){
  switcher.switch_menu(get_jobs_menu());
}


/**
Fails all cards plays in the given array that the player's can't afford
Returns players whose plays failed
*/
HashSet<Player> check_agent_costs(Iterable<CardPlay> card_plays){

  // sort the plays by player
  HashMap<Player,ArrayList<CardPlay>> cp_by_player = new HashMap<Player,ArrayList<CardPlay>>();
  for(CardPlay cp : card_plays){
    if(!cp_by_player.containsKey(cp.get_player())){
      cp_by_player.put(cp.get_player(), new ArrayList<CardPlay>());
    }
    cp_by_player.get(cp.get_player()).add(cp);
  }

  // set up return 
  HashSet<Player> r = new HashSet<Player>();

  // check for each player
  for(Player player : cp_by_player.keySet()){
    // get the cards played by the player
    Card[] cards = new Card[cp_by_player.get(player).size()];
    for(int i = 0; i < cards.length; i++){
      cards[i] = cp_by_player.get(player).get(i).get_card();
    }
    // if their plays aren't legal, fail them all
    if(!player.are_legal_plays(cards)) {
      for(CardPlay cp : cp_by_player.get(player)){
        cp.fail();
      }
      // denot that they failed
      r.add(player);
    }
  }

  return r;
}


void setup_local_player(String local_id, Deck deck){
  LocalPlayer lp = new LocalPlayer(deck);
  players.put(local_id, lp);
  local_player = new PlayerUI(local_id, lp);
  hand = lp.get_hand();
}


void setup_opponents(String local_id, String[] player_ids){
  opponents = new PlayerUI[player_ids.length];
  for(int i = 0; i < player_ids.length; i++){
    Player player = new Player();
    players.put(player_ids[i], player);
    if(player_ids[i] != local_id){
      opponents[i] = new PlayerUI(player_ids[i], player);
    }
  }
}


void setup_game(String local_id, String[] player_ids, int turn){

  // setup the players
  players = new HashMap<String, Player>();
  setup_local_player(local_id, test_deck);
  setup_opponents(local_id, player_ids);

  // begin game logic
  for(String id : players.keySet()){
    players.get(id).start_game();
  }

  // gameplay connection
  gp_sender = new GameplaySender(con, local_id, opponents, turn);
  
  // go into the game menu; currently starts with a welcome menu followed by choosing your first job
  main_menu = new MainMenu(opponents, local_player, hand, switcher, gp_sender, holo_color);
  Menu jobs_menu = get_jobs_menu();
  switcher.switch_menu(new AlertMenu(
    welcome_text+"Relay located. Link secured. Foreign parties identified. Comsnet established. The game is afoot .Agent "+local_player.get_id()+".. Best of luck.",
    holo_color, switcher.create_button_handler(jobs_menu)
  ));
}


// TODO: FORK OUT THE MESSAGE PARSING AND UI STUFF FROM HERE
String play_maneuver_cards(Message resp){

  String alert = "";
  HashMap<CardPlay, String> card_plays_text = new HashMap<CardPlay, String>();

  ArrayList<CardPlay> card_plays = new ArrayList<CardPlay>();

  // HANDLE PLAYING MANEUVERS AS DEFENSE
  // for the rules to work, this must happen before playing maneuvers
  for(String id : players.keySet()){
    String card_id = resp.get(id + "_defense");
    if(card_id != null){
      Card c = cl.load_card(card_id);
      CardPlay cp = new DefenseCardPlay(players.get(id), c);
      card_plays.add(cp);
      card_plays_text.put(cp, player_name(id) + " defended with " + c.get_id() + ".\n");
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
    CardPlay cp = new PlayAgainstCardPlay(players.get(ids[0]), players.get(ids[1]), c);
    card_plays.add(cp);
    // tell the player what happened
    card_plays_text.put(cp, player_name(ids[0]) + " played " + c.get_id() + " against " + player_name(ids[1]) + ".\n");
  }

  // HANDLE AGENTS COSTS
  HashSet<Player> failed_players = check_agent_costs(card_plays);

  // RESOLVE ALL THE CARD PLAYS, STEP BY STEP
  for(String step : STEPS_CARD_PLAY){
    for(CardPlay cp : card_plays){
      cp.play(step);
    }
  }

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


// TODO: Fork out the UI stuff and message parsing from here
String play_job_cards(Message resp){

  String alert = "";

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

  return alert;

}

/**
Handles the start of each turn
*/
void start_turn(){
    for(String id : players.keySet()){
      players.get(id).start_turn();
    }
    main_menu.start_turn();
}


void play_cards(Message resp){

  String maneuver_alert = play_maneuver_cards(resp);
  String job_alert = play_job_cards(resp);

  // leave any current menu
  switcher.switch_menu(main_menu);

  // Hand the start of a new round
  // TODO: this is SO hacky; it will be better once we have any conception of UI vs. Message parsing vs. Gameplay handling
  if(job_alert.equals("")){
    start_turn();
    switch_to_jobs_menu();
  }

  // alert the user to what happened
  // TODO: this can preserve a menu that shouldn't be preverved sometimes
  // TODO:      .... WHEN?
  switcher.switch_menu(new AlertMenu(maneuver_alert + job_alert, holo_color, switcher.create_return_handler()));

  // clear all card positions
  // TODO: doing this exhaustively is annoying
  for(PlayerUI o : opponents){
    o.get_played_against().clear();
  }
  local_player.get_played_against().clear();
  job_position.clear();

  // increment the turn count
  gp_sender.inc_turn();
}


/**
THE MAIN LOOP
*/
void draw() {

  // render onto the screen
  bg.draw();
  switcher.draw();

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
          switcher.switch_menu(new AlertMenu(welcome_text+"Relay located. Link secured.\nAwaiting handshake from foreign parties...", holo_color, null));
          break;

        // SETS UP THE GAME 
        case "setup":
          String local_id = resp.get("you_are");
          String[] player_ids = resp.get("other_players").split(",",0);
          int turn = int(resp.get("turn"));
          setup_game(local_id, player_ids, turn);
          break;

        // TELL THE CLIENT CARDS HAVE BEEN PLAYED 
        case "card_play":
          play_cards(resp);
          break;
        
      }

    }

  }else{ // if !con.is_connected();

    con.connect(server_ip);

  }
}