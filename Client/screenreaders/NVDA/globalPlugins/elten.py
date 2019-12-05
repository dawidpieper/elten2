import globalPluginHandler
import ui
import api
is_python_3_or_above = (lambda x: [x for x in [False]] and None or x)(True)
if is_python_3_or_above:
	import threading
else:
	import thread
import time
import os
import globalCommands
import tones
import json
import speech
import braille
import appModuleHandler
import queueHandler
import buildVersion
import types

eltenindex=None
eltenindexid=None

if is_python_3_or_above:
	class EltenIndexCallback(speech.BaseCallbackCommand):
		def __init__(self, index, indid=None):
			self.index = index
			self.indid=indid
		def run(self):
			global eltenindex
			global eltenindexid
			eltenindex=self.index
			eltenindexid=self.indid
		def __repr__(self):
			return "EltenIndexCallback({index}, {indid})".format(
				index=self.index,indid=self.indid)

eltenmod=None
eltenbraille = braille.BrailleBuffer(braille.handler)
eltenqueue=[]

ostc = speech.speakTypedCharacters
def stc(ch):
	global eltenmod
	if(appModuleHandler.getAppModuleForNVDAObject(api.getForegroundObject())!=eltenmod):
		return ostc(ch)

speech.speakTypedCharacters=stc

class GlobalPlugin(globalPluginHandler.GlobalPlugin):

	def elten_thread(threadName=None):
		global eltenmod
		nvdapipeid=""
		nvdapipein=None
		nvdapipeout=None
		eltendata = os.getenv("appdata")+"\\elten"
		nvdapipefile = eltendata+"\\temp\\nvda.pipe"
		while(1):
			try:
				if(nvdapipeid!=""):
					if(appModuleHandler.getAppModuleForNVDAObject(api.getForegroundObject())==eltenmod): time.sleep(0.001)
					else: time.sleep(0.1)
					str=nvdapipein.readline()
					if(len(str)>0):
						if(is_python_3_or_above): str=str.decode("utf-8", errors="ignore")
						j = json.loads(str)
						id=j['id']
						j=elten_command(j)
						j['id']=id
						w=json.dumps(j)+"\n"
						if(is_python_3_or_above): w=w.encode("utf-8")
						nvdapipeout.write(w)
					else:
						time.sleep(0.1)
				if(os.path.isfile(nvdapipefile)):
					file = open(nvdapipefile,mode='r')
					pipeid = file.read()
					file.close()
					if(pipeid!=nvdapipeid):
						try:
							nvdapipeid=pipeid
							nvdapipein=open("\\\\.\\pipe\\"+nvdapipeid+"out", 'rb', 0)
							nvdapipeout=open("\\\\.\\pipe\\"+nvdapipeid+"in", 'wb', 0)
						except: nvdapipeid=""
				elif(nvdapipeid!=""):
					nvdapipeid=""
					nvdapipein.close()
					nvdapipeout.close()
					nvdapipein=None
					nvdapipeout=None
			except Exception as e:
				tones.beep(1320, 100)
#				pass

	def elten_braille_thread(threadName=None):
		global eltenmod
		global eltenbraille
		while(True):
			time.sleep(0.1)
			if(eltenmod!=None and eltenbraille!=None):
				if(appModuleHandler.getAppModuleForNVDAObject(api.getForegroundObject())==eltenmod and eltenbraille!=None and braille.handler.buffer!=eltenbraille and braille.handler.buffer!=braille.handler.messageBuffer):
					braille.handler.buffer=eltenbraille
					braille.handler.update()
				elif(braille.handler!=None and appModuleHandler.getAppModuleForNVDAObject(api.getForegroundObject())!=eltenmod and braille.handler.buffer==eltenbraille):
					braille.handler.buffer=braille.handler.mainBuffer
					braille.handler.update()
				braille.handler.update()

	if is_python_3_or_above:
		threading.Thread(target=elten_thread).start()
		threading.Thread(target=elten_braille_thread).start()
	else:
		thread.start_new_thread ( elten_thread, ('elten', ))
		thread.start_new_thread ( elten_braille_thread, ('elten_braille', ))

def elten_command(ac):
	global eltenmod
	global eltenbraille
	global eltenindex
	global eltenindexid
	global eltenqueue
	try:
		if(('ac' in ac)==False): return {}
		if(ac['ac']=="speak"):
			eltenindex=None
			eltenindexid=None
			text=""
			if('text' in ac): text=ac['text']
			queueHandler.queueFunction(queueHandler.eventQueue,speech.speakText,text)
		if(ac['ac']=="speakindexed"):
			eltenindex=None
			eltenindexid=None
			texts=[]
			indexes=[]
			indid=None
			if('texts' in ac): texts=ac['texts']
			if('indexes' in ac): indexes=ac['indexes']
			if('indid' in ac): indid=ac['indid']
			v=[]
			for i in range(0, len(texts)):
				if is_python_3_or_above:
					if(i<len(indexes)): v.append(EltenIndexCallback(indexes[i], indid))
				else:
					eltenindexid=indid
					if(i<len(indexes)): v.append(speech.IndexCommand(indexes[i]))
				v.append(texts[i])
			speech.speak(v)
		if(ac['ac']=='stop'):
			speech.cancelSpeech()
			eltenindex=None
			eltenindexid=None
		if(ac['ac']=='sleepmode'):
			st=eltenmod.sleepMode
			if('st' in ac): st=ac['st']
			eltenmod.sleepMode=st
			return {'st': st}
		if(ac['ac']=='init'):
#			if(is_python_3_or_above):
#				globalCommands.GlobalCommands.script_braille_toggleTether.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_toggleFocusContextPresentation.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_scrollBack.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_scrollForward.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_routeTo.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_previousLine.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_nextLine.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_dots.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_toFocus.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_eraseLastCell.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_enter.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_translate.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_toggleShift.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_toggleControl.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_toggleAlt.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_toggleWindows.allowInSleepMode=True
#				globalCommands.GlobalCommands.script_braille_toggleNVDAKey.allowInSleepMode=True
			pid=0
			if('pid' in ac): pid=ac['pid']
			eltenmod = appModuleHandler.getAppModuleFromProcessID(pid)
			def script_eltengesture(self, gesture):
				global eltenqueue
				eltenqueue+=gesture.identifiers
			eltenmod.__class__.script_eltengesture = types.MethodType(script_eltengesture, eltenmod.__class__)
			eltenmod.bindGesture('kb(laptop):NVDA+A', 'eltengesture')
			eltenmod.bindGesture('kb(laptop):NVDA+L', 'eltengesture')
			eltenmod.bindGesture('kb(desktop):NVDA+downArrow', 'eltengesture')
			eltenmod.bindGesture('kb(desktop):NVDA+upArrow', 'eltengesture')
#			if(is_python_3_or_above):
#				eltenmod.sleepMode=True
		if(ac['ac']=='braille'):
			text=""
			if('text' in ac): text=ac['text']
			region = braille.TextRegion(text)
			eltenbraille.regions=[region]
			region.update()
			if('pos' in ac): 
				poses = eltenbraille.rawToBraillePos
				if(ac['pos']<len(text) and ac['pos']<len(poses)): eltenbraille.scrollTo(region, poses[ac['pos']])
			eltenbraille.update()
			braille.handler.update()
		if(ac['ac']=='braillepos' and 'pos' in ac and len(eltenbraille.regions)>0):
			poses = eltenbraille.rawToBraillePos
			if(ac['pos']<len(poses)): eltenbraille.scrollTo(eltenbraille.regions[0], poses[ac['pos']])
		if(ac['ac']=='getversion'):
			return {'version': 14}
		if(ac['ac']=='getnvdaversion'):
			return {'version': buildVersion.version}
		if(ac['ac']=='getgestures'):
			r=eltenqueue[:]
			eltenqueue=[]
			return {'queue':r}
			return r
		if(ac['ac']=='getindex'):
			if(is_python_3_or_above):
				return {'index': eltenindex, 'indid': eltenindexid}
			else:
				return {'index': speech.getLastSpeechIndex(), 'indid': eltenindexid}
	except: return {}
	return {}