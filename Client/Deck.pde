import java.util.ArrayList;

/**
A class to represent a randomized deck of cards
*/
class Deck {

    private ArrayList<Card> cards;

    Deck(){
        cards = new ArrayList<Card>();
    }

    /**
    Adds the given number of copies of the given card to the deck
    */
    void add_card(Card c, int copies){
        for(int i = 0; i < copies; i++){
            cards.add(c);
        }
    }

    /**
    Randomizes the order of cards in the deck
    */
    void shuffle(){
        for(int i = 0; i < cards.size(); i++){
            int j = (int)random(i, cards.size());
            Card swap = cards.get(i);
            cards.set(i, cards.get(j));
            cards.set(j, swap);
        }
    }

    /**
    Draws the top card off the deck
    Returns the card and removes it from the deck
    */
    Card draw_card(){
        if(cards.size() > 0){
            Card r = cards.get(cards.size()-1);
            cards.remove(cards.size()-1);
            return r;
        }
        return null;
    }

}