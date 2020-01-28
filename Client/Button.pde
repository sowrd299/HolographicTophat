// a display class for animated dots that acknowledge a button being pressed

class AckDots {

    private Rect r;

    private int when_last_played;
    private int anim_length; // the length of the animation in milis;

    private color c;
    private int displacement; // the displacement covered by the animation
    private int margin; // the margin within the rect the animation is contained inside

    AckDots(Rect rect, int anim_length, color c, int displacement, int margin){
        this.r = rect;
        this.anim_length = anim_length;
        this.c = c;
        this.displacement = displacement;
        this.margin = margin;

        // start not animated, even at time 0;
        this.when_last_played = -(2*anim_length);
    }

    void play_anim(){
        when_last_played = millis();
    }

    void draw(){
        int time = millis() - when_last_played;
        int current_disp = 0;
        if( time < anim_length){
            current_disp = (displacement * time) /anim_length;
        }
        stroke(c);
        strokeWeight(10);
        point(r.x+margin+current_disp, r.y + r.h/2);
        point(r.x+r.w-margin-current_disp, r.y + r.h/2);
    }

}

interface ButtonHandler {
    void on_click();
}

/**
A class to represent a button the user can interact with
 */
class Button {
    
    private Rect r;

    private String label;
    private TicketBox box;
    private PFont font;
    private int margin;
    private color c;

    private AckDots dots;

    ButtonHandler handler;

    Button(Rect rect, String label, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        this.r= rect;
        this.label = label;
        this.box = new TicketBox(rect, c, stroke_weight, corner_size);
        this.font = loadFont("OldeEnglish-Regular-48.vlw");
        this.margin = 16;

        this.handler = handler;
        // create the font color
        colorMode(HSB);
        this.c = color(hue(c), saturation(c), 50);
        colorMode(RGB);

        // create the animated dots
        dots = new AckDots(rect, 500, this.c, 64, 2*margin);
    }

    String get_label(){
        return label;
    }

    void draw(){
        box.draw();
        // draw the label
        textFont(font, r.h-(2*margin));
        textAlign(CENTER);
        fill(c, 200);
        text(get_label(), r.x + r.w/2, r.y+r.h-(int)(1.5 * margin));
        // draw the dots
        dots.draw();
    }

    boolean click(int x, int y){
        if(handler != null && r.touches_point(x,y)){
            handler.on_click();
            dots.play_anim();
            return true;
        }
        return false;
    }
    
}