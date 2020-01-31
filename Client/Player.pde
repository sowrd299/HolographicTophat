/**
A class to represent a player's current gamestate
Implements game logic
*/
class Player{

    private int progress; // the player's current progress on their current job
    private int score; // the player's current score
    private Card defense; // the card the player is currently playing as their defense
    private Card job; // the job the player is currently on

    Player(){
        progress = 0;
        score = 0;
        clear_defense();
    }

    int get_progress(){
        return progress;
    }

    int get_score(){
        return score;
    }

    Card get_job(){
        return job;
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
    Handles the end of a job
    returns wether or not that job succeeded
    */
    boolean finish_job(){
        boolean success = false;
        if(job != null){
            if(progress >= 0){
                score += job.get_stat(STAT_REWARD);
                success = true;
            }
        }
        progress = 0;
        return success;
    }

}