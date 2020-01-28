/**
A class to represent a player's current gamestate
Implements game logic
*/
class Player{

    private int progress; // the player's current progress on their current job
    private int score; // the player's current score
    private Card defense; // the card the player is currently playing as their defense

    Player(){
        progress = 0;
        score = 0;
        defense = new Card("The-No-Card-Here-Card",0,0,0);
    }

    int get_progress(){
        return progress;
    }

    int get_score(){
        return score;
    }

    /**
    Manages what happens when a card is played against a player
    */
    void play_card_against(Player played_by, Card c){
        // decrement progress
        progress -= c.get_stat("cunning");
        // deal damage
        take_damage(c.get_stat("force") - defense.get_stat("stealth"));
        played_by.take_damage(defense.get_stat("force") - c.get_stat("stealth"));
    }

    /**
    Manages damage being dealt to this player
    Damage cannot result in gaining score
    */
    private void take_damage(int val){
        score -= max(0, val);
    }

}