#!/usr/bin/env python3

import math
import cairo


DPI = 72

A4_WIDTH = 210 / 25.4
A4_HEIGHT = 297 / 25.4

A3_WIDTH = A4_HEIGHT
A3_HEIGHT = A4_WIDTH * 2

WIDTH = A3_HEIGHT
HEIGHT = A3_WIDTH

LANE_WIDTH = 52
LINE_WIDTH = 2
STREET_COLOR = (0.3, 0.3, 0.3)

EXTRA_STREET = 20

def deg2rad(deg):
    return deg * (math.pi / 180.0)


def turn(cr, radius):
    xc = -radius/2 - 20
    yc = 50
    angle1 = deg2rad(0)  # angles are specified
    angle2 = deg2rad(30)  # in radians

    cr.set_source_rgb(*STREET_COLOR)
    cr.set_line_width(LANE_WIDTH*2 + EXTRA_STREET)
    cr.arc(xc, yc, radius, angle1, angle2)
    cr.stroke()

    cr.set_source_rgb(1.0, 1.0, 1.0)
    cr.set_line_width(LINE_WIDTH)

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
    cr.set_source_rgb(*STREET_COLOR)
    cr.rectangle(x - EXTRA_STREET / 2, y, LANE_WIDTH * 2 + EXTRA_STREET, length)
    cr.fill()

    cr.set_source_rgb(1.0, 1.0, 1.0)
    cr.set_line_width(LINE_WIDTH)
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


def intersection(cr):
    x = 25
    y = 250

    radius = 152
    length = 202

    #cr.move_to(0,0)
    cr.set_line_width(0)
    cr.set_source_rgb(*STREET_COLOR)
    cr.rectangle(x, y - radius - LANE_WIDTH - EXTRA_STREET / 2, radius * 2, LANE_WIDTH*2 + EXTRA_STREET)
    cr.fill()

    angle1 = math.pi / 2 + math.pi
    angle2 = 0
    cr.set_source_rgb(*STREET_COLOR)
    cr.set_line_width(LANE_WIDTH*2 + EXTRA_STREET)
    cr.arc(x, y, radius, angle1, angle2)
    cr.stroke()

    angle1 = -math.pi
    angle2 = -math.pi / 2
    cr.set_source_rgb(*STREET_COLOR)
    cr.set_line_width(LANE_WIDTH*2 + EXTRA_STREET)
    cr.arc(x+radius*2, y, radius, angle1, angle2)
    cr.stroke()

    # lines for straight part
    cr.set_source_rgb(1.0, 1.0, 1.0)
    cr.set_line_width(LINE_WIDTH)
    cr.move_to(x, y - radius - LANE_WIDTH)
    cr.line_to(x + radius * 2, y - radius - LANE_WIDTH)
    cr.stroke()

    for i in range(0, (radius * 2) // 20, 2):
        cr.move_to(x + i * 20, y - radius - LANE_WIDTH + LANE_WIDTH * 2)
        cr.line_to(x + 20 + i * 20, y - radius - LANE_WIDTH + LANE_WIDTH * 2)
        cr.stroke()

    for i in range(0, (radius * 2) // 20, 2):
        cr.move_to(x + i * 20, y - radius - LANE_WIDTH + LANE_WIDTH)
        cr.line_to(x + 20 + i * 20, y - radius - LANE_WIDTH + LANE_WIDTH)
        cr.stroke()

    # lines for curved parts
    cr.arc(x, y, radius - LANE_WIDTH, math.pi * 1.5, 0)
    cr.stroke()

    cr.arc(x + radius * 2, y, radius - LANE_WIDTH, -math.pi, -math.pi / 2)
    cr.stroke()

    stop_line_offset = 25

    cr.move_to(x + radius, y)
    cr.line_to(x + radius, y - radius + LANE_WIDTH + stop_line_offset)
    cr.stroke()

    cr.set_line_width(10)
    cr.move_to(x + radius - LINE_WIDTH / 2, y - radius + LANE_WIDTH + stop_line_offset)
    cr.line_to(x + radius + LANE_WIDTH + 20, y - radius + LANE_WIDTH + stop_line_offset)
    cr.stroke()




with cairo.PDFSurface('texture.pdf', WIDTH * DPI, HEIGHT * DPI) as surface:
    cr = cairo.Context(surface)

    # set canvas scaling to mm
    cr.scale(DPI/25.4, DPI/25.4)

    radius = 229 + LANE_WIDTH/2

    turn(cr, radius)
    cr.show_page()

    straight(cr, 202)
    cr.show_page()

    intersection(cr)
    cr.show_page()
