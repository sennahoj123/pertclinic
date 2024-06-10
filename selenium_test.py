from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Configure Chrome options for headless mode
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--disable-gpu")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
# chrome_options.binary_location = "/usr/bin/google-chrome-stable"

# Set up the WebDriver service
service = Service(executable_path="/usr/bin/chromedriver")

# Initialize the WebDriver
driver = webdriver.Chrome(service=service, options=chrome_options)

# Open the specified URL
driver.get("http://localhost:8080/petclinic/")
print("Opened Petclinic homepage")

# Set window size
driver.set_window_size(980, 1176)
print("Set window size")

# Define a function to wait and find elements
def wait_and_find(driver, by, selector, timeout=20):
    try:
        element = WebDriverWait(driver, timeout).until(
            EC.presence_of_element_located((by, selector))
        )
        return element
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

# Click on the "Oups" link (4th item in the navbar)
oups_link = wait_and_find(driver, By.CSS_SELECTOR, "li:nth-child(4) > a")
if oups_link:
    oups_link.click()
    print("Clicked on 'Oups' link")

# Click on the "Owners" link (3rd item in the navbar)
owners_link = wait_and_find(driver, By.CSS_SELECTOR, "li:nth-child(3) span:nth-child(2)")
if owners_link:
    owners_link.click()
    print("Clicked on 'Owners' link")

# Click on the "Veterinarians" link (2nd item in the navbar)
vets_link = wait_and_find(driver, By.CSS_SELECTOR, "li:nth-child(2) span:nth-child(2)")
if vets_link:
    vets_link.click()
    print("Clicked on 'Veterinarians' link")

# Click on the "Find Owners" field
find_owners_field = wait_and_find(driver, By.NAME, "lastName")
if find_owners_field:
    find_owners_field.click()
    print("Clicked on 'Find Owners' field")

# Click on the "Add Owner" link
add_owner_link = wait_and_find(driver, By.LINK_TEXT, "Add Owner")
if add_owner_link:
    add_owner_link.click()
    print("Clicked on 'Add Owner' link")

# Fill out the form with owner details
first_name_field = wait_and_find(driver, By.ID, "firstName")
if first_name_field:
    first_name_field.send_keys("Iede")
last_name_field = wait_and_find(driver, By.ID, "lastName")
if last_name_field:
    last_name_field.send_keys("ADU")
address_field = wait_and_find(driver, By.ID, "address")
if address_field:
    address_field.send_keys("zwanenvechtlaan 140")
city_field = wait_and_find(driver, By.ID, "city")
if city_field:
    city_field.send_keys("Utrecht")
telephone_field = wait_and_find(driver, By.ID, "telephone")
if telephone_field:
    telephone_field.send_keys("0628716632")
print("Filled out owner details")

# Click the "Add Owner" button to submit the form
submit_button = wait_and_find(driver, By.CSS_SELECTOR, ".btn")
if submit_button:
    submit_button.click()
    print("Submitted owner details")

# Click on the "Find Owners" link again
find_owners_link = wait_and_find(driver, By.CSS_SELECTOR, ".active span:nth-child(2)")
if find_owners_link:
    find_owners_link.click()
    print("Clicked on 'Find Owners' link again")

# Search for the newly added owner
last_name_search_field = wait_and_find(driver, By.NAME, "lastName")
if last_name_search_field:
    last_name_search_field.send_keys("iede adu")
    last_name_search_field.send_keys(Keys.ENTER)
    print("Searched for the newly added owner")

# Click the "Find Owner" button to search
find_owner_button = wait_and_find(driver, By.CSS_SELECTOR, ".btn:nth-child(1)")
if find_owner_button:
    find_owner_button.click()
    print("Clicked 'Find Owner' button")

# Clean up by closing the WebDriver
driver.quit()
print("Test completed successfully")
