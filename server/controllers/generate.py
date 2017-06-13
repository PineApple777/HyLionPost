import os
import sys
import threading
sys.path.insert(0,'/Users/Jungsunwook/HyLionPost/crawlers')

from selenium import webdriver
from crawler.csck2notice import csck2notice
from crawler.csjob import csjob
from crawler.csgradu import csgradu
from crawler.csnotice import csnotice
from crawler.csstrk import csstrk
from crawler.demon import demon
import codecs
import json
import time

# firebase db part
from dbconn import *
import pyrebase

# notification part
from pushnotify import *

crawl = '../crawlers/crawler/result/'

# main proceed part

def lion_running (name):
    data = codecs.open(crawl + name +'.json', 'r', encoding ='utf-8')
    try :
        new_datas = json.load(data)
    except json.decoder.JSONDecodeError as e :
        print('[ HANDLING ] ')
        print(e)
        return 1
    old_data = load_lionbase(name).val()
    filter_notify_func(name,new_datas,old_data)
    print('[ ' + name.upper() +' ] Server waiting...\n')
    return 0


# crawler and server connection part
def csck2notice_server():
    while True :
        csck2notice(webdriver.Chrome('/Users/Jungsunwook/HyLionPost/crawlers/res/chromedriver'))
        if lion_running("csck2notice") :
            continue
        time.sleep(15)

def csjob_server():
    while True :
        csjob(webdriver.Chrome('/Users/Jungsunwook/HyLionPost/crawlers/res/chromedriver')) 
        if lion_running("csjob") :
            continue
        time.sleep(15)

def csgradu_server():
    while True :
        csgradu(webdriver.Chrome('/Users/Jungsunwook/HyLionPost/crawlers/res/chromedriver'))
        if lion_running("csgradu") :
            continue
        time.sleep(15)

def csnotice_server():
    while True :
        csnotice(webdriver.Chrome('/Users/Jungsunwook/HyLionPost/crawlers/res/chromedriver'))
        if lion_running("csnotice") :
            continue
        time.sleep(15)

def csstrk_server():
    while True :
        csstrk(webdriver.Chrome('/Users/Jungsunwook/HyLionPost/crawlers/res/chromedriver'))
        if lion_running("csstrk") :
            continue
        time.sleep(15)

# test crawler part
def demo_server():
    while True :
        demon(webdriver.Chrome('/Users/Jungsunwook/HyLionPost/crawlers/res/chromedriver'))
        if lion_running("demon") :
            continue
        time.sleep(15)



