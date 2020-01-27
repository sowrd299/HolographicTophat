class MainMenu extends Menu {

    private Button[] play_buttons; // buttons for places where the player can play buttons
    private Button send_button;
    private Opponent[] opponents;

    MainMenu(Opponent[] opponents, MenuSwitcher menu_switcher, color holo_color){
        super(menu_switcher, holo_color);
        this.opponents = opponents;
    }

    void init() {

        // testing hand and play position
        Hand hand = new Hand();

        // setup the opponent buttons
        play_buttons = new Button[opponents.length];
        Rect[] rects = create_rects(32,32,width-64,124,8,8,opponents.length,1);
        
        for(int i = 0; i < play_buttons.length; i++){
            // the menu for playing a card against that opponent
            HandMenu hand_menu = new HandMenu(
                hand,
                opponents[i].get_played_against(),
                menu_switcher.create_button_handler(this),
                holo_color
            );
            // the buttons for each opponent
            play_buttons[i] = new OpponentButton(
                opponents[i],
                rects[i],
                holo_color,
                menu_switcher.create_button_handler(hand_menu),
                5, 32
            );
        };

        send_button = new Button(new Rect(32,height-224,width-64,124), "Lock-in Action", holo_color, null, 5, 32);

    }

    Button[] get_buttons(){
        Button[] r = new Button[play_buttons.length+1];
        r[0] = send_button;
        for(int i = 0; i < play_buttons.length; i++){
            r[1+i] = play_buttons[i];
        }
        return r;
    }

}
