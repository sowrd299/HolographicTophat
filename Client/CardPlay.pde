/**
A family of classes that governs playing cards
*/

String[] STEPS_CARD_PLAY = new String[]{
    "setup",
    "score",
    "cleanup"
};

class CardPlay {

    protected Player player;
    protected Card card;

    CardPlay(Player player, Card card){
        this.player = player;
        this.card = card;
    }

    Player get_player(){
        return player;
    }

    void play(String step) {
        switch(step) {
            case "cleanup":
                player.played_from_hand(card);
                break;
        }
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
                against.play_card_against(player, card);
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
                player.play_defense(card);
                break;
            case "cleanup":
                player.clear_defense();
                break;
        }
    }

}