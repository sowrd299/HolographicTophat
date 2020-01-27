/**
a class for representing a retangular region of the screen
 */
class Rect{

    public int x, y, w, h;

    Rect(int x, int y, int w, int h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    /**
    Returns if the rect includes a given region of the screen
     */
    boolean touches_point(int x, int y){
        return x > this.x && x < this.x + w &&
                y > this.y && y < this.y + h;
    }

}

/**
Returns an array of teslated rects created to the given speficications
*/
Rect[] create_rects(int x, int y, int w, int h, int x_padding, int y_padding, int rows, int cols){

    Rect[] r = new Rect[rows * cols];
    int x_step = w + x_padding;
    int y_step = h + y_padding;

    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            r[i*cols + j] = new Rect(x+(j*x_step),y+(i*y_step),w,h);
        }
    }

    return r;

}

/**
A class to render a fancy box
 */
class TicketBox {

    private Rect r;
    private color c;
    private int stroke_weight;
    private int corner_size;

    TicketBox(Rect rect, color c, int stroke_weight, int corner_size){
        this.r= rect;
        this.c = c;
        this.stroke_weight = stroke_weight;
        this.corner_size = corner_size;
    }

    void draw(){
        
        // set the pallet
        stroke(c, 200);
        fill(c, 150);

        // do the background rectangle
        strokeWeight(stroke_weight-1);
        rect(r.x + corner_size/2, r.y + corner_size/2, r.w - corner_size, r.h - corner_size);

        // the main box
        strokeWeight(stroke_weight);
        int x1 = r.x + corner_size;
        int x2 = r.x + r.w - corner_size;
        int x3 = r.x + r.w;
        int y1 = r.y + corner_size;
        int y2 = r.y + r.h - corner_size;
        int y3 = r.y + r.h;
        beginShape();
        vertex(x1, r.y);

        // top right corner
        vertex(x2, r.y);
        bezierVertex(x2, y1, x3, y1, x3, y1);

        // bottom right corner
        vertex(x3,y2);
        bezierVertex(x2, y2, x2, y3, x2, y3);

        // bottom left corner
        vertex(x1,y3);
        bezierVertex(x1, y2, r.x, y2, r.x, y2);

        // top left corner
        vertex(r.x,y1);
        bezierVertex(x1, y1, x1, r.y, x1, r.y);

        endShape();
    
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

    ButtonHandler handler;

    Button(Rect rect, String label, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        this.r= rect;
        this.label = label;
        this.box = new TicketBox(rect, c, stroke_weight, corner_size);
        this.font = loadFont("OldeEnglish-Regular-48.vlw");
        this.margin = 8;

        this.handler = handler;
        // create the font color
        colorMode(HSB);
        this.c = color(hue(c), saturation(c), 50);
        colorMode(RGB);
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
    }

    boolean click(int x, int y){
        if(handler != null && r.touches_point(x,y)){
            handler.on_click();
            return true;
        }
        return false;
    }
    
}