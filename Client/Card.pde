import java.util.HashMap;

/**
A class for representing an in-game card
*/
class Card {

    private String id;
    private HashMap<String, Integer> stats; // the stats of the card

    Card(String id){
        this.id = id;
        stats = new HashMap<String, Integer>();

        // set the default stats
        stats.put("cunning", 3);
        stats.put("force", 2);
        stats.put("stealth", 1);
    }

    Card(String id, int cunning, int force, int stealth){
        this.id = id;
        stats = new HashMap<String, Integer>();

        stats.put("cunning", cunning);
        stats.put("force", force);
        stats.put("stealth", stealth);
    }

    String get_id(){
        return id;
    }

    /**
    Returns the value of the given stat
    */
    int get_stat(String stat) {
        return stats.get(stat);
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