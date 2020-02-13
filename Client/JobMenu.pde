class JobMenu extends Menu {

    private Hand job_hand;
    private Player player;
    private Card cont_job; // the job that can be continued
    private PlayPosition position;
    private ButtonHandler when_finished;

    private Button status_button;
    private Button bg_button;
    private Button[] job_buttons;
    private Button continue_button;

    JobMenu(Hand job_hand, Player player, PlayPosition position, ButtonHandler when_finished, color holo_color){
        super(null, holo_color);
        this.job_hand = job_hand;
        this.player = player;
        this.cont_job = player.get_job();
        this.position = position;
        this.when_finished = when_finished;
    }

    void init(){

        Rect status_rect = new Rect(r.x + margin, r.y+margin, r.w-2*margin, 2*(margin+font_size));
        status_button = new BackgroundButton(
            status_rect,
            (player.will_complete_job()? "You are ready for your next job." : "If you abandon your job now, it will fail.") + " (" + player.get_progress() + " Pogress)",
            holo_color,
            null,
            font_size,
            margin/10, margin, margin/2
        );

        Card[] cards = job_hand.get_cards();
        Rect[] rects = create_rects(r.x+margin, status_rect.y+status_rect.h+margin+font_size, r.w-2*margin, r.h/12, 0, margin/2, cards.length+1, 1);
        int i = 0;

        job_buttons = new Button[cards.length];
        for(; i < job_buttons.length; i++){
            job_buttons[i] = new JobCardButton(
                cards[i],
                rects[i],
                holo_color,
                new JobButtonHandler(cards[i]),
                margin/10, 2*margin/3
            );
        }

        rects[i] = rects[i].get_section(0,0,1,1.5);
        continue_button = new ContinueButton(rects[i]);

        bg_button = new BackgroundButton(
            create_bounding_rect(rects, margin/2, margin/2, margin/2 + font_size, margin/2),
            "Select your next job:",
            holo_color,
            null,
            font_size,
            margin/10, margin, margin/2
        );

    }

    Button[] get_buttons(){
        Button[] r = new Button[job_buttons.length + 3];
        r[0] = bg_button;
        r[1] = continue_button;
        r[2] = status_button;
        for(int i = 0; i < job_buttons.length; i++){
            r[i+3] = job_buttons[i];
        }
        return r;
    }

    class JobButtonHandler implements ButtonHandler{

        private Card card;

        JobButtonHandler(Card card){
            this.card = card;
        }

        void on_click(){
            job_hand.remove_card(card);
            position.play_card(card);
            when_finished.on_click();
        }

    }

    class ContinueButton extends CompositButton {

        private Button label_button;
        private Button card_button;

        ContinueButton(Rect r){
            super(r, "", holo_color, cont_job != null ? when_finished : null);
            label_button = new TicketButton(
                r.get_section(0.25,0,0.5,0.33),
                "Continue:",
                holo_color,
                null,
                margin/3, 3*margin
            );
            card_button = new JobCardButton(
                cont_job,
                r.get_section(0, 0.34, 1, 0.64),
                holo_color,
                null,
                margin/3, 3*margin
            );
        }

        Button[] get_buttons(){
            return new Button[]{
                label_button,
                card_button
            };
        }

    }

}