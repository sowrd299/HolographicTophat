import java.util.HashMap;

// the names of the stats
final String STAT_CUNNING = "cunning";
final String STAT_FORCE = "force";
final String STAT_STEALTH = "stealth";

final String STAT_REWARD = "reward";
final String STAT_PATIENCE = "patience";

final String STAT_AGENTS = "agents";

/**
A class to represent a value on a card
A stat can be comprised on mutliple sub-values
*/
class Stat {

    int value;
    private HashMap<String, Stat> components;

    Stat(int value){
        this.value = value;
    }

    /**
    Returns the total of all components, including the current node
    */
    int get(){
        int r = value;
        for(String k : components.keySet()){
           r += components[k].get();
        }
        return r;
    }

    /**
    Returns an array of all the name of components
    */
    String[] get_components(){
        String[] r = new String[components.size()];
        components.keySet().toArray(r);
        return r;
    }

    Stat get_component(String stat){
        if(components.containsKey(stat)){
            return this.components.get(stat);
        }else{
            return new Stat(0);
        }
    }

}

/**
A class for representing an in-game card
*/
class Card {

    private String id;
    protected HashMap<String, Stat> stats; // the stats of the card

    Card(String id){
        this.id = id;
        stats = new HashMap<String, Integer>();
        list_stats = new HashMap<String, HashMap<String, Integer>>();
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

    HashMap<String, Integer> get_list_stat(String stat){
        return list_stats.get(stat);
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