#!/usr/bin/env python3

import math
import cairo


DPI = 72

WIDTH = 210 / 25.4
HEIGHT = 297 / 25.4

LANE_WIDTH = 52

def deg2rad(deg):
    return deg * (math.pi / 180.0)


def turn(cr, radius):
    xc = -radius/2 - 20
    yc = 50
    angle1 = deg2rad(0)  # angles are specified
    angle2 = deg2rad(30)  # in radians

    cr.set_source_rgb(0.25, 0.25, 0.25)
    cr.set_line_width(LANE_WIDTH*2 + 10)
    cr.arc(xc, yc, radius, angle1, angle2)
    cr.stroke()

    cr.set_source_rgb(1.0, 1.0, 1.0)
    cr.set_line_width(2)

    for i in (-1, 1):
        cr.arc(xc, yc, radius + LANE_WIDTH * -i + 2 * i, 0, angle2)
        cr.stroke()

    for i in range(0, 5, 2):
        cr.arc(xc, yc, radius, deg2rad(5*i), deg2rad(5*(i+1)))
        cr.stroke()



def straight(cr, length):
    x = 25
    y = 25

    #cr.move_to(0,0)
    cr.set_line_width(0)
    cr.set_source_rgb(0.25, 0.25, 0.25)
    cr.rectangle(x-5, y, LANE_WIDTH*2+10, length)
    cr.fill()

    cr.set_source_rgb(1.0, 1.0, 1.0)
    cr.set_line_width(2)
    cr.move_to(x+2, y)
    cr.line_to(x+2, y+length)
    cr.stroke()

    cr.move_to(x + LANE_WIDTH*2 - 2, y)
    cr.line_to(x + LANE_WIDTH*2 - 2, y+length)
    cr.stroke()

    for i in range(0, length // 20, 2):
        cr.move_to(x + LANE_WIDTH, y + i * 20)
        cr.line_to(x + LANE_WIDTH, y + 20 + i * 20)
        cr.stroke()


with cairo.PDFSurface('texture.pdf', WIDTH * DPI, HEIGHT * DPI) as surface:
    cr = cairo.Context(surface)

    # set canvas scaling to mm
    cr.scale(DPI/25.4, DPI/25.4)

    radius = 281 + LANE_WIDTH/2
    turn(cr, radius)
    cr.show_page()
    straight(cr, 202)
    cr.show_page()
