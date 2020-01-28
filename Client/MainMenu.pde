class MainMenu extends Menu {

    private Button opponent_bg_button;
    private Button[] play_buttons; // buttons for places where the player can play buttons
    private Button send_button;
    private Opponent[] opponents;
    private ButtonHandler lockin_handler;

    MainMenu(Opponent[] opponents, MenuSwitcher menu_switcher, ButtonHandler lockin_handler, color holo_color){
        super(menu_switcher, holo_color);
        this.opponents = opponents;
        this.lockin_handler = lockin_handler;
        margin = 48;
    }

    void init() {

        // testing hand and play position
        Hand hand = new Hand();

        // setup the opponent buttons
        int title_font_size = height/36;
        play_buttons = new Button[opponents.length];
        Rect[] rects = create_rects(margin,margin+title_font_size,width-2*margin,height/7,8,8,opponents.length,1);
        
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

        opponent_bg_button = new BackgroundButton(
            create_bounding_rect(rects, margin/2, margin/2, title_font_size + margin/2, margin/2),
            ":opponent <played against>:",
            holo_color,
            null,
            title_font_size,
            5, margin, margin/2
        );

        send_button = new TicketButton(new Rect(32,height-224,width-64,124), "Lock-in Action", holo_color, lockin_handler, 5, 32);

    }

    Button[] get_buttons(){
        Button[] r = new Button[play_buttons.length+2];
        r[0] = send_button;
        r[1] = opponent_bg_button;
        for(int i = 0; i < play_buttons.length; i++){
            r[2+i] = play_buttons[i];
        }
        return r;
    }

}
