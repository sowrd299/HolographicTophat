import java.lang.Comparable;
import java.lang.Integer;
import java.util.Arrays;
import java.util.HashMap;


/**
A menu for showing all the cards in a hand
*/
class HandMenu extends Menu{

    Hand hand; // the hand to be displayed
    ButtonHandler when_finished; // what to do after a card has been selected

    // menu items
    Button bg_button;
    Button[] card_buttons;

    PlayPosition position;

    HandMenu(Hand hand, PlayPosition position, ButtonHandler when_finished, color holo_color){
        super(null, holo_color);
        this.hand = hand;
        this.position = position;
        this.when_finished = when_finished;
    }


    void init(){

        // display variables
        int x, y;
        int button_w;
        int button_h;
        int y_padding;
        x = r.x + margin;
        y = r.y + margin;

        button_w = r.w - 2*margin;
        button_h = r.h/12;
        y_padding = margin/3;

        boolean keep_option = position.get() != null; // if there is a card to have the option to keep

        // the vairious card buttons
        HashMap<Card, Integer> copies = count_card_copies(hand.get_cards());
        Card[] cards = new Card[copies.size()];
        cards = copies.keySet().toArray(cards);
        sort_cards(cards);

        card_buttons = new Button[cards.length + (keep_option? 2 : 1)];
        Rect[] rects = create_rects(x,y,button_w,button_h,0,y_padding,card_buttons.length,1);

        int i;
        for(i = 0; i < cards.length; i++){
            card_buttons[i] = new ManeuverCardButton(
                cards[i],
                copies.get(cards[i]),
                rects[i],
                holo_color,
                new CardButtonHandler(cards[i], position, when_finished),
                margin/10, 2*margin/3
            );

        }

        // the keep button
        if(keep_option) {
            card_buttons[i] = new TicketButton(
                rects[i].get_section(0.1,0.1,0.8,0.8),
                "<"+position.get().get_id()+">",
                holo_color,
                when_finished,
                margin/10, 2*margin/3
            );
            i++;
        }

        // the none button
        card_buttons[i] = new TicketButton(
            rects[i].get_section(0.6,0.1,0.3,0.8),
            "None",
            holo_color,
            new CardButtonHandler(null, position, when_finished),
            margin/10, 2*margin/3
        );

        // the background button
        bg_button = new BackgroundButton(
            create_bounding_rect(rects, margin, margin, margin, margin),
            "",
            holo_color,
            null,
            0, margin/10, margin, margin/2
        );

    }

    Button[] get_buttons(){
        Button[] r = new Button[card_buttons.length + 1];
        r[0] = bg_button;
        for(int i = 0; i < card_buttons.length; i++){
            r[i+1] = card_buttons[i];
        }
        return r;
    }

    class CardButtonHandler implements ButtonHandler{

        Card card;
        ButtonHandler when_finished;
        PlayPosition position;

        CardButtonHandler(Card card, PlayPosition position, ButtonHandler when_finished){
            this.card = card;
            this.position = position;
            this.when_finished = when_finished; 
        }

        void on_click(){
            if(position != null){
                Card prev = position.play_card(card);
                if(prev != null) {
                    hand.add_card(prev);
                }
                hand.remove_card(card);
            }
            this.when_finished.on_click();
        }

    }
  
    // CARD SORTING


}




/**
A class and method for sorting cards
Assumes all cards have atleast one agent type
*/

class SortableCard implements Comparable<SortableCard>{

    public Card card;

    private SortableCard(Card card){
        this.card = card;
    }

    int compareTo(SortableCard other){
        Stat agents = this.card.get_stat_object(STAT_AGENTS);
        Stat other_agents = other.card.get_stat_object(STAT_AGENTS);


        String[] agent_types = agents.get_stats();
        String[] other_agent_types = other_agents.get_stats();
        int name_eval = 0; // the comparison of the types of agents
        for(int i = 0; i < agent_types.length && i < other_agent_types.length; i++){
            for(int j = 0; j < agent_types[i].length() && j < other_agent_types[i].length(); j++){
                if(agent_types[i].charAt(j) < other_agent_types[i].charAt(j)){
                    name_eval = -1;
                    break;
                }
                if(agent_types[i].charAt(j) > other_agent_types[i].charAt(j)){
                    name_eval = 1;
                    break;
                }
            }
            if(name_eval != 0){
                break;
            }
        }

        if(name_eval == 0){
            return new Integer(agents.get()).compareTo(new Integer(other_agents.get()));
        }else{
            return name_eval;
        }
    }

}

void sort_cards(Card[] cards){
    // setup
    SortableCard[] sorting = new SortableCard[cards.length];
    for(int i = 0; i < cards.length; i++){
        sorting[i] = new SortableCard(cards[i]);
    }
    // sort
    Arrays.sort(sorting);
    // cleanup
    for(int i = 0; i < cards.length; i++){
        cards[i] = sorting[i].card;
    }
}


/**
Returns a map of <Card, number of copies of that card>
*/
HashMap<Card, Integer> count_card_copies(Card[] cards){

    HashMap<Card, Integer> r = new HashMap<Card, Integer>();

    for(int i = 0; i < cards.length; i++){
        r.put(cards[i], r.containsKey(cards[i])? r.get(cards[i]) + 1 : 1);
    }

    return r;

}