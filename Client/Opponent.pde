/**
Represents an other player in the game
For use organizing data for the UI
*/
class Opponent{

    private String id;
    private PlayPosition played_against; // the card played against this player
    private Player player;

    Opponent(String id, Player player){
        this.id = id;
        played_against = new PlayPosition();
        this.player = player;
    }

    String get_id(){
        return id;
    }

    PlayPosition get_played_against(){
        return played_against;
    }

    Player get_player(){
        return player;
    }
  
}

/**
A class to render the oppoent as a button
*/
class OpponentButton extends CompositButton{
    
    Opponent opponent;

    private class MainButton extends TicketButton {

        MainButton(Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
            super(rect, "", c, handler, stroke_weight, corner_size);
        }

        String get_label() {
            String r = opponent.id;
            Card c = opponent.get_played_against().get();
            if(c != null){
                r += " <" + c.get_id() + ">";
            }
            return r;
        }

    }

    private class ScoreButton extends TicketButton {

        ScoreButton(Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
            super(rect, "", c, handler, stroke_weight, corner_size);
        }

        String get_label() {
            String r = "Score: " + Integer.toString(opponent.get_player().get_score());
            r += " | Progress: " + Integer.toString(opponent.get_player().get_progress());
            return r;
        }

    }

    private MainButton main_button;
    private ScoreButton score_button;

    OpponentButton(Opponent opponent, Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(rect, "", c, handler);
        this.opponent = opponent;

        // set up the buttons
        main_button = new MainButton(rect.get_section(0,0,1,0.63), c, null, stroke_weight, corner_size);
        score_button = new ScoreButton(rect.get_section(0.1,0.64,0.66,0.33), c, null, stroke_weight, corner_size);
    }

    Button[] get_buttons(){
        return new Button[]{ score_button, main_button };
    }

}