from selenium import webdriver 
import sys
from selenium.selenium import selenium

profile = webdriver.FirefoxProfile()
profile.set_preference('browser.download.folderList', 2) # custom location
profile.set_preference('browser.download.manager.showWhenStarting', False)
profile.set_preference('browser.download.dir', '/home/jj/web')
profile.set_preference('browser.helperApps.neverAsk.saveToDisk', 'application/javascript')
profile.set_preference("browser.helperApps.alwaysAsk.force", False);
profile.set_preference("browser.download.manager.useWindow",False)
profile.set_preference("pdfjs.disabled", True)

browser=webdriver.Firefox(profile)
browser.get('http://visipedia-annotator.org/mturk/anno_task/')
username=browser.find_element_by_id('id_username')
username.send_keys('jpark3')
password=browser.find_element_by_id('id_password')
password.send_keys('0000\n')

#upload=browser.find_element_by_id('upload_images')
#upload.click()

#file_upload=browser.find_element_by_id('id_file')
#file_upload.send_keys('/media/My Passport/vision/piotr_toolbox/toolbox/detector/pedestrain.zip')


#from selenium.webdriver.support.ui import Select
#taxon=Select(browser.find_element_by_id('taxonDropDown'))
#taxon.select_by_visible_text('dolphin face')

#anno_type=Select(browser.find_element_by_id('typeDropDown'))
#anno_type.select_by_visible_text('Bounding Boxes')

#browser.find_element_by_id('download').click()
from time import sleep
sleep(1)

browser.find_element_by_xpath("//*[contains(text(), 'Label pedestrian in images0')]").click();
sleep(3)
print 'image'
browser.find_element_by_xpath("//*[contains(text(), 'Fetch Completed Assignments')]").click();
print 'fetch'
sleep(3)
#self.browser=browser;

#count=selenium.get_xpath_count(self,"//*[contains(text(), 'Workers')]")


#download=browser.find_element_by_xpath("//*[contains(text(), 'Download Annotations')]")
all_cookies = browser.get_cookies()
sessionid=all_cookies[0]['value']
csrftoken=all_cookies[1]['value']
cookie='csrftoken='+csrftoken+';'+'sessionid='+sessionid

url = browser.find_element_by_xpath("//*[contains(text(), 'Download Annotations')]").get_attribute("href");
import urllib2
opener = urllib2.build_opener()
opener.addheaders.append(('Cookie', 'csrftoken=aNjK5TTAg3TOO5CmsQ8r4xcVHOzBtxku; sessionid=sbstqy8vfs1aeo6whg002gn38djkcraq'))
response=opener.open(url)

dataDir = '/media/My Passport/vision/piotr_toolbox/detector/data/inria/cropped/';

f=open(dataDir+'cropped.json','w')
f.write(response.read())
