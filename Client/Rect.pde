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

    /**
    Returns a rect that is a sliced subsection of the total rect
    Takes the pos and size of the new rect as percentages of the entire rect
        where (0,0) is the upper left, and (1,1) is the lower right
    */
    Rect get_section(float rel_x, float rel_y, float rel_w, float rel_h){
        return new Rect(
            x + (int)(rel_x * (float)w),
            y + (int)(rel_y * (float)h),
            (int)(rel_w * (float)w),
            (int)(rel_h * (float)h)
        );
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
the rect that represents the entire screen
*/
Rect SCREEN_RECT = new Rect(0,0,width,height);