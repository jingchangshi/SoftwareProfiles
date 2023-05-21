import re
import requests
from bs4 import BeautifulSoup
from datetime import datetime

MUCHONG_USERNAME = 'bxsjc'  # write your username and password here
MUCHONG_PASSWORD = 'bxsjc19920728'

def getBibItemByDOI(doi_str):
    if(doi_str == ''):
        exit("DOI %s is invalid!"%(doi_str))
    import requests
    url = "https://dx.doi.org/" + doi_str
    headers = {"accept": "application/x-bibtex"}
    response = requests.get(url, headers=headers)
    BibContentStr = response.text
    from io import StringIO
    bibtex_tmp_f = StringIO(BibContentStr)
    import bibtexparser
    from bibtexparser.bparser import BibTexParser
    parser = BibTexParser(common_strings=True)
    bib_database = bibtexparser.load(bibtex_tmp_f, parser=parser)
    # Handle bad chars
    bib_item = bib_database.entries[0]
    if ('journal' in bib_item):
        journal_str = bib_item['journal']
        # Remove the substring between ()
        if ('(' in journal_str):
            idx1 = journal_str.index('(')
            idx2 = journal_str.index(')')
            bib_database.entries[0]['journal'] = journal_str[:idx1]+' '+journal_str[idx2:]
    return bib_database

def getTitleFromBibItem(bib_item_dict):
    if ('title' in bib_item_dict):
        title_str = bib_item_dict['title']
        #
        if ('{' in title_str):
            if ('{\\textendash}' in title_str):
                idx1 = title_str.index('{')
                idx2 = title_str.index('}')
                title_str = title_str[:idx1]+'-'+title_str[idx2+1:]
    else:
        exit('Key Error in bib item dict!')
    return title_str

class MuChong(object):

    def __init__(self, username, password):
        self.headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36',
                        'Origin': 'http://muchong.com',
                        'Host': 'muchong.com'}
        self.username = username
        self.password = password
        self.session = requests.session()
        self.session.headers = self.headers
        self.fail_fpath = '/tmp/muchong.fail'

    def login(self):
        resp = self.session.get('http://muchong.com/bbs/logging.php?action=login')
        my_formhash = re.search(r'name="formhash" value="(\w{8})"', resp.text).group(1)
        login_t = re.search(r't=(\d{10})', resp.text).group(1)
        login_url = 'http://muchong.com/bbs/logging.php?action=login&t='+login_t
        my_data = {'formhash': my_formhash,
                   'refer': '',
                   'username': self.username,
                   'password': self.password,
                   'cookietime': '31536000',
                   'loginsubmit': '会员登录'}
        login_result = self.session.post(login_url, data=my_data)
        verify_calc = re.search(u'问题：(\d+)(\D+)(\d+)等于多少?', login_result.text)
        number1 = int(verify_calc.group(1))
        number2 = int(verify_calc.group(3))
        if verify_calc.group(2) == '加':
            my_answer = number1 + number2
        elif verify_calc.group(2) == '减':
            my_answer = number1 - number2
        elif verify_calc.group(2) == '乘以':
            my_answer = number1 * number2
        else:
            my_answer = number1 / number2

        my_post_sec_hash = re.search(r'name="post_sec_hash" value="(\w+)"', login_result.text).group(1)
        my_new_data = {'formhash': my_formhash,
                       'post_sec_code': my_answer,
                       'post_sec_hash': my_post_sec_hash,
                       'username': self.username,
                       'loginsubmit': '提交'}

        res = self.session.post(login_url, data=my_new_data)

    def check_in(self):
        resp = self.session.get('http://muchong.com/bbs/memcp.php?action=getcredit')
        with open('/tmp/muchong_login.log', 'a+') as f:
            try:
                if u'您现在的金币数' in resp.text:
                    print('今天已经登录！')
                    coins_number = BeautifulSoup(resp.text, 'html.parser').find('span', {'style': 'color:red;font-weight:bold;font-size:20px;'}).text
                    print('目前的金币数是：%s.' % coins_number)
                    f.write('当前时间为：%s. 今天已经登录，不用再重复登录了！\n' % datetime.now())
                elif u'您还没有登录' in resp.text:
                    print('登录异常，没有成功登录。')
                    fail_f = open(self.fail_fpath,'w')
                    fail_f.write('登录异常，没有成功登录。')
                    fail_f.close()
                else:
                    credit_formhash = BeautifulSoup(resp.text, 'html.parser').find('input', {'name': 'formhash'})['value']
                    credit_data = {'formhash': credit_formhash,
                                   'getmode': '1',
                                   'message': '',
                                   'creditsubmit': '领取红包'}
                    r = self.session.post('http://muchong.com/bbs/memcp.php?action=getcredit', data=credit_data)
                    get_coins_number = BeautifulSoup(r.text, 'html.parser').find('span', {'style': 'color:red;font-weight:bold;font-size:30px;'}).text
                    coins = BeautifulSoup(r.text, 'html.parser').find('span', {'style': 'color:red;font-weight:bold;font-size:20px;'}).text
                    print('今天领取了金币数为：%s' % get_coins_number)
                    print('目前的总金币数为：%s' % coins)
                    f.write('本次登录成功，具体时间为：%s. 得到的金币数为：%s. 目前的总金币数为：%s.\n' % (datetime.now(), get_coins_number, coins))
            except Exception as e:
                print('签到失败', e)

    def double_check(self):
        from os.path import isfile
        from os import remove
        tried_times = 1
        while(isfile(self.fail_fpath) and tried_times < 10):
            remove(self.fail_fpath)
            self.login()
            self.check_in()
            tried_times += 1
            #  cmd_str = '/home/jcshi/Softwares/Python/bin/python3 /home/jcshi/software_profile/linux/muchong.py checkin'
            #  from shlex import split
            #  cmd_list = split(cmd_str)
            #  from subprocess import call
            #  call(cmd_list)
            from time import sleep
            sleep(10)

    def askForHelp(self,doi_str,helpcredit=5):
        #
        if (helpcredit < 5 or helpcredit > 50):
            exit("helpcredit must be in [5,50], while now it is %d"%(helpcredit))
        #
        ask_help_url = 'http://muchong.com/bbs/post.php?action=newthread&fid=158'
        # Get bib info by DOI
        bib_item_database = getBibItemByDOI(doi_str)
        bib_item_title = getTitleFromBibItem(bib_item_database.entries[0])
        bib_item_author = bib_item_database.entries[0]['author']
        bib_item_year = bib_item_database.entries[0]['year']
        try:
            bib_item_journal = bib_item_database.entries[0]['journal']
        except KeyError:
            bib_item_journal = "Unknown"
        bib_item_doi = bib_item_database.entries[0]['doi']
        bib_item_url = bib_item_database.entries[0]['url']
        try:
            bib_item_volume = bib_item_database.entries[0]['volume']
        except KeyError:
            bib_item_volume = 0
        try:
            bib_item_number = bib_item_database.entries[0]['number']
        except KeyError:
            bib_item_number = 0
        try:
            bib_item_pages = bib_item_database.entries[0]['pages']
        except KeyError:
            bib_item_pages = 0
        #
        paper_info = {
            "helpcredit2": "%d"%(helpcredit),
            'info[1]': bib_item_author,
            "info[2]": bib_item_title,
            "info[3]": bib_item_journal,
            "info[4]": bib_item_year,
            "info[5]": "Volume %s, Issue %s, Page %s"%(bib_item_volume,bib_item_number,bib_item_pages),
            "info[6]": bib_item_doi,
            "info[7]": bib_item_url,
            "newtypeid": "369", # Journal paper
            "subject": ("[%d金币]求助期刊论文: %s"%(helpcredit,bib_item_journal)).encode(encoding='gbk'),
            "topicsubmit": ("提交帖子").encode(encoding='gbk')
            }
        print(paper_info)
        res = self.session.post(ask_help_url, data=paper_info)
        print("Asking for help is finished.")
        print("Check this link: %s"%(res.url))

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('op', choices = ['checkin', 'askhelp'], 
        help='Operation to do')
    parser.add_argument('--doi', nargs=1, type=str, default = '',
        help='DOI of the paper for the help')
    parser.add_argument('--helpcredit', type=int, nargs=1, default = [15],
        metavar='N', help='Credit score for the help')
    args = parser.parse_args()

    my_muchong = MuChong(MUCHONG_USERNAME, MUCHONG_PASSWORD)
    my_muchong.login()
    if ( args.op == 'checkin' ):
        my_muchong.check_in()
        my_muchong.double_check()
    elif ( args.op == 'askhelp' ):
        my_muchong.askForHelp(args.doi[0],helpcredit=args.helpcredit[0])

