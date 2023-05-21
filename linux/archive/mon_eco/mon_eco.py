def dropbox_saveurl(in_url,in_fname):
    import requests
    ACCESS_TOKEN='-sjUrUjSmOAAAAAAAAACtdxwQ976dJRT7-h6CFXkS7oYfdDoIhGO5mzLz8iOulvp'
    import json
    url="https://api.dropboxapi.com/2/files/save_url"
    headers={"Authorization":"Bearer %s"%ACCESS_TOKEN,"Content-Type":"application/json"}
    data={"path":"/%s"%in_fname,"url":in_url}
    r=requests.post(url,headers=headers,data=json.dumps(data))
    return r.json()['async_job_id']

def dropbox_saveurl_checkstatus(in_async_job_id):
    import requests
    import json
    ACCESS_TOKEN='-sjUrUjSmOAAAAAAAAACtdxwQ976dJRT7-h6CFXkS7oYfdDoIhGO5mzLz8iOulvp'
    url="https://api.dropboxapi.com/2/files/save_url/check_job_status"
    headers={"Authorization": "Bearer %s"%ACCESS_TOKEN,"Content-Type": "application/json"}
    data={"async_job_id":in_async_job_id}
    # Wait some time for the saving to be complete.
    time_delay=60*10
    dt=5
    n=int(time_delay/dt)
    from time import sleep
    success=0
    for i in range(n):
        r=requests.post(url,headers=headers,data=json.dumps(data))
        tag=r.json()['.tag']
        if(tag=='complete'):
            success=1
            break
        else:
            sleep(dt)
    if(success==0):
        print(r.json())
        exit("Saving to Dropbox failed!")

record_fname="record.txt"
from os.path import dirname,join
record_fdir=dirname(__file__)
record_fpath=join(record_fdir,record_fname)
f=open(record_fpath,'r')
content=f.readlines()
last_issue=content[-1].strip()
last_issue_id=int(last_issue)

import xml.etree.ElementTree as etree
from urllib.request import Request,urlopen
xml_url='http://www.economist.com/audio-edition-podcast/6v7t6DR5agzAJnsJgMIABw/index.xml'
req=Request(xml_url,headers={'User-Agent':'Mozilla/5.0'})
xml_content=urlopen(req).read()
rss=etree.fromstring(xml_content)
channel=rss[0]
items=channel.findall('item')
item=items[0]
import re
nums=re.findall(r'\d+',item[0].text)
latest_issue_id=int(nums[0])

def send_simple_message(in_mail_account,in_subject,in_message):
    import requests
    DOMAIN_NAME="sandbox242ffd8b079949f1aca37a03edb8f236.mailgun.org"
    API_KEY="key-b4fb9ea63b6bfb1c55444795080f332c"
    r=requests.post("https://api.mailgun.net/v3/%s/messages"%DOMAIN_NAME,auth=("api",API_KEY),data={"from":"Mailgun Robot<mailgun@%s>"%DOMAIN_NAME,"to":["%s"%in_mail_account],"subject":in_subject,"text":in_message})
    return r

if(latest_issue_id>last_issue_id):
    mail_acc="jingchangshi@gmail.com"
    subject="Economist: Issue %d. Audio is released."%latest_issue_id
    guids=item.findall('guid')
    guid=guids[0]
    issue_audio_url=guid.text[:-3]+"zip"
    idx=guid.text.find('Issue')
    saved_fname=guid.text[idx:-3]+"zip"
    #  job_id=dropbox_saveurl(issue_audio_url,saved_fname)
    #  dropbox_saveurl_checkstatus(job_id)
    from subprocess import call
    from shlex import split
    cmd="/home/jcshi/Softwares/calibre/bin/ebook-convert economist.recipe The_Economist_Issue_%d.mobi"%latest_issue_id
    call(split(cmd))
    cmd="/home/jcshi/Softwares/calibre/bin/calibre-smtp -v -s \'The Economist Issue %d\' jingchangshi@gmail.com jingchangshi+amazon@kindle.cn \'The Economist Issue %d Print Version\' -a The_Economist_Issue_%d.mobi"%(latest_issue_id,latest_issue_id,latest_issue_id)
    call(split(cmd))
    message="The latest audio of Issue %d of Economist has already been saved into Dropbox."%latest_issue_id
    with open(record_fpath,"a") as f:
        f.write("%d\n"%latest_issue_id)
    send_simple_message(mail_acc,subject,message)
