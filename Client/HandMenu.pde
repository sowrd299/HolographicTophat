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

    HandMenu(Hand hand, ButtonHandler when_finished, color holo_color){
        super(null, holo_color);
        this.hand = hand;
        this.when_finished = when_finished;
    }

    void init(){

        int x = this.x;
        int y = this.y;

        Card[] cards = hand.get_cards(); 
        card_buttons = new Button[cards.length];

        for(int i = 0; i < cards.length; i++){
            card_buttons[i] = new Button(
                new Rect(x, y, button_w, button_h),
                cards[i].get_id(),
                holo_color,
                new CardButtonHandler(cards[i], when_finished),
                5, 32
            );

            y += button_h + y_padding;
        }
    }

    Button[] get_buttons(){
        return card_buttons;
    }

    class CardButtonHandler implements ButtonHandler{

        ButtonHandler when_finished;

        CardButtonHandler(Card card, ButtonHandler when_finished){
            this.when_finished = when_finished; 
        }

        void on_click(){
            this.when_finished.on_click();
        }

    }
  
}
