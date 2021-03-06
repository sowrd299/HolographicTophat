import java.util.get_h()ashMap;

// the names of the stats
final String STAT_AGENTS = "agents";

final String STAT_CUNNING = "CUN";
final String STAT_FORCE = "FRC";
final String STAT_STEALTH = "STL";

final String STAT_REWARD = "RWD";
final String STAT_PATIENCE = "PTN";

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

    Stat get_subset(String[] stats){
        Stat r = new SortedStat(stats);
        for(String s : stats){
            r.set_stat(s, get_stat(s));
        }
        return r;
    }

    void set_stat(String stat, int val){
        components.put(stat, new Stat(val));
    }

    void set_stat(String stat, Stat s){
        components.put(stat, s);
    }

}

/**
A subclass of stat that keeps its component is a specific order
*/
class SortedStat extends Stat{

    private String[] order;

    SortedStat(String[] order){
        super();
        this.order = order;
    }

    /**
    May return stats that in  fact don't exist
    */
    // TODO: change that
    String[] get_stats(){
        return order;
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

    Stat get_stat_subset(String[] stats){
        return this.stats.get_subset(stats);
    }
  
}

class ManeuverCard extends Card {

    ManeuverCard(String id, int cunning, int force, int stealth, String agent_type, int agent_val){
        super(id);

        stats.set_stat(STAT_CUNNING, cunning);
        stats.set_stat(STAT_FORCE, force);
        stats.set_stat(STAT_STEALTH, stealth);

        // placeholder team of agents
        Stat agents = new Stat();
        agents.set_stat(agent_type, agent_val);
        stats.set_stat(STAT_AGENTS, agents);
    }

    ManeuverCard(String id){
        this(id, 3, 2, 1, "Sailor", 2);
    }

    ManeuverCard(String id, int cunning, int force, int stealth){
        this(id, cunning, force, stealth, "Goon", 0);
    }

}

class JobCard extends Card {

    JobCard(String id, int cunning, int patience, int reward){
        super(id);

        stats.set_stat(STAT_CUNNING, cunning);
        stats.set_stat(STAT_PATIENCE, patience);
        stats.set_stat(STAT_REWARD, reward);
    }

    JobCard(String id){
        this(id, 8, 5, 3);
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
        register(new ManeuverCard("Do as Mantis",           3,0,0, "Seducer",2));

        register(new ManeuverCard("Relay Access",           0,0,3, "Hacker",2));
        register(new ManeuverCard("Tampering Ghast",        2,0,1, "Hacker",2));

        register(new ManeuverCard("Heavy Fire",             0,3,0, "Sailor",3));
        register(new ManeuverCard("Dogfight",               0,2,0, "Sailor",2));
        register(new ManeuverCard("Turret Fire",            0,1,0, "Sailor",1));
        register(new ManeuverCard("Dreadfleat's Aid",       4,2,0, "Sailor",4));
        register(new ManeuverCard("The Arcus 2's Aid",      2,1,0, "Sailor",2));
        register(new ManeuverCard("Embargo",                4,0,0, "Sailor",3)); // slightly under powered
        register(new ManeuverCard("Boarding",               2,0,0, "Sailor",1));
        register(new ManeuverCard("Supressive Fire",        0,1,2, "Sailor",2));

        register(new ManeuverCard("Raw Muscle",             3,0,0, "Goon",2));
        register(new ManeuverCard("Alert DJNF",             1,1,0, "Goon",0));

        // testing jobs
        register(new JobCard("Patient Stalking",            3,6,5));
        register(new JobCard("Rocketeering",                5,4,7));
        register(new JobCard("Club Infiltration",           4,4,9));
        register(new JobCard("Assassination in Nightlife",  2,2,12));
    }

    void register(Card card){
        cards.put(card.get_id(), card);
    }

    Card load_card(String id){
        return cards.get(id);
    }

}