/**
Represents a positions a card can be played.
A play position accepts exactly one card.
*/

class PlayPosition {

    Card card_played;

    /**
    Sets the card played against this opponent
    Returns the card previously played
    */
    Card play_card(Card card){
        Card prev = card_played;
        card_played = card;
        return prev;
    }

    void clear(){
        play_card(null);
    }

    /**
    Returns the card currently played at this position
    */
    Card get(){
        return card_played;
    }

}
