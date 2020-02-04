/**
A menu for showing all the cards in a hand
*/
class HandMenu extends Menu{

    Hand hand; // the hand to be displayed
    ButtonHandler when_finished; // what to do after a card has been selected

    // display variables
    int x, y;
    int button_w;
    int button_h;
    int y_padding;

    // menu items
    Button bg_button;
    Button[] card_buttons;

    PlayPosition position;

    HandMenu(Hand hand, PlayPosition position, ButtonHandler when_finished, color holo_color){
        super(null, holo_color);
        this.hand = hand;
        this.position = position;
        this.when_finished = when_finished;
        x = r.x + margin;
        y = r.y + margin;
        button_w = r.w - 2*margin;
        button_h = r.h/12;
        y_padding = margin/3;
    }

    void init(){

        boolean keep_option = position.get() != null; // if there is a card to have the option to keep

        Card[] cards = hand.get_cards(); 
        card_buttons = new Button[cards.length + (keep_option? 2 : 1)];
        Rect[] rects = create_rects(x,y,button_w,button_h,0,y_padding,card_buttons.length,1);

        int i;
        for(i = 0; i < cards.length; i++){
            card_buttons[i] = new ManeuverCardButton(
                cards[i],
                rects[i],
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

        // the background button
        bg_button = new BackgroundButton(
            create_bounding_rect(rects, margin, margin, margin, margin),
            "",
            holo_color,
            null,
            0, 5, margin, margin/2
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
  
}
