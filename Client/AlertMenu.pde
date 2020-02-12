/**
A class for displaying alerts to the user
*/
class AlertMenu extends Menu{

    String text;
    ButtonHandler when_finished;
    Button bg;
    Button finished_button;

    AlertMenu(String text, color holo_color, ButtonHandler when_finished){
        super(null, holo_color);
        this.text = text;
        this.when_finished = when_finished;
        this.margin = r.h/120;
    }

    void init(){

        Rect area = new Rect(8, r.h/4, r.w-2*margin, r.h/2);

        bg = new BackgroundButton(area, text, holo_color, null, r.h/36, margin/3, 8*margin, 2*margin);

        finished_button = new TicketButton(
            area.get_section(0.33, 0.8, 0.33, 0.15),
            "Ja",
            holo_color,
            when_finished,
            margin/3, 2*margin
        );

    }

    Button[] get_buttons(){
        return new Button[]{bg, finished_button};
    }

}