/**
A class for displaying cards
If asked to display a null card, will display a dark blank button
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
            super(r, "", c, null);
            font = loadFont("OldeEnglish-Regular-48.vlw");
            this.stat = stat;
            this.label_button = new Button(r.get_section(0,0.66,1,0.33), label, c, null);
        }

        String get_label(){
            return str(stat.get());
        }
        
        Button[] get_buttons(){
            return new Button[]{
                label_button
            };
        }

    }

    protected MainButton main_button;
    protected TitleButton title_button;
    protected StatButton[] stat_buttons;
    protected Button copies_button;

    CardButton(Card card, int copies, Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(rect, "", c, handler);
        this.card = card;

        if(card != null){
            // setup main button
            main_button = new MainButton(rect, c, stroke_weight, corner_size);
            // setup stat buttons
            // TODO: make this less redundent maybe?
            Stat left_stats = get_left_stats();
            String[] left_stat_names = left_stats.get_stats();
            Stat right_stats = get_right_stats();
            String[] right_stat_names = right_stats.get_stats();

            Rect base_left_rect = rect.get_section(0.05, 0.05, 0.1, 0.7);
            Rect[] left_rects = create_rects(base_left_rect, margin, margin, 1, left_stat_names.length);

            Rect base_right_rect = rect.get_section(0.85, 0.05, 0.1, 0.7);
            Rect[] right_rects = create_rects(base_right_rect, 2*(-base_right_rect.w), margin, 1, right_stat_names.length);

            stat_buttons = new StatButton[left_rects.length + right_rects.length];

            for(int i = 0; i < left_rects.length; i++){
                stat_buttons[i] = new StatButton(left_rects[i], left_stat_names[i], left_stats.get_stat(left_stat_names[i]), c);
            }

            for(int i = 0; i < right_rects.length; i++){
                stat_buttons[i+left_rects.length] = new StatButton(right_rects[i], right_stat_names[i], right_stats.get_stat(right_stat_names[i]), c);
            }

            // set title button in intervening space
            Rect inner_left_rect = left_rects.length > 0 ? left_rects[left_rects.length-1] : r.get_section(0.1,0.1,0,0.8);
            Rect inner_right_rect = right_rects.length > 0 ? right_rects[right_rects.length-1] : r.get_section(0.9,0.1,0,0.8);
            title_button = new TitleButton(
                new Rect( inner_left_rect.x + inner_left_rect.w,  inner_left_rect.y, inner_right_rect.x - inner_left_rect.x - inner_left_rect.w, r.h/3),
                c
            );

            // setup the copies button
            copies_button = new TicketButton(rect.get_section(0.85,0.8,0.15,0.3), "x" + copies, c, null, stroke_weight, corner_size/3);

        }else{
            main_button = new MainButton(rect, this.c, stroke_weight, corner_size);
        }
    }

    CardButton(Card card, Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        this(card, 1, rect, c, handler, stroke_weight, corner_size);
    }

    Button[] get_buttons(){
        if(card != null){
            Button[] r = new Button[3 + stat_buttons.length];
            r[0] = main_button;
            r[1] = title_button;
            r[2] = copies_button;
            for(int i = 0; i < stat_buttons.length; i++){
                r[3+i] = stat_buttons[i];
            }
            return r;
        }else{
            return new Button[]{
                main_button
            };
        }
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


class ManeuverCardButton extends CardButton {

    ManeuverCardButton(Card card, Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(card, rect, c, handler, stroke_weight, corner_size);
    }

    ManeuverCardButton(Card card, int copies, Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(card, copies, rect, c, handler, stroke_weight, corner_size);
    }

    Stat get_left_stats(){
        return card.get_stat_object(STAT_AGENTS);
    }

    Stat get_right_stats(){
        return card.get_stat_subset(new String[]{STAT_CUNNING, STAT_FORCE, STAT_STEALTH});
    }

}

class JobCardButton extends CardButton {

    JobCardButton(Card card, Rect rect, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(card, rect, c, handler, stroke_weight, corner_size);
    }

    Stat get_left_stats(){
        return card.get_stat_subset(new String[]{STAT_CUNNING, STAT_PATIENCE});
    }

    Stat get_right_stats(){
        return card.get_stat_subset(new String[]{STAT_REWARD});
    }

}