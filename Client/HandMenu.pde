/**
A menu for showing all the cards in a hand
*/
class HandMenu extends Menu{

    Hand hand; // the hand to be displayed
    ButtonHandler when_finished; // what to do after a card has been selected

    // display variables
    int x = 32,y = 32;
    int button_h = 124;
    int button_w = width-64;
    int y_padding = 16;

    // menu items
    Button[] card_buttons;

    PlayPosition position;

    HandMenu(Hand hand, PlayPosition position, ButtonHandler when_finished, color holo_color){
        super(null, holo_color);
        this.hand = hand;
        this.position = position;
        this.when_finished = when_finished;
    }

    void init(){

        boolean keep_option = position.get() != null; // if there is a card to have the option to keep

        Card[] cards = hand.get_cards(); 
        card_buttons = new Button[cards.length + (keep_option? 2 : 1)];
        Rect[] rects = create_rects(x,y,button_w,button_h,0,y_padding,card_buttons.length,1);

        int i;
        for(i = 0; i < cards.length; i++){
            card_buttons[i] = new TicketButton(
                rects[i],
                cards[i].get_id(),
                holo_color,
                new CardButtonHandler(cards[i], position, when_finished),
                5, 32
            );

        }

        // the keep button
        if(keep_option) {
            card_buttons[i] = new TicketButton(
                rects[i],
                "<"+position.get().get_id()+">",
                holo_color,
                when_finished,
                5, 32
            );
            i++;
        }

        // the none button
        card_buttons[i] = new TicketButton(
            rects[i].get_section(0.5,0,0.5,1),
            "None",
            holo_color,
            new CardButtonHandler(null, position, when_finished),
            5, 32
        );

    }

    Button[] get_buttons(){
        return card_buttons;
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
  
}
