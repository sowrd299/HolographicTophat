import java.util.HashMap;

/**
A class to represent a player's current gamestate
Implements game logic
*/
class Player{

    private int progress; // the player's current progress on their current job
    private int score; // the player's current score
    private int hand_size; // tracks the number of cards in this player's hand

    private Card boss; // the player's "boss" identity card

    private Card defense; // the card the player is currently playing as their defense
    private Card job; // the job the player is currently on

    Player(){
        progress = 0;
        score = 0;
        hand_size = 0;
        boss = new BossCard("Agent of the Houses"); // testing boss card
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

    // PLAYING MANEUVERS

    /**
    Manages what happens when a card is played against a player
    */
    void play_card_against(Player played_by, Card c){
        // decrement progress
        progress -= c.get_stat(STAT_CUNNING);
        // deal damage
        take_damage(c.get_stat(STAT_FORCE) - defense.get_stat(STAT_STEALTH));
        played_by.take_damage(defense.get_stat(STAT_FORCE) - c.get_stat(STAT_STEALTH));
    }

    /**
    Manages damage being dealt to this player
    Damage cannot result in gaining score
    Damage cannot result in having negative score
    */
    private void take_damage(int val){
        score -= max(0, val);
        score = max(score, 0);
    }

    // DEFENDING WITH MANEUVERS

    /**
    Manage what happens when a player sets a new defense
    */
    void play_defense(Card c){
        defense = c;
        progress += defense.get_stat(STAT_CUNNING);
    }

    /**
    To be called after a card's defense seases to be relivant
    */
    void clear_defense(){
        defense = new ManeuverCard("The-No-Card-Here-Card",0,0,0);
    }

    // MANAGING THE AGENT COST OF MANEUVERS

    /**
    Returns if the given cards are a legal play, given the available agents
    Takes all cards played by the player in a given round
    */
    // TODO: make this algorithm implementation more reusable
    boolean are_legal_plays(Card[] played) {

        HashMap<String, Integer> available = new HashMap<String, Integer>(); // agent type : number still available

        // get the agents available
        Stat boss_agents = boss.get_stat_object(STAT_AGENTS);
        available.put(AGENT_ALL_PURPOSE, 0); // ensure always have this fields
        for(String agent_type: boss_agents.get_stats()) {
            available.put(agent_type, boss_agents.get_stat(agent_type).get());
        }

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

    void draw_cards(int num){
        super.draw_cards(num);
        for(int i = 0; i < num; i++){
            Card c = deck.draw_card();
            hand.add_card(c);
        }
    }
    
}