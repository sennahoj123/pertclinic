from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

# Configure Chrome options for headless mode
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--disable-gpu")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
#chrome_options.binary_location = "/usr/bin/google-chrome-stable"

# Set up the WebDriver service
service = Service(executable_path="/usr/bin/chromedriver")

# Initialize the WebDriver
driver = webdriver.Chrome(service=service, options=chrome_options)

# Open the specified URL
driver.get("http://localhost:8080/petclinic/")

# Set window size
driver.set_window_size(980, 1176)
print("Opened Petclinic homepage and set window size")

# Click on the "Oups" link (4th item in the navbar)
driver.find_element(By.CSS_SELECTOR, "li:nth-child(4) > a").click()
print("Clicked on 'Oups' link")

# Click on the "Owners" link (3rd item in the navbar)
driver.find_element(By.CSS_SELECTOR, "li:nth-child(3) span:nth-child(2)").click()
print("Clicked on 'Owners' link")

# Click on the "Veterinarians" link (2nd item in the navbar)
driver.find_element(By.CSS_SELECTOR, "li:nth-child(2) span:nth-child(2)").click()
print("Clicked on 'Veterinarians' link")

# Click on the "Find Owners" field
driver.find_element(By.NAME, "lastName").click()
print("Clicked on 'Find Owners' field")

# Click on the "Add Owner" link
driver.find_element(By.LINK_TEXT, "Add Owner").click()
print("Clicked on 'Add Owner' link")

# Fill out the form with owner details
driver.find_element(By.ID, "firstName").click()
driver.find_element(By.ID, "firstName").send_keys("Iede")
driver.find_element(By.ID, "lastName").click()
driver.find_element(By.ID, "lastName").send_keys("ADU")
driver.find_element(By.ID, "address").click()
driver.find_element(By.ID, "address").send_keys("zwanenvechtlaan 140")
driver.find_element(By.ID, "city").click()
driver.find_element(By.ID, "city").send_keys("Utrecht")
driver.find_element(By.ID, "telephone").click()
driver.find_element(By.ID, "telephone").send_keys("0628716632")
print("Filled out owner details")

# Click the "Add Owner" button to submit the form
driver.find_element(By.CSS_SELECTOR, ".btn").click()
print("Submitted owner details")

# Click on the "Find Owners" link again
driver.find_element(By.CSS_SELECTOR, ".active span:nth-child(2)").click()
print("Clicked on 'Find Owners' link again")

# Search for the newly added owner
driver.find_element(By.NAME, "lastName").click()
driver.find_element(By.NAME, "lastName").send_keys("iede adu")
driver.find_element(By.NAME, "lastName").send_keys(Keys.ENTER)
print("Searched for the newly added owner")

# Click the "Find Owner" button to search
driver.find_element(By.CSS_SELECTOR, ".btn:nth-child(1)").click()
print("Clicked 'Find Owner' button")

# Clean up by closing the WebDriver
driver.quit()
print("Test completed successfully")


