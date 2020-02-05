/**
Represents a player in the game
For use organizing data for the UI
*/
class PlayerUI{

    private String id;
    private PlayPosition played_against; // the card played against this player
    private Player player;

    PlayerUI(String id, Player player){
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
A class to render the player as a button
*/
class PlayerUIButton extends CompositButton{
    
    PlayerUI opponent;

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
            r += " | Hand: " + Integer.toString(opponent.get_player().get_hand_size());
            return r;
        }

    }

    protected MainButton main_button;
    protected CardButton job_button;
    protected CardButton played_against_button;
    protected ScoreButton score_button;

    PlayerUIButton(PlayerUI opponent, Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(rect, "", c, handler);
        this.opponent = opponent;

        // set up the buttons
        main_button = new MainButton(rect.get_section(0,0,0.5,0.2), c, null, stroke_weight, corner_size);
        job_button = new JobCardButton(opponent.get_player().get_job(), rect.get_section(0,0.2,1,0.3), c, null, stroke_weight, corner_size);
        played_against_button =new ManeuverCardButton(opponent.get_played_against().get(), rect.get_section(0,0.5,1,0.3), c, null, stroke_weight, corner_size);
        score_button = new ScoreButton(rect.get_section(0.1,0.64,0.8,0.2), c, null, stroke_weight, corner_size);
    }

    Button[] get_buttons(){
        return new Button[]{ score_button, job_button, played_against_button, main_button };
    }

}