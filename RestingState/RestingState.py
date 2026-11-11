import StimToolLib, os
from psychopy import visual, event, data

#Resting state fixation cross
#Shows a fixed cross in the middle of the screen until the proctor presses escape.
#There is no scanner trigger wait, no instructions and no time limit: the cross appears as soon as the window opens.

class GlobalVars:
    #This class will contain all module specific global variables
    def __init__(self):
        self.win = None #the window where everything is drawn
        self.clock = None #global clock used for timing
        self.output = None #The output file
        self.msg = None
        self.status = -1

CROSS_SIZE = 180 #length of each line of the cross, in pixels
CROSS_THICKNESS = 6 #in pixels

event_types = {'FIXATION_ONSET':1,
    'FIXATION_END':2,
    'TASK_END':StimToolLib.TASK_END}

def open_output():
    #The log only holds the time the cross appeared and the time escape was pressed.
    #If it cannot be written (e.g. output_dir does not exist on this computer and cannot be created) the cross is still shown.
    try:
        g.prefix = StimToolLib.generate_prefix(g)
        fileName = g.prefix + '.csv'
        g.output = open(fileName, 'w')
        sorted_events = sorted(event_types.items(), key=lambda item: item[1])
        g.output.write('Administrator:,' + str(g.session_params['admin_id']) + ',Original File Name:,' + fileName + ',Time:,' + data.getDateStr() + ',Event Codes:,' + str(sorted_events) + '\n')
        g.output.write('trial_number,trial_type,event_code,absolute_time,response_time,response,result\n')
    except (IOError, OSError) as e:
        print('RestingState: could not create the output file, continuing without one: ' + str(e))
        g.output = None

def mark(event_name, now, duration):
    if g.output:
        StimToolLib.mark_event(g.output, 'NA', 'NA', event_types[event_name], now, duration, 'NA', 'NA', g.session_params['signal_parallel'], g.session_params['parallel_port_address'])

def run(session_params, run_params):
    global g
    g = GlobalVars()
    g.session_params = session_params
    g.run_params = StimToolLib.get_var_dict_from_file(os.path.join(os.path.dirname(__file__), 'REST.Default.params'), {})
    g.run_params.update(run_params)
    try:
        run_try()
    finally:
        #task_end shows a "Run complete" screen when the status is 0. Escape is the normal way to end
        #this run, so close everything down without that screen and then report success.
        g.status = -1
        StimToolLib.task_end(g)
    g.status = 0
    return g.status

def run_try():
    StimToolLib.general_setup(g)
    open_output()

    #black cross in the exact centre of the screen, about the size of the one in the fixation blocks of the face matching task
    #(that one is an image, Hariri/media/Cross.bmp, in which the cross is not centred, so it is drawn here instead)
    bars = [visual.Rect(g.win, width=w, height=h, units='pix', pos=[0, 0], fillColor=[-1, -1, -1], lineColor=None, colorSpace='rgb') for w, h in [(CROSS_SIZE, CROSS_THICKNESS), (CROSS_THICKNESS, CROSS_SIZE)]]
    def draw_cross():
        for bar in bars:
            bar.draw()

    StimToolLib.task_start(StimToolLib.REST_CODE, g)
    event.clearEvents() #a key pressed before the cross is up should not end the run
    draw_cross()
    g.win.flip()
    onset = g.clock.getTime()
    mark('FIXATION_ONSET', onset, 'NA')

    while not event.getKeys(['escape']):
        draw_cross() #redraw every frame so the cross survives the window being covered and uncovered
        g.win.flip()

    now = g.clock.getTime()
    mark('FIXATION_END', now, now - onset)
