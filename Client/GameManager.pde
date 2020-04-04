/**
A class for managing game-wide game logic
*/
class GameManager{

    Player[] players;
    int turn_ind; // the index of the player whose turn it is

    GameManager(Player[] players){
        this.players = players;
        turn_ind = 0;
    }

    /*
    Handles gamelogic for the start of the game
    */
    void start_game(){
        // begin game logic
        for(int i = 0; i < players.length; i++){
            players[i].start_game();
        }

        start_turn();
    }

    /**
    Handles gamelogic for the start of each turn
    */
    void start_turn(){

        // advance the turn player
        turn_ind++;
        turn_ind %= players.length;

        for(int i = 0; i < players.length; i++){
            players[i].start_turn(i == turn_ind);
        }
    }

    Player get_turn_player(){
        return players[turn_ind];
    }


    // TODO: right now, this can actually be split into two classes at this point here

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
                // denote that they failed
                r.add(player);
            }
        }

        return r;
    }

    /**
    Resolves the effects of all the given cards being played on a turn
    Returns the players who's plays failed
    */
    HashSet<Player> play_cards(Iterable<CardPlay> card_plays){

        // HANDLE AGENTS COSTS
        HashSet<Player> failed_players = check_agent_costs(card_plays);

        // RESOLVE ALL THE CARD PLAYS, STEP BY STEP
        for(String step : STEPS_CARD_PLAY){
            for(CardPlay cp : card_plays){
                cp.play(step);
            }
        }

        return failed_players;
    }

}