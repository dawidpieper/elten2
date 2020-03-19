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

stopThreads=False
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
			global eltenqueue
			eltenindex=self.index
			eltenindexid=self.indid
			eltenqueue['indexes'].append({'index':self.index, 'indid':self.indid})
		def __repr__(self):
			return "EltenIndexCallback({index}, {indid})".format(
				index=self.index,indid=self.indid)

eltenmod=None
eltenbraille = braille.BrailleBuffer(braille.handler)
eltenbrailletext=""
eltenqueue={'gestures':[], 'indexes':[], 'statuses':[]}
eltenpipein=None
eltenpipeout=None
eltenpipest=None

ostc = speech.speakTypedCharacters
def stc(ch):
	global eltenmod
	if(appModuleHandler.getAppModuleForNVDAObject(api.getForegroundObject())!=eltenmod):
		return ostc(ch)

speech.speakTypedCharacters=stc

class GlobalPlugin(globalPluginHandler.GlobalPlugin):

	def elten_thread(threadName=None):
		global stopThreads
		wrongpipeid=""
		global eltenmod
		global eltenqueue
		nvdapipeid=""
		global eltenpipein
		global eltenpipeout
		global eltenpipest
		eltenpipein=None
		eltenpipeout=None
		eltenpipest=None
		eltendata = os.getenv("appdata")+"\\elten"
		nvdapipefile = eltendata+"\\temp\\nvda.pipe"
		while(1):
			if(stopThreads): break
			try:
				if(nvdapipeid!=""):
					if(appModuleHandler.getAppModuleForNVDAObject(api.getForegroundObject())==eltenmod): time.sleep(0.001)
					else: time.sleep(0.1)
					str=eltenpipein.readline()
					if(len(str)>0):
						if(is_python_3_or_above): str=str.decode("utf-8", errors="ignore")
						j = json.loads(str)
						id=j['id']
						asnc=False
						if('async' in j): asnc=j['async']
						j=elten_command(j)
						j['id']=id
						if(asnc!=False): j['msgtype']=1
						w=json.dumps(j)+"\n"
						if(is_python_3_or_above): w=w.encode("utf-8")
						if(asnc==False): eltenpipeout.write(w)
						else: eltenpipest.write(w)
				else:
					time.sleep(0.1)
				if(os.path.isfile(nvdapipefile)):
					file = open(nvdapipefile,mode='r')
					pipeid = file.read()
					file.close()
					if(pipeid!=nvdapipeid and pipeid!=wrongpipeid):
						try:
							nvdapipeid=pipeid
							eltenpipein=open("\\\\.\\pipe\\"+nvdapipeid+"out", 'rb', 0)
							eltenpipeout=open("\\\\.\\pipe\\"+nvdapipeid+"in", 'wb', 0)
							eltenpipest=open("\\\\.\\pipe\\"+nvdapipeid+"st", 'wb', 0)
							eltenqueue['statuses'].append("connected")
							if(is_python_3_or_above): 							eltenqueue['statuses'].append("cbckindexing")
						except:
							wrongpipeid=pipeid
							nvdapipeid=""
							try: os.remove(nvdapipefile)
							except: pass
				elif(nvdapipeid!=""):
					nvdapipeid=""
					eltenpipein.close()
					eltenpipeout.close()
					eltenpipest.close()
					eltenpipein=None
					eltenpipeout=None
					eltenpipest=None
			except:
				tones.beep(1320, 100)
				pass

	def elten_braille_thread(threadName=None):
		global stopThreads
		global eltenmod
		global eltenbraille
		global eltenbrailletext
		oldbraille=eltenbrailletext
		while(True):
			if(stopThreads): break
			time.sleep(0.1)
			if(eltenmod!=None and eltenbraille!=None):
				if(appModuleHandler.getAppModuleForNVDAObject(api.getForegroundObject())==eltenmod and eltenbraille!=None and braille.handler.buffer!=eltenbraille and braille.handler.buffer!=braille.handler.messageBuffer):
					braille.handler.buffer=eltenbraille
					braille.handler.update()
				elif(braille.handler!=None and appModuleHandler.getAppModuleForNVDAObject(api.getForegroundObject())!=eltenmod and braille.handler.buffer==eltenbraille):
					braille.handler.buffer=braille.handler.mainBuffer
					braille.handler.update()
				if oldbraille!=eltenbrailletext:
					oldbraille=eltenbrailletext
					braille.handler.update()

	def elten_queue_thread(threadName=None):
		global stopThreads
		global eltenqueue
		global eltenpipest
		global eltenindex
		global eltenindexid
		global eltenmod
		lastSend=0
		while(True):
			if(stopThreads): break
			time.sleep(0.01)
			try:
				if(eltenpipest!=None and eltenpipest!=-1 and len(eltenqueue['gestures'])>0):
					r=eltenqueue['gestures'][:]
					eltenqueue['gestures']=[]
					j={'msgtype':2, 'gestures':r}
					w=json.dumps(j)+"\n"
					if(is_python_3_or_above): w=w.encode("utf-8")
					eltenpipest.write(w)
					lastSend=time.time()
				if(eltenpipest!=None and eltenpipest!=-1 and len(eltenqueue['indexes'])>0):
					r=eltenqueue['indexes'][:]
					eltenqueue['indexes']=[]
					j={'msgtype':3, 'indexes':r}
					w=json.dumps(j)+"\n"
					if(is_python_3_or_above): w=w.encode("utf-8")
					eltenpipest.write(w)
					lastSend=time.time()
				if(eltenpipest!=None and eltenpipest!=-1 and len(eltenqueue['statuses'])>0):
					r=eltenqueue['statuses'][:]
					eltenqueue['statuses']=[]
					j={'msgtype':4, 'statuses':r}
					w=json.dumps(j)+"\n"
					if(is_python_3_or_above): w=w.encode("utf-8")
					eltenpipest.write(w)
					lastSend=time.time()
				if(lastSend<time.time()-1 and appModuleHandler.getAppModuleForNVDAObject(api.getForegroundObject())==eltenmod):
					eltenqueue['statuses'].append("noop")
					lastSend=time.time()
			except:
				time.sleep(0.05)
				eltenqueue={'gestures':[], 'indexes':[], 'statuses':[]}
				pass

	if is_python_3_or_above:
		t1=threading.Thread(target=elten_thread)
		t1.daemon=True
		t1.start()
		t2=threading.Thread(target=elten_braille_thread)
		t2.daemon=True
		t2.start()
		t3=threading.Thread(target=elten_queue_thread)
		t3.daemon=True
		t3.start()
	else:
		thread.start_new_thread ( elten_thread, ('elten', ))
		thread.start_new_thread ( elten_braille_thread, ('elten_braille', ))
		thread.start_new_thread ( elten_queue_thread, ('elten_queue', ))

	def terminate(self):
		stopThreads=True
		time.sleep(0.1)

def elten_command(ac):
	global eltenmod
	global eltenbraille
	global eltenbrailletext
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
			if(speech.isBlank(text)==False): queueHandler.queueFunction(queueHandler.eventQueue,speech.speakText,text)
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
					if(speech.isBlank(texts[i])): continue
					if(i<len(indexes)): v.append(EltenIndexCallback(indexes[i], indid))
					if(i<len(indexes) and texts[i-1][-1]=="\n"): v.append(speech.EndUtteranceCommand())
				else:
					eltenindexid=indid
					if(i<len(indexes)): v.append(speech.IndexCommand(indexes[i]))
				v.append(texts[i])
			speech.cancelSpeech()
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
			pid=0
			if('pid' in ac): pid=ac['pid']
			eltenmod = appModuleHandler.getAppModuleFromProcessID(pid)
			def script_eltengesture(self, gesture):
				global eltenqueue
				eltenqueue['gestures']+=gesture.identifiers
			eltenmod.__class__.script_eltengesture = types.MethodType(script_eltengesture, eltenmod.__class__)
			eltenmod.bindGesture('kb(laptop):NVDA+A', 'eltengesture')
			eltenmod.bindGesture('kb(laptop):NVDA+L', 'eltengesture')
			eltenmod.bindGesture('kb(desktop):NVDA+downArrow', 'eltengesture')
			eltenmod.bindGesture('kb(desktop):NVDA+upArrow', 'eltengesture')
		if(ac['ac']=='braille'):
			text=""
			if('text' in ac): text=ac['text']
			if('type' in ac and 'index' in ac):
				if ac['type']==-1: text=eltenbrailletext[:ac['index']]+eltenbrailletext[ac['index']+1:]
				elif ac['type']==1: text=eltenbrailletext[:ac['index']]+text+eltenbrailletext[ac['index']:]
			eltenbrailletext=text+" "
			region = braille.TextRegion(text)
			eltenbraille.regions=[region]
			region.update()
			if('pos' in ac): 
				poses = eltenbraille.rawToBraillePos
				if(ac['pos']<len(text) and ac['pos']<len(poses)):
					eltenbraille.scrollTo(region, poses[ac['pos']])
				region.cursorPos=ac['cursor']
				region.update()
			eltenbraille.update()
			braille.handler.update()
		if(ac['ac']=='braillepos' and 'pos' in ac and len(eltenbraille.regions)>0):
			poses = eltenbraille.rawToBraillePos
			if(ac['pos']<len(poses)): eltenbraille.scrollTo(eltenbraille.regions[0], poses[ac['pos']])
			eltenbraille.regions[0].cursorPos=ac['cursor']
			eltenbraille.regions[0].update()
			eltenbraille.update()
			braille.handler.update()
		if(ac['ac']=='getversion'):
			return {'version': 21}
		if(ac['ac']=='getnvdaversion'):
			return {'version': buildVersion.version}
		if(ac['ac']=='getindex'):
			if(is_python_3_or_above):
				return {'index': eltenindex, 'indid': eltenindexid}
			else:
				return {'index': speech.getLastSpeechIndex(), 'indid': eltenindexid}
	except: return {}
	return {}