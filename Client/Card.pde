import java.util.HashMap;

// the names of the stats
final String STAT_AGENTS = "agents";

final String STAT_CUNNING = "cunning";
final String STAT_FORCE = "force";
final String STAT_STEALTH = "stealth";

final String STAT_REWARD = "reward";
final String STAT_PATIENCE = "patience";

// the names of agents with special roles
final String AGENT_ALL_PURPOSE = "Elite";

/**
A class to represent a value on a card
A stat can be comprised on mutliple sub-values
*/
class Stat {

    int value;
    private HashMap<String, Stat> components;

    Stat(int value){
        this.value = value;
        this.components = new HashMap<String, Stat>();
    }

    Stat(){
        this(0);
    }

    /**
    Returns the total of all components, including the current node
    */
    int get(){
        int r = value;
        for(String k : components.keySet()){
           r += components.get(k).get();
        }
        return r;
    }

    /**
    Returns an array of all the name of components
    */
    String[] get_stats(){
        String[] r = new String[components.size()];
        components.keySet().toArray(r);
        return r;
    }

    Stat get_stat(String stat){
        if(components.containsKey(stat)){
            return this.components.get(stat);
        }else{
            // System.out.println("Tried to access stat "+stat+" that does not exist!");
            return new Stat(0);
        }
    }

    void set_stat(String stat, int val){
        components.put(stat, new Stat(val));
    }

    void set_stat(String stat, Stat s){
        components.put(stat, s);
    }

}

/**
A class for representing an in-game card
*/
class Card {

    private String id;
    protected Stat stats; // the stats of the card

    Card(String id){
        this.id = id;
        stats = new Stat(0);
    }

    String get_id(){
        return id;
    }

    /**
    Returns the value of the given stat
    */
    int get_stat(String stat) {
        return stats.get_stat(stat).get();
    }

    Stat get_stat_object(String stat){
        return stats.get_stat(stat);
    }
  
}

class ManeuverCard extends Card {

    ManeuverCard(String id, int cunning, int force, int stealth){
        super(id);

        stats.set_stat(STAT_CUNNING, cunning);
        stats.set_stat(STAT_FORCE, force);
        stats.set_stat(STAT_STEALTH, stealth);

        // placeholder team of agents
        Stat agents = new Stat();
        agents.set_stat("Sailor",2);
        stats.set_stat(STAT_AGENTS, agents);
    }

    ManeuverCard(String id){
        this(id, 3, 2, 1);
    }

}

class JobCard extends Card {

    JobCard(String id){
        super(id);
        stats.set_stat(STAT_CUNNING, 8);
        stats.set_stat(STAT_REWARD, 3);
        stats.set_stat(STAT_PATIENCE,4);
    }

}

class BossCard extends Card {

    BossCard(String id){
        super(id);
        Stat agents = new Stat();
        agents.set_stat("Sailor", 4);
        agents.set_stat(AGENT_ALL_PURPOSE,2);
        stats.set_stat(STAT_AGENTS, agents);
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