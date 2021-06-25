$fa = 1;
$fs = 1;
magnetWidth = 3.2;
magnetHeight = 1.0;
laneWidth = 52;
streetHeight = 2.0;

trackExtraOffset = 11;

module sector(d, a1, a2) {
    if (a2 - a1 > 180) {
        difference() {
            circle(d=d);
            translate([0,0, 0]) sector(d+1, a2-360, a1); 
        }
    } else {
        difference() {
            circle(d=d);
            rotate([0,0,a1]) translate([-d/2, -d/2, 0])
                square([d, d/2]);
            rotate([0,0,a2]) translate([-d/2, 0, 0])
                square([d, d/2]);
        }
    }
}

module arc(d1, d2, a1, a2) {
    difference() {
        sector(d2, a1, a2);
        circle(d=d1);
    };
}

module turnTrackExtraEntry(r, b, alpha) {
    x = -(b*(r*2+b)) / (2 * r * cos(alpha) - (2*r + 2*b));
    s = (2 * r*(r+b)*cos(alpha) - (r*(r+b)*2+b^2)) / (2 * r * cos(alpha) - (2*r + 2*b));
    beta = asin((2 * r *sin(alpha)*(r * cos(alpha) - (r + b))) / (r*(r+b)*2*cos(alpha) - (r*(r+b)*2+b^2)));
    
    translate([x, 0, 0]) arc(2*(s-magnetWidth/2), 2*(s+magnetWidth/2), -1, beta + 1);
}

module turnTrack(r, alpha) {
    arc(2*(r-magnetWidth/2), 2*(r+magnetWidth/2), -1, alpha+1);
}

module straightTrack(length) {
    translate([-magnetWidth/2, 0, 0]) square([magnetWidth, length]);
}

module roundedCorner(r) {
    difference() {
        translate([0, 0, 0]) square([r, r]);
        translate([r, r, 0]) circle(r=r);
    }
}

module notch(scale=1.0) {
    union() {
        translate([0, 12.5, 0]) circle(r=8*scale);
        translate([0, 5, 0]) square([10, 10], center=true);
    }
}

module notchCutout() {
    union() {
        notch();
        translate([5, 0, 0]) roundedCorner(2.5);
        translate([-5, 0, 0]) mirror([1, 0, 0]) roundedCorner(2.5);
        translate([0, -0.5, 0]) square([15, 1], center=true);
    }
}

module turn(r, alpha, entry=false, extra=false) {
    r_inner = r - laneWidth/2;
    r_outer = r + laneWidth/2;
    
    difference() {
        linear_extrude(streetHeight) {
            arc(2*r_inner, 2*r_outer, 0, alpha);
        };
        translate([0, 0, streetHeight-magnetHeight]) linear_extrude(magnetHeight+1) {
            turnTrack(r, alpha);
            if (entry) {
                turnTrackExtraEntry(r, trackExtraOffset, alpha);
            }
            if (extra) {
                turnTrack(r + trackExtraOffset, alpha);
            }
        };
        translate([0, 0, -1]) linear_extrude(streetHeight+2) {
            translate([r, 0]) notchCutout();
        }
        
        translate([0, 0, -1]) linear_extrude(streetHeight+2) {
            rotate([0, 0, alpha])
                translate([r, 0]) mirror([0, 1, 0]) notchCutout();
        }
    };
}

module straight(length, extra=false) {
    difference() {
        linear_extrude(streetHeight) {
            square([laneWidth, length]);
        };
        translate([laneWidth/2, 0, streetHeight-magnetHeight]) linear_extrude(magnetHeight+1) {
            straightTrack(length);
        }
        if (extra) {
            translate([laneWidth/2 + trackExtraOffset, 0, streetHeight-magnetHeight]) 
                linear_extrude(magnetHeight+1) {
                straightTrack(length);
            }
        }
        translate([0, 0, -1]) linear_extrude(streetHeight+2) {
            translate([laneWidth/2, 0]) notchCutout();
        }
        translate([0, length, -1]) linear_extrude(streetHeight+2) {
            translate([laneWidth/2, 0]) mirror([0, 1, 0]) notchCutout();
        }
    }
}

module doubleStraight(length, extra=false) {
    union() {
        straight(length, extra=extra);
        translate([laneWidth, 0, 0]) straight(length, extra=extra);
    };
}


straightLenghts = [203, 101.5, 52];

for (i = [0:len(straightLenghts)-1]) {
    length = straightLenghts[i];
    translate([0, 220*i, 0]) rotate([0, 0, 90]) {
        straight(length, extra=true);
        translate([laneWidth + 10, 0, 0]) doubleStraight(length);
    }
}

turnRadii = [385, 333, 281, 229, 177, 125];
turnAngles = [45, 30, 15];
turnModes = [0, 1, 2, 3];

for (i = [0:len(turnRadii)-1], j=[0:len(turnAngles)-1], k=[0:len(turnModes)-1]) {
    r = turnRadii[i];
    a = turnAngles[j];
    mode = turnModes[k];
    
    entry = mode == 1 || mode == 3;
    extra = mode == 2;
    mir = mode == 3;

    translate([-10 * i + k * 500, 300*j, 0]) {
        if (mir) {
            rotate([0, 0, a]) mirror([0,1,0]) turn(r, a, entry=entry, extra=extra);
        } else {
            turn(r, a, entry=entry, extra=extra);
        }
    }
}


//notchCutout();
/*

alpha=30
r=100
b = 10


s = cos(beta) * s + (r - cos(alpha) * r)

cos(beta) * s + x = cos(alpha) * r
x = cos(alpha) * r - cos(beta) * s

sin(alpha) * r = sin(beta) * s
beta = asin((sin(alpha) * r) / s)

x + s = r + b
s = (r + b) - x

alpha=30°;
r=100; 
b = 10; 

beta = asin((sin(alpha) * r) / s); 
x = cos(alpha) * r - cos(beta) * s; 
s = (r + b) - x


beta = asin((sin(alpha) * r) / s); 
s = (r + b) - (cos(alpha) * r - cos(beta) * s) 


sin(beta) * s = sin(alpha) * r)
cos(beta) * s + x = cos(alpha) * r
x + s = r + b | *-1
-x - s = -r - b

sin(beta) * s = sin(alpha) * r)
cos(beta) * s + x = cos(alpha) * r | +(-x - s = -r - b)
cos(beta) * s - s = cos(alpha) - r - b





s = (?*cos(alpha) - ??) / (2 * r * cos(alpha) - ????)
beta = asin((2 * r *sin(alpha)*(r * cos(alpha) - (r + b)) / (? * cos(alpha)-??)


x = -(b*(r*2+b)) / (2 * r * cos(alpha) - (2*r + 2*b)
s = (r*(r+b)*2*cos(alpha) - r*(r+b)*2+b^2) / (2 * r * cos(alpha) - (2*r + 2*b)
beta = asin((2 * r *sin(alpha)*(r * cos(alpha) - (r + b)) /  (r*(r+b)*2*cos(alpha) - r*(r+b)*2+b^2)

*/
