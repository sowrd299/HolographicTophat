/**
A class to render a very not fancy box
 */
class Box {

    protected Rect r;
    protected color c;
    protected int stroke_weight;
    protected int corner_size;

    Box(Rect rect, color c, int stroke_weight, int corner_size){
        this.r= rect;
        this.c = c;
        this.stroke_weight = stroke_weight;
        this.corner_size = corner_size;
    }

    void setup_draw() { 
        // set the pallet
        stroke(c, 200);
        fill(c, 150);
        strokeWeight(stroke_weight);
    }

    void draw() {
        setup_draw();
        rect(r.x,r.y,r.w,r.h);
    }

}

/**
A class to render a fancy box
 */
class TicketBox extends Box{

    TicketBox(Rect rect, color c, int stroke_weight, int corner_size){
        super(rect, c, stroke_weight, corner_size);
    }

    void draw(){

        setup_draw();

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

/**
A class that represents a less fancy, but still fancy, box
*/
class DeskBox extends Box{

    int margin;

    DeskBox(Rect rect, color c, int stroke_weight, int corner_size, int margin){
        super(rect, c, stroke_weight, corner_size);
        this.margin = margin;
    }

    /**
    Draws the tab decal for each corner
    */
    void draw_corner(int x1, int y1, int x2, int y2, int x3, int y3) {

        float inside_scale = (float)margin / (float)max(x1-x2, x3-x2);

        beginShape();

        vertex(x1,y1);
        vertex(x2,y2);
        vertex(x3,y3);

        int x_cp1 = x3 + (int)((x1 - x2)*inside_scale);
        int y_cp1 = y3 + (int)((y1 - y2)*inside_scale);
        int x4 = x2 + (int)((x1 - x3)*inside_scale/2);
        int y4 = y2 + (int)((y1 - y3)*inside_scale/2);
        bezierVertex(x_cp1,y_cp1,x_cp1,y_cp1,x4,y4);

        int x_cp2 = x1 + (int)((x3 - x2)*inside_scale);
        int y_cp2 = y1 + (int)((y3 - y2)*inside_scale);
        bezierVertex(x_cp2,y_cp2,x_cp2,y_cp2,x1,y1);

        endShape();

    }

    void draw() {

        setup_draw();
        fill(c, 75);

        super.draw();

        draw_corner();

    }

}