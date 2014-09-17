from selenium import webdriver 
from time import sleep
import sys

directory='/media/My Passport/vision/'

profile = webdriver.FirefoxProfile()
profile.set_preference('browser.download.folderList', 2) # custom location
profile.set_preference('browser.download.manager.showWhenStarting', False)
profile.set_preference('browser.download.dir', '/home/jj/web')
profile.set_preference('browser.helperApps.neverAsk.saveToDisk', 'application/javascript')
profile.set_preference("browser.helperApps.alwaysAsk.force", False);
profile.set_preference("browser.download.manager.useWindow",False)
profile.set_preference("pdfjs.disabled", True)

browser=webdriver.Firefox(profile)
browser.get('http://visipedia-annotator.org')
sleep(1)
username=browser.find_element_by_id('id_username')
username.send_keys('jpark3')
password=browser.find_element_by_id('id_password')
password.send_keys('0000\n')

sleep(1)
upload=browser.find_element_by_id('upload_images')
upload.click()

sleep(1)
file_upload=browser.find_element_by_id('id_file')
file_upload.send_keys(directory+'piotr_toolbox/toolbox/detector/data/inria/cropped/cropped.zip')

browser.find_element_by_id('id_category name').send_keys('pedestrian n')
browser.find_element_by_id('submit_button')

browser.get('http://visipedia-annotator.org/mturk/anno_task/new/')
sleep(1)

from selenium.webdriver.support.ui import Select
anno_model=Select(browser.find_element_by_id('id_task-anno_model'))
anno_model.select_by_visible_text('pedestrian')

category=Select(browser.find_element_by_id('id_task-category'))
category.select_by_visible_text('pedestrian2')

title=browser.find_element_by_id('id_hit-title')
title.send_keys('Label pedestrian in images(n)')

submit=browser.find_element_by_xpath("//*[contains(text(), 'Create New Annotation Task')]")
