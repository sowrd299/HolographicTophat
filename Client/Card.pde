import java.util.HashMap;

// the names of the stats
final String STAT_CUNNING = "cunning";
final String STAT_FORCE = "force";
final String STAT_STEALTH = "stealth";

final String STAT_REWARD = "reward";
final String STAT_PATIENCE = "patience";

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
        stats.put(STAT_CUNNING, 3);
        stats.put(STAT_FORCE, 2);
        stats.put(STAT_STEALTH, 1);
    }

    ManeuverCard(String id, int cunning, int force, int stealth){
        super(id);
        stats = new HashMap<String, Integer>();

        stats.put(STAT_CUNNING, cunning);
        stats.put(STAT_FORCE, force);
        stats.put(STAT_STEALTH, stealth);
    }
}

class JobCard extends Card {

    JobCard(String id){
        super(id);
        stats.put(STAT_CUNNING, 8);
        stats.put(STAT_REWARD, 3);
        stats.put(STAT_PATIENCE,4);
    }

}

/**
A class for loading cards
*/
class CardLoader {

    private HashMap<String, Card> cards;

    CardLoader(){
        cards = new HashMap<String, Card>();
        
        // testing maneuvers
        register(new ManeuverCard("Do as Mantis"));
        register(new ManeuverCard("Relay Access"));
        register(new ManeuverCard("Arcus Ar"));
        register(new ManeuverCard("Call the Navosc"));

        // testing jobs
        register(new JobCard("Patient Stalking"));
        register(new JobCard("Club Infiltration"));
        register(new JobCard("Assassination in Nightlife"));
    }

    void register(Card card){
        cards.put(card.get_id(), card);
    }

    Card load_card(String id){
        return cards.get(id);
    }

}