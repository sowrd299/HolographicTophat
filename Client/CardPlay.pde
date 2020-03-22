/**
A family of classes that governs playing cards
*/

// the steps in which card plays happen, in order
String[] STEPS_CARD_PLAY = new String[]{
    "setup",
    "score",
    "cleanup"
};

class CardPlay {

    protected Player player;
    protected Card card;
    protected boolean failed; // weather or not playing the card has failed

    protected CardPlayResault resault;

    CardPlay(Player player, Card card){
        this.player = player;
        this.card = card;
        failed = false;
    }

    Player get_player(){
        return player;
    }

    Card get_card(){
        return card;
    }

    void play(String step) {
        switch(step) {
            case "cleanup":
                player.played_from_hand(card);
                break;
        }
    }

    // calling this will prevent the card play from having future game effects
    void fail(){
        this.failed = true;
    }

    boolean is_failed(){
        return failed;
    }

    CardPlayResault get_resault(){
        return resault;
    }

}

class PlayAgainstCardPlay extends CardPlay {

    protected Player against;

    PlayAgainstCardPlay(Player player, Player against, Card card) {
        super(player, card);
        this.against = against;
    }

    void play(String step) {
        super.play(step);
        switch(step) {
            case "score":
                if(!failed) resault = against.play_card_against(player, card);
                break;
        }
    }

}

class DefenseCardPlay extends CardPlay {

    DefenseCardPlay(Player player, Card card) {
        super(player, card);
    }

    void play(String step) {
        super.play(step);
        switch(step) {
            case "setup":
                if(!failed) resault = player.play_defense(card);
                break;
            case "cleanup":
                player.clear_defense();
                break;
        }
    }

}