/**
A class for displaying cards
*/

class CardButton extends CompositButton {

    protected Card card;

    class MainButton extends ShieldButton {

        MainButton(Rect rect, color c, int stroke_weight, int corner_size){
            super(rect, "", c, null, stroke_weight, corner_size);
        }

    }

    class TitleButton extends Button {

        TitleButton(Rect r, color c){
            super(r,"",c,null);
        }

        String get_label(){
            return card.get_id();
        }
    }

    class StatButton extends CompositButton {

        protected Stat stat;
        protected Button label_button;

        StatButton(Rect r, String label, Stat stat, color c){
            super(rect, "", c, null);
            font = loadFont("OldeEnglish-Regular-48.vlw");
            this.stat = stat;
            this.label_button = new Button(r.get_section(0,0.66,1,0.33), label, c, null);
        }

        String get_label(){
            return stat.get().toString();
        }
        
        Button[] get_buttons(){
            return new Button[]{
                label_button;
            }
        }

    }

    protected MainButton main_button;
    protected TitleButton title_button;
    protected StatButton[] stat_buttons;

    CardButton(Card card, Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(rect, "", c, handler);
        this.card = card;
        main_button = new MainButton(rect, c, stroke_weight, corner_size);

        // setup stat buttons
        Stat left_stats = get_left_stats();
        String[] left_stat_names = left_stats.get_stats();
        Stat right_stats = get_right_stats();
        String[] right_stat_names = right_stats.get_stats();

        Rect base_left_rect = rect.get_section(0.1,0.1,0.15,0.8);
        Rect[] left_rects = create_rects(base_left_rect, margin, margin, 1, left_stat_names.length);

        Rect base_right_rect = rect.get_section(0.75, 0.1, 0.15, 0.8);
        Rect[] right_rects = create_rects(base_right_rect, -margin-base_right_rect.w, margin, 1, right_stats.get_stats().length);

        stat_buttons = new StatButton[left_rects.length + right_rects.length];
        for(int i = 0; i < left_rects.length; i++){

        }

        // set title button in intervening space
        title_button = new TitleButton(rect.get_section())
    }

    Button[] get_buttons(){
        return new Button[]{
            main_button,
            title_button
        };
    }

    /**
    The stats that go on the left side
    */
    Stat get_left_stats(){
        return new Stat();
    }

    /**
    The stats that go on the right side
    */
    Stat get_right_stats(){
        return new Stat();
    }

}
