/**
A class for representing a in-game card
*/
class Card {

    private String id;

    Card(String id){
        this.id = id;
    }

    String get_id(){
        return id;
    }
  
}

/**
A class for loading cards
*/
class CardLoader {

    Card load_card(String id){
        // placeholder implementation
        return new Card(id);
    }

}