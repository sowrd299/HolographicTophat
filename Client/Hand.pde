import java.util.ArrayList;

/**
A class for representing a hand of cards
*/
class Hand {

    private ArrayList<Card> cards;

    Hand(){
        this.cards = new ArrayList<Card>();
    }

    /**
    Lists all the card in the hand
    */
    Card[] get_cards(){
        Card[] r = new Card[cards.size()];
        return cards.toArray(r);
    }

    /**
    Removes a given card from the hand
    */
    void remove_card(Card card){
        cards.remove(card);
    }

    /**
    Adds a card to the hand
    */
    void add_card(Card card){
        cards.add(card);
    }
  
}
