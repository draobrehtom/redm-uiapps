"""A match HUD (scores, timer, objective bar, kill feed) written with tools/uiscene.py.

    python build.py path\to\codexcli.exe
"""
import os, subprocess, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'tools'))
from uiscene import Scene, flow

s = Scene('MatchHud')

# top centre: BLUE 3   2:41   1 RED
s.add(s.panel('PAN_Score', [
    s.ink('IMG_ScoreBg'),
    s.text('TXT_Blue', 'blue', 'HUD_LOCATION_TEXT', 'CENTER', color='COLOR_BLUE', w=80, l=20, t=8),
    s.text('TXT_Timer', 'timer', 'HUD_LOCATION_TEXT', 'CENTER', color_path='timerColor', w=140, l=110, t=8),
    s.text('TXT_Red', 'red', 'HUD_LOCATION_TEXT', 'CENTER', color='COLOR_RED', w=80, l=260, t=8),
], h='HALIGN_CENTER', w=360, ht=70))

# under it: objective text and a bar
s.add(s.stack('STACK_Objective', [
    s.text('TXT_Objective', 'objective', 'HUD_TEXT_BODY', 'CENTER', h='HALIGN_STRETCH'),
    s.meter('METER_Capture', 'capture', fill='COLOR_GOLD', w=300, ht=10, h='HALIGN_CENTER', t=6),
], visible='objectiveVisible', h='HALIGN_CENTER', w=400, t=80))

# top right: four kill feed rows
s.add(s.stack('STACK_Feed', [
    s.text(f'TXT_Feed{i}', f'feed{i}', 'HUD_TEXT_BODY', 'RIGHT', visible=f'feed{i}Visible', h='HALIGN_STRETCH')
    for i in range(1, 5)
], h='HALIGN_RIGHT', w=500))

here = os.path.dirname(os.path.abspath(__file__))
s.write(os.path.join(here, 'src', 'match_hud_scene.rbf.xml'))
flow('match_hud_flow', 'match_hud_scene', os.path.join(here, 'src', 'match_hud_flow.rbf.xml'))
print('bound paths:', ', '.join(sorted(s.paths)))

if len(sys.argv) > 1:
    for n in ('match_hud_scene', 'match_hud_flow'):
        subprocess.run([sys.argv[1], 'fromxml', os.path.join(here, 'src', n + '.rbf.xml'),
                        os.path.join(here, 'stream', n + '.ymt')], check=True)
