import processing.pdf.*;
import java.util.Comparator;
import java.util.Collections;
import java.util.List;

float sca = 2;

int mmx = int(297*sca);
int mmy = int(420*sca);

int mrx = int(40*sca);
int mry = int(40*sca);

int W = mmx-2*mrx;
int H = mmy-2*mry;

int NUM_LINES = 20000;

PGraphics pg;
List<Line> lines = new ArrayList<Line>();

void settings(){
    size(W + 2*mrx, H + 2*mry, P2D);
}

void setup(){
    pg = createGraphics(W, H);
    pg.beginDraw();
    pg.background(255);
    pg.endDraw();
    noLoop();

    while(lines.size() < NUM_LINES){
        if(lines.size() % 500 == 0)
            println(lines.size());
        create_line();
    }
}

void draw(){
    background(240);
    beginRecord(PDF, "vector/vec.pdf");
    translate(mrx, mry);

    for(Line l : lines){
        l.show();
    }
    
    println("[", lines.size(), "]");

    //rect(0, 0, W, H);
    endRecord();

    pg.save("kaj.png");
}

float power(float p, float g) {
    if (p < 0.5)
        return 0.5 * pow(2*p, g);
    else
        return 1 - 0.5 * pow(2*(1 - p), g);
}


PVector get_root(){
    float ang = random(2*PI);
    float r = map(power(random(1), 1./6), 0, 1, 0, H);
    float vx = W/2 + r * cos(ang);
    float vy = H/2 + r * sin(ang);
    // float vx = random(W);
    // float vy = random(H);
    PVector v1 = new PVector(vx, vy);

    return v1;
}


PVector get_dir(){
    PVector dir = PVector.random2D();
    dir = new PVector(0, 1);
    dir.rotate(radians(random(360)));

    return dir;
}


void create_line(){
    
    PVector v1  = get_root();
    PVector dir = get_dir();

    int ind = lines.size();
    Line new_line = new Line(ind, v1, dir, true);
    lines.add(new_line);
    new_line.build();
    Collections.reverse(new_line.points);
    new_line.v12.rotate(PI);
    new_line.build();
}

boolean isblack(PVector v){
    float b = brightness(pg.get(int(v.x), int(v.y)));

    if(b < 127)
        return true;
    return false;
}

class Line{
    List<PVector> points = new ArrayList<PVector>();
    int ind;
    PVector v1;
    PVector v12;
    float val = 0;
    int points_size = 0;

    Line(int ind, PVector v1, PVector v12){
        this.ind = ind;
        this.v1 = v1;

        this.v12 = v12.get();
        this.v12.normalize();
        if(random(1) < 0.5)
            this.v12.rotate(+PI/2);
        else
            this.v12.rotate(-PI/2);

        this.v12.rotate(radians(random(-45, 45)));
    }

    Line(int ind, PVector v1, PVector v12, boolean zas){
        this.ind = ind;
        this.v1 = v1;

        this.v12 = v12.get();
    }

    Line(int ind, List<PVector> inpoints){
        this.ind = ind;
        this.points = inpoints;
    }

    void build(){
        float mag = 1;

        PVector dir = this.v12;
        //dir = new PVector(0, 1);
        //dir.rotate(radians(random(-45, +45)));
        //if(random(1)>0.5)
        //    dir.rotate(PI);

        boolean zas = true;
        boolean broken = false;
        PVector next = v1.get();
        points.add(next.get());
        int cc = 1;
        while(zas){
            next = PVector.add(next, dir);
            if((next.x < 0 || next.x > W || next.y < 0 || next.y > H || isblack(next) || points.size()>100000) && cc <= 0){
                zas = false;
                next.x = min(W, max(0, next.x));
                next.y = min(H, max(0, next.y));
            }
            if((next.x < 0 || next.x > W || next.y < 0 || next.y > H || isblack(next) || points.size()>100000) && cc > 0){
                cc--;
            }
            points.add(next.get());

            PVector perp = dir.get().rotate(PI/2);
            perp.mult(random(-0.5, +0.5));
            //perp.mult(0.06);
            float amp = 2 * (-0.5 + power(noise(this.ind, this.points.size()*0.3), 2));
            
            amp = 0;
            if (random(100) > 100){
                amp = random(1);
            }

            perp.mult(amp);
            dir.add(perp);
        }
        this.mask();
        //points.remove(points.size()-1);
        this.points_size = points.size();
        //this.val = dist(bpoint.x, bpoint.y, W/2, H/2) / dist(0, 0, W/2, H/2);
        this.val = points.get(points.size()/2).y;
    }

    void show(){
        if(points.size() < 10){
            return;
        }
        noFill();
        stroke(20, 190);
        beginShape();
        strokeWeight(1);
        for(int k = 0; k < points.size(); k++){
            float x = points.get(k).x;
            float y = points.get(k).y;
            vertex(x, y);
        }
        endShape();
    }

    void mask(){
        pg.beginDraw();
        pg.noFill();
        pg.stroke(20);
        pg.strokeWeight(2.2);
        pg.beginShape();
        for(int k = 0; k < points.size(); k++){
            float x = points.get(k).x;
            float y = points.get(k).y;
            pg.vertex(x, y);
        }
        pg.endShape();
        pg.endDraw();
    }
}

public class CustomComparator implements Comparator<Line> {
    @Override
    public int compare(Line o1, Line o2) {
        if(o1.val > o2.val)
            return +1;
        if(o1.val < o2.val)
            return -1;
        return 0;
    }
}