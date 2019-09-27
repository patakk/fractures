import processing.pdf.*;
import java.util.Comparator;
import java.util.Collections;
import java.util.List;

int pad = 100;
int W = 800-2*pad;
int H = 800-2*pad;

int NUM_POINTS = 24000;

PGraphics pg;
List<Line> lines = new ArrayList<Line>();

void settings(){
    size(W + 2*pad, H + 2*pad, P2D);
}

void setup(){
    pg = createGraphics(W, H);
    pg.beginDraw();
    pg.background(255);
    pg.endDraw();
    noLoop();

    Line l = null;
    int rand = floor(random(4));
    if(rand == 0){
        PVector v12 = new PVector(0, 1);
        v12.rotate(radians(random(-45, +45)));
        l = new Line(0, new PVector(random(W)-1, 0), v12, true);
    }
    if(rand == 1){
        PVector v12 = new PVector(0, -1);
        v12.rotate(radians(random(-45, +45)));
        l = new Line(0, new PVector(random(W)-1, H-1), v12, true);
    }
    if(rand == 2){
        PVector v12 = new PVector(1, 0);
        v12.rotate(radians(random(-45, +45)));
        l = new Line(0, new PVector(0, random(H)-1), v12, true);
    }
    if(rand == 3){
        PVector v12 = new PVector(-1, 0);
        v12.rotate(radians(random(-45, +45)));
        l = new Line(0, new PVector(W-1, random(H)-1), v12, true);
    }
    lines.add(l);

    lines.get(lines.size()-1).build();
    while(lines.size() < NUM_POINTS){
        println(lines.size());
        trigger();
    }
}

void draw(){
    background(240);
    beginRecord(PDF, "vector/vec.pdf");
    translate(pad, pad);

    for(Line l : lines){
        l.show();
    }
    
    println("**", lines.size());

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

void trigger(){
    Line line = lines.get(0);

    /*
    float chosen_prob = H * pow(random(1), 4);
    float min_dist = 100000000;
    for(Line l : lines){
        PVector rp1 = l.points.get(0);
        PVector rp2 = l.points.get(l.points.size()/2);
        PVector rp3 = l.points.get(l.points.size()-1);
        float the_dist = (abs(rp1.y - chosen_prob))/1;
        if(the_dist < min_dist){
            line = l;
            min_dist = the_dist;
        }
    }

    Collections.sort(lines, new CustomComparator());
    int choose = int(floor(lines.size()*pow(random(1), 2)));
    choose = 0;
    if(lines.size() > 10){
        choose = floor(random(10));
    }
    line = lines.get(choose);
    */

    int the_ind = -1;
    if(random(1) < 1.0){
        int max_points = -1;
        line = lines.get(0);
        the_ind = 0;
        for(int k = 0; k < lines.size(); k++){
            Line l = lines.get(k);
            if(l.points_size > max_points){
                max_points = l.points_size;
                line = l;
            }
            the_ind = k;
        }
    }else{
        int randind = floor(random(lines.size()));
        line = lines.get(randind);
        the_ind = randind;
        int counter = 0;
        while(line.points_size < 20 && counter++ < 100){
            randind = floor(random(lines.size()));
            line = lines.get(randind);
            the_ind = randind;
        }
    }

    int num_points = line.points.size();
    int rand_ind   = int(num_points*random(0.3, 0.7));
    int rand_ind_n = rand_ind + 1;

    try{
        PVector v1 = line.points.get(rand_ind);
        PVector v2 = line.points.get(rand_ind_n);
        
        ////
        line.points_size /= 2;
        //Line lp1 = new Line(lines.size()+1, line.points.subList(0, rand_ind));
        //Line lp2 = new Line(lines.size()+2, line.points.subList(rand_ind, line.points.size()));
        //lines.remove(the_ind);
        //lines.add(lp1);
        //lines.add(lp2);

        int ind = lines.size();
        Line new_line = new Line(ind, v1, PVector.sub(v2, v1));
        lines.add(new_line);
        new_line.build();
    }
    catch(IndexOutOfBoundsException e){

    }
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
        if(points.size() < 5){
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
        pg.strokeWeight(1.9);
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