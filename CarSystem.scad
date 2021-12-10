$fa = 1;
$fs = 1;
magnetWidth = 3.2;
magnetHeight = 1.0;
magnetHole = 4.0;

laneWidth = 52;
streetHeight = 3.0;

trackExtraOffset = 11;

switchOuter = 32;
switchInner = 30;

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
        difference() {
            translate([0, 5, 0]) square([10*scale, 10], center=true);
            translate([0, 12.5, 0]) circle(r=8*scale);
        };
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

module turn(r, alpha, entry=false, exit=false, extra=false) {
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
            if (exit) {
                rotate([0, 0, alpha]) mirror([0, 1, 0])
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

module notchConnector() {
    difference() {
        linear_extrude(streetHeight) union() {
            notch(0.98);
            mirror([0, 1, 0]) notch(0.98);
        };
        translate([0, 0, streetHeight - magnetHeight * 0.5 + 0.5])
            cube([magnetWidth, 50, magnetHeight + 1], center=true);
        for (m=[0, 1]) {
            mirror([0, m, 0]) translate([0, 0, streetHeight - magnetHeight])
                linear_extrude(magnetHeight + 1) polygon([[0, 0], [4.5, 21], [-4.5, 21]]);
        };
    };
}

module switchCutout() {
    topHeight = 1;
    bottomHeight = streetHeight-topHeight;
    union() {
        translate([0, 0, -0.5]) cylinder(h=bottomHeight+1, d=switchInner);
        translate([0, 0, bottomHeight]) cylinder(h=topHeight+1, d=switchOuter);
    };
}

module intersectionA(r=150) {
    l = r + laneWidth;

    track_inner_r = r-25;
    track_offset = (r + laneWidth/2) - track_inner_r;

    difference() {
        linear_extrude(streetHeight) difference() {
            union() {
                square([l, l]);
                translate([l, l-laneWidth/2, 0]) rotate([0, 0, -90]) notch();
            };
            circle(r=r);
            translate([0, l-laneWidth/2, 0]) rotate([0, 0, -90]) notchCutout();
            translate([l-laneWidth/2, 0, 0]) notchCutout();
            translate([l-laneWidth/2, l, 0]) rotate([0, 0, 180]) notchCutout();
        };

        translate([0, 0, streetHeight - magnetHeight]) linear_extrude(magnetHeight+1) {
            translate([l/2, l - laneWidth/2, 0])
              square([l+50, magnetWidth], center=true);
            translate([l - laneWidth/2, l/2, 0])
              square([magnetWidth, l+1], center=true);

            translate([track_offset, track_offset, 0])
              arc(2*(track_inner_r-magnetWidth/2), 2*(track_inner_r+magnetWidth/2), 0, 90);
            translate([track_offset, track_offset, 0])
              arc(2*(track_inner_r+laneWidth-magnetWidth/2), 2*(track_inner_r+laneWidth+magnetWidth/2), 0, 90);

            translate([l+track_inner_r+laneWidth/2, track_offset, 0])
              arc(2*(track_inner_r+laneWidth-magnetWidth/2), 2*(track_inner_r+laneWidth+magnetWidth/2), 0, 270);

            translate([track_offset, l+track_inner_r+laneWidth/2, 0])
              arc(2*(track_inner_r+laneWidth-magnetWidth/2), 2*(track_inner_r+laneWidth+magnetWidth/2), 270, 360);
        };
        
        arc_pos = [track_offset, track_offset];
        arc2_pos = [track_offset, l+track_inner_r+laneWidth/2];
        switch_pos = [track_offset+switchOuter, l-laneWidth/2];

        pts = circleIntersection(arc_pos, switch_pos, track_inner_r, switchOuter/2);
        pts2 = circleIntersection(arc2_pos, switch_pos, track_inner_r+laneWidth, switchOuter/2);

        translate(switch_pos) switchCutout();
        
        translate([track_offset+switchOuter+switchOuter*0.5, l-laneWidth/2, -0.5]) cylinder(h=streetHeight + 1, d=magnetHole);
        translate([pts[0][0], pts[0][1], -0.5]) cylinder(h=streetHeight + 1, d=magnetHole);
        translate([pts2[1][0], pts2[1][1], -0.5]) cylinder(h=streetHeight + 1, d=magnetHole);
   };
}

module intersectionB(r=150) {
    l = r + laneWidth;
    track_inner_r = r-25;
    track_offset = (r + laneWidth/2) - track_inner_r;

    difference() {
        linear_extrude(streetHeight) difference() {
            union() {
                square([l, laneWidth]);
                translate([laneWidth/2, laneWidth, 0]) rotate([0, 0, 0]) notch();
            };

            translate([0, laneWidth/2, 0]) rotate([0, 0, -90]) notchCutout();
            translate([l, laneWidth/2, 0]) rotate([0, 0, 90]) notchCutout();
        };

        translate([0, 0, streetHeight - magnetHeight]) linear_extrude(magnetHeight+1) {
            translate([l/2, laneWidth/2, 0])
              square([l, magnetWidth], center=true);

            translate([l-track_offset, track_inner_r +laneWidth+ laneWidth/2, 0]) 
              arc(2*(track_inner_r+laneWidth-magnetWidth/2), 2*(track_inner_r+laneWidth+magnetWidth/2), 180, 270);
        };
    };
}

function distance(P0, P1) = 
    sqrt(pow(P0[0] - P1[0], 2) + pow(P0[1] - P1[1], 2));

function circleIntersection(P0, P1, r0, r1) = 
    let (d = distance(P0, P1))
    let (a = (r0*r0 - r1*r1 + d*d) / (2*d))
    let (h = sqrt(r0*r0 - a*a))
    let (P2 = P0 + a * (P1 - P0) / d)
        [[P2[0] + h * (P1[1] - P0[1]) / d, P2[1] - h * (P1[0] - P0[0]) / d],
         [P2[0] - h * (P1[1] - P0[1]) / d, P2[1] + h * (P1[0] - P0[0]) / d]];

module intersectionC(r=150) {
    l = r + laneWidth;
    track_inner_r = r-25;
    track_offset = (r + laneWidth/2) - track_inner_r;
    switch_offset = track_offset+switchInner;

    difference() {
        linear_extrude(streetHeight) difference() {
            union() {
                square([l, laneWidth]);
                translate([l, laneWidth/2, 0]) rotate([0, 0, -90]) notch();
            };

            translate([0, laneWidth/2, 0]) rotate([0, 0, -90]) notchCutout();
            translate([l-laneWidth/2, laneWidth, 0]) rotate([0, 0, 180]) notchCutout();
        };
        
        arc_pos = [track_offset, track_inner_r +laneWidth+ laneWidth/2];

        translate([0, 0, streetHeight - magnetHeight]) linear_extrude(magnetHeight+1) {
            translate([l/2, laneWidth/2, 0]) square([l+50, magnetWidth], center=true);
            translate(arc_pos)
              arc(2*(track_inner_r+laneWidth-magnetWidth/2), 2*(track_inner_r+laneWidth+magnetWidth/2), 270, 360);
        };
        
        switch_pos = [switch_offset, laneWidth/2];
        
        pts = circleIntersection(arc_pos, switch_pos, track_inner_r+laneWidth, switchOuter/2);

        translate(switch_pos) switchCutout();
        
        translate([switch_offset+switchOuter*0.5, laneWidth/2, -0.5]) cylinder(h=streetHeight + 1, d=magnetHole);
        translate([pts[1][0], pts[1][1], -0.5]) cylinder(h=streetHeight + 1, d=magnetHole);
    };
}


straightLenghts = [202, 101, 2*laneWidth, laneWidth];

//turnRadii = [385, 333, 281, 229, 177, 125];

function turnRadii() = [
        for (a = [3, 2, 1, 0, -1, -2]) straightLenghts[0] + laneWidth / 2 + a * laneWidth    
];
        
turnAngles = [/*45, */30/*, 15*/];
turnModes = [0, 1, 2, 3];

showAll = false;

if (showAll) {
    for (i = [0:len(straightLenghts)-1]) {
        length = straightLenghts[i];
        translate([0, 220*i, 0]) rotate([0, 0, 90]) {
            straight(length, extra=true);
            translate([laneWidth + 10, 0, 0]) doubleStraight(length);
        }
    }

    for (i = [0:len(turnRadii)-1], j=[0:len(turnAngles)-1], k=[0:len(turnModes)-1]) {
        r = turnRadii[i];
        a = turnAngles[j];
        mode = turnModes[k];
        
        entry = mode == 1;
        extra = mode == 2;
        exit = mode == 3;

        translate([-10 * i + k * 500, 300*j, 0]) {
            turn(r, a, entry=entry, exit=exit, extra=extra);        
        }
    }
}

//notchConnector();


turn(turnRadii[3], 30, entry=true, exit=true, extra=true);

//straight(straightLenghts[2], extra=false);

//intersectionA(r=straightLenghts[0] - laneWidth); // length = r+laneWidth = 202



//translate([202, 202+52+0, 0]) rotate([0, 0, 180]) intersectionB();
//translate([202*2, 202+52+0, 0]) rotate([0, 0, 180]) intersectionC();

//translate([202*2, 0, 0]) rotate([0, 0, 90]) intersectionA();
//translate([0, 202*2, 0]) rotate([0, 0, 270]) intersectionA();
//translate([202*2, 202*2, 0]) rotate([0, 0, 180]) intersectionA();
