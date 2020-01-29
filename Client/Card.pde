import java.util.HashMap;

/**
A class for representing an in-game card
*/
class Card {

    private String id;
    protected HashMap<String, Integer> stats; // the stats of the card

    Card(String id){
        this.id = id;
        stats = new HashMap<String, Integer>();
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

class ManeuverCard extends Card {

    ManeuverCard(String id) {
        super(id);
        // set the default stats
        stats.put("cunning", 3);
        stats.put("force", 2);
        stats.put("stealth", 1);
    }

    ManeuverCard(String id, int cunning, int force, int stealth){
        super(id);
        stats = new HashMap<String, Integer>();

        stats.put("cunning", cunning);
        stats.put("force", force);
        stats.put("stealth", stealth);
    }
}

class JobCard extends Card {

    JobCard(String id){
        super(id);
        stats.put("cunning", 8);
        stats.put("reward", 3);
        stats.put("patience",4);
    }

}

/**
A class for loading cards
*/
class CardLoader {

    Card load_card(String id){
        // placeholder implementation
        return new ManeuverCard(id);
    }

}