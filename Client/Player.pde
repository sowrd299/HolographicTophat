import java.util.HashMap;

/**
Represents the outcome of a player playing a card
*/
class CardPlayResault{

    public int progress;
    public int damage_to_def;
    public int defense_stealth_used;
    public int damage_to_player;

    CardPlayResault(int progress, int damage_to_def, int defense_stealth_used, int damage_to_player){
        this.progress = progress;
        this.damage_to_def = damage_to_def;
        this.defense_stealth_used = defense_stealth_used;
        this.damage_to_player = damage_to_player;
    }

    CardPlayResault(){
        this(0,0,0,0);
    }

    String toString(){
        String r = "";

        if(progress != 0){
            r += " " + progress + " progress.";
        }
        if(damage_to_def != 0){
            r += " " + damage_to_def + " damage dealt.";
        }else if(defense_stealth_used != 0){
            r += " " + defense_stealth_used + " damage avoided.";
        }
        if(damage_to_player != 0){
            r += " " + damage_to_player + " damage dealt back.";
        }

        if(r.equals("")){
            r = " no effect.";
        }

        return r;
    }

}

/**
A class to represent a player's current gamestate
Implements game logic
*/
class Player{

    static STARTING_CARDS = 6;
    static CARDS_PER_TURN = 2;

    private int progress; // the player's current progress on their current job
    private int score; // the player's current score
    private int hand_size; // tracks the number of cards in this player's hand

    private Card boss; // the player's "boss" identity card
    private HashMap<String, Integer> available_agents;

    private Card defense; // the card the player is currently playing as their defense
    private Card job; // the job the player is currently on

    private int defense_stealth; // the amount of stealth the player has left on their current defense card

    private boolean active; // if the player is "active" this turn

    Player(){
        progress = 0;
        score = 0;
        hand_size = 0;
        boss = new BossCard("Agent of the Houses"); // testing boss card
        active = true;
        reset_agents();
        clear_defense();
    }

    int get_progress(){
        return progress;
    }

    int get_score(){
        return score;
    }

    int get_hand_size(){
        return hand_size;
    }

    Card get_job(){
        return job;
    }

    Card get_boss(){
        return boss;
    }

    HashMap<String, Integer> get_available_agents(){
        return available_agents;
    }

    boolean is_active(){
        return active;
    }


    // HAND MANAGEMENT

    /**
    Adds cards to the player's hand
    Takes the number of cards drawn
    */
    void draw_cards(int num){
        hand_size += num;
    }

    /**
    Manages a card leaves the player's hand
    Takes the card played
    */
    void played_from_hand(Card c){
        hand_size -= 1;
    }

    // REGULAR UPKEEP

    /**
    To be called at the start of the game
    */
    void start_game(){
        draw_cards(STARTING_CARDS);
    }


    /**
    To be called at the end of every turn
    Takes if the player is the active player on this turn that is starting
    */
    void start_turn(boolean active_this_turn){
        if(active_this_turn){
            draw_cards(CARDS_PER_TURN);
            reset_agents();
        }
        active = active_this_turn;
    }

    // PLAYING MANEUVERS

    /**
    Manages what happens when a card is played against a player
    */
    CardPlayResault play_card_against(Player played_by, Card c){

        CardPlayResault r = new CardPlayResault();

        // decrement progress
        int progress = -1 * c.get_stat(STAT_CUNNING);
        this.progress += progress;
        r.progress = progress;
        // deal damage to defender
        if(c.get_stat(STAT_FORCE) > defense_stealth){
            r.damage_to_def = take_damage(c.get_stat(STAT_FORCE) - defense_stealth);
            r.defense_stealth_used = defense_stealth;
            defense_stealth = 0;
        }else{
            int defense_stealth_used = c.get_stat(STAT_FORCE);
            defense_stealth -= defense_stealth_used;
            r.defense_stealth_used = defense_stealth_used;
        }
        // deal damage to attacker
        played_by.take_damage(defense.get_stat(STAT_FORCE) - c.get_stat(STAT_STEALTH));

        return r;
    }

    /**
    Manages damage being dealt to this player
    Damage cannot result in gaining score
    Damage cannot result in having negative score
    Return the damage dealt
    */
    private int take_damage(int val){
        int damage = max(0, val);
        score -= damage;
        score = max(score, 0);
        return damage;
    }

    // DEFENDING WITH MANEUVERS

    /**
    Manage what happens when a player sets a new defense
    */
    CardPlayResault play_defense(Card c){
        defense = c;
        defense_stealth = defense.get_stat(STAT_STEALTH);
        int progress = defense.get_stat(STAT_CUNNING);
        this.progress += progress;
        return new CardPlayResault(progress,0,0,0);
    }

    /**
    To be called after a card's defense seases to be relivant
    */
    void clear_defense(){
        play_defense(new ManeuverCard("The-No-Card-Here-Card",0,0,0));
    }

    // MANAGING THE AGENT COST OF MANEUVERS

    /**
    Returns all the agents the player will ever have available
    */
    HashMap<String, Integer> get_max_agents_available(){

        HashMap<String, Integer> available = new HashMap<String, Integer>(); // agent type : number still available

        Stat boss_agents = boss.get_stat_object(STAT_AGENTS);
        available.put(AGENT_ALL_PURPOSE, 0); // ensure always have this fields
        for(String agent_type: boss_agents.get_stats()) {
            available.put(agent_type, boss_agents.get_stat(agent_type).get());
        }

        return available;

    }

    void reset_agents(){
        available_agents = get_max_agents_available();
    }

    /**
    By default, will used stored agents available
    */
    boolean are_legal_plays(Card[] played){
        return are_legal_plays(played, available_agents);
    }

    /**
    Returns if the given cards are a legal play, given the available agents
    Takes all cards played by the player in a given round
    Take the remaining agents available; will mutate this map as those agents are assigned
    */
    // TODO: make this algorithm implementation more reusable
    boolean are_legal_plays(Card[] played, HashMap<String, Integer> available ) {

        // use agents
        for(Card c : played) {
            Stat agents = c.get_stat_object(STAT_AGENTS);
            for(String agent_type : agents.get_stats()) {

                String assigned_agent_type = agent_type;

                if(!available.containsKey(agent_type)){
                    // if we know we don't have any agents of a type b/c it's not even in the map,
                    //      just asign all purpose agents from the get-go
                    assigned_agent_type = AGENT_ALL_PURPOSE; 
                }

                available.put(assigned_agent_type, available.get(assigned_agent_type) - agents.get_stat(agent_type).get());
            }
        }

        // assign extra agents to all purpose
        for(String k : available.keySet()){
            if(k != AGENT_ALL_PURPOSE && available.get(k) < 0){
                available.put(AGENT_ALL_PURPOSE, available.get(AGENT_ALL_PURPOSE) + available.get(k));
            }
        }

        System.out.println("Calculated agent assignment totals: "+available);

        // because of the last step, if we have enough all purpse agents, we have enough agents
        return available.get(AGENT_ALL_PURPOSE) >= 0;

    }

    // PLAYING JOBS

    /**
    Sets the player's job to the given card
    */
    void play_job(Card job){
        this.job = job;
        progress += job.get_stat(STAT_CUNNING);
    }

    /**
    Handles the play continuing their current job
    */
    void continue_job(){
        progress += job.get_stat(STAT_PATIENCE);
    }

    /**
    Returns if the current job will succeed if it is finished at this moment
    */
    boolean will_complete_job(){
        return job == null || progress >= 0;
    }

    /**
    Handles the end of a job
    returns wether or not that job succeeded
    */
    boolean finish_job(){
        boolean success = false;
        if(will_complete_job() && job != null) {
            score += job.get_stat(STAT_REWARD);
            success = true;
        }
        progress = 0;
        return success;
    }

}

/**
Adds in code for handling hidden gamestates of that player
*/
class LocalPlayer extends Player {

    private Hand hand;
    private Deck deck;

    LocalPlayer(Deck deck){
        super();
        hand = new Hand();
        this.deck = deck;
    }

    Hand get_hand(){
        return hand;
    }

    Deck get_deck(){
        return deck;
    }

    void start_game(){
        deck.shuffle();
        super.start_game();
    }

    void played_from_hand(Card c){
        super.played_from_hand(c);
        hand.remove_card(c);
    }

    void draw_cards(int num){
        super.draw_cards(num);
        for(int i = 0; i < num; i++){
            Card c = deck.draw_card();
            if(c != null){
                hand.add_card(c);
            }
        }
    }
    
}