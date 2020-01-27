/**
Represents an other player in the game
*/
class Opponent{

    String id;
    PlayPosition played_against; // the card played against this player

    Opponent(String id){
        this.id = id;
        played_against = new PlayPosition();
    }

    String get_id(){
        return id;
    }

    PlayPosition get_played_against(){
        return played_against;
    }
  
}

/**
A class to render the oppoent as a button
*/
class OpponentButton extends Button{

    Opponent opponent;

    OpponentButton(Opponent opponent, Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(rect, "", c, handler, stroke_weight, corner_size);
        this.opponent = opponent;
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
