#!/bin/env python3

import sched
import time
import urllib.request
import os
import sys
import subprocess
import re
import json

success_url = "https://www.google.fr"
error_url = "https://portal-front.wifirst.net"


def reset_mac():
    if sys.platform.lower() == 'win32':
        profile_name = None
        xml_filename = None

        try:
            # Step 1: Find the profile name of the current Wi-Fi network
            result = subprocess.run(
                ['netsh', 'wlan', 'show', 'interfaces'],
                capture_output=True, text=True, check=True, encoding='utf-8',
                errors='ignore'
            )
            profile_match = re.search(r"Profile\s+:\s(.*)", result.stdout)

            if not profile_match or not profile_match.group(1).strip():
                print(
                    "Could not find an active Wi-Fi profile.")
                return

            profile_name = profile_match.group(1).strip()
            # Sanitize filename, although netsh handles this well.
            safe_profile_name = re.sub(r'[<>:"/\\|?*]', '', profile_name)
            xml_filename = f"Wi-Fi-{safe_profile_name}.xml"
            print(f"Found active Wi-Fi profile: '{profile_name}'")

            # Step 2: Export the current profile to an XML file
            print(f"Exporting profile to '{xml_filename}'...")
            command = f"netsh wlan export profile name=\"{profile_name}\""
            if os.system(command) != 0:
                print(f"Error: Failed to export profile '{profile_name}'.")
                return

            # Step 3: Modify the randomizationSeed in the XML file
            print("Modifying randomizationSeed...")
            with open(xml_filename, 'r', encoding='utf-8') as f:
                xml_content = f.read()

            new_seed = str(int(time.time()))

            # Use regex to find and replace the seed value safely
            updated_content, replacements = re.subn(
                r'(<randomizationSeed>)\d+(</randomizationSeed>)',
                rf'\g<1>{new_seed}\g<2>',
                xml_content
            )

            if replacements > 0:
                with open(xml_filename, 'w', encoding='utf-8') as f:
                    f.write(updated_content)
                print(f"Set randomizationSeed to {new_seed}")
            else:
                print("Warning: <randomizationSeed> tag not found.")
                # The script will still proceed, but the MAC might not change.

            # Step 4: Delete the current profile
            print(f"Deleting profile '{profile_name}'...")
            command = f"netsh wlan delete profile name=\"{profile_name}\""
            if os.system(command) != 0:
                print(f"Error: Failed to delete profile '{profile_name}'.")
                return

            # Step 5: Add the modified profile from the XML file
            print(f"Adding modified profile from '{xml_filename}'...")
            abs_xml_path = os.path.abspath(xml_filename)
            command = f"netsh wlan add profile filename=\"{abs_xml_path}\""
            if os.system(command) != 0:
                print(f"Error: Failed to add profile from '{xml_filename}'.")
                return

            # Step 6: Connect to the newly added profile
            print(f"Connecting to '{profile_name}'...")
            command = f"netsh wlan connect name=\"{profile_name}\""
            if os.system(command) != 0:
                print(f"Error: Failed to connect to '{profile_name}'.")
                return

            print("A new random MAC address should be active.")

        except FileNotFoundError:
            print(
                "Error: 'netsh' command not found.")
        except subprocess.CalledProcessError as e:
            error_output = e.stdout or e.stderr
            print(f"An error occurred executing a command: {e}")
            print(f"Command output:\n{error_output}")
        finally:
            # Clean up the created XML file
            if xml_filename and os.path.exists(xml_filename):
                os.remove(xml_filename)
    elif os.getlogin() == "jing":
        cmd = r"""
            dev=$(/bin/ip link | /bin/grep -o -P 'wlp[^:]+')
            sudo /bin/ip link set $dev down
            sudo /bin/macchanger -r $dev
            sudo /bin/ip link set $dev up"""
        os.system(cmd)
    elif os.environ["TERMUX_VERSION"] != "":
        cmd = r"""
            su shell -c svc data disable
            wifi=$(sudo cmd wifi status)
            ssid=$(echo $wifi | grep -o -P 'SSID: "\K.*(?=",)')
            netid=$(echo $wifi | grep -o -P 'Net ID: \K\d+')
            su shell -c cmd wifi forget-network $netid
            sudo cmd wifi connect-network "$ssid" open -r non_persistent
            """
        os.system(cmd)


class NoRedirect(urllib.request.HTTPRedirectHandler):

    def redirect_request(self, req, fp, code, msg, headers, newurl):
        if error_url + "/?code=2" == newurl:
            print("Login failed, resetting MAC address")
            reset_mac()
            while (True):
                try:
                    login_wifirst()
                    break
                except Exception as e:
                    print(f"Login error: {e}, retrying in 2s")
                    time.sleep(2)

            hack_wifirst()
        return None


urllib.request.install_opener(urllib.request.build_opener(NoRedirect))


def logout_wifirst():
    data = urllib.parse.urlencode({
        "success_url": success_url,
        "error_url": error_url
    })
    data = data.encode('ascii')
    try:
        urllib.request.urlopen(
            urllib.request.Request(
                "https://wireless.wifirst.net/goform/HtmlLogout",
                data,
                method='POST'))
    except urllib.error.HTTPError as e:
        if e.code != 302:
            raise e


def login_wifirst(login=int(round(time.time() * 1000))):
    data = urllib.parse.urlencode({
        "username": f"PAY/{login}@wifirst.net",
        "password": login,
        "success_url": success_url,
        "error_url": error_url
    })
    data = data.encode('ascii')
    try:
        urllib.request.urlopen(
            urllib.request.Request(
                "https://wireless.wifirst.net/goform/HtmlLoginRequest",
                data,
                method='POST'))
    except urllib.error.HTTPError as e:
        if e.code != 302:
            raise e


def captive_time():
    request = urllib.request.Request(
        "https://wireless.wifirst.net/captive-portal/api")
    request.add_header("Content-Type", "application/captive+json")
    with urllib.request.urlopen(request) as response:
        data = json.loads(response.read())
        if data["captive"]:
            return 0
        else:
            return data["seconds-remaining"]


scheduler = sched.scheduler(time.time, time.sleep)


def is_on_wifirst_network():
    url = "https://wireless.wifirst.net/index.txt"
    try:
        # We use a short timeout (5s) so the script doesn't hang if there's no connection
        with urllib.request.urlopen(url, timeout=5) as response:
            # If we get a 200 OK, we are successfully connected/authenticated
            return response.getcode() == 200
    except Exception:
        # If there's a timeout, DNS error, or 404, it's not "detected"
        return False


def hack_wifirst():
    # Now using the clean Python check
    if is_on_wifirst_network():
        next_round = 10 * 60

        # Clear existing tasks in scheduler
        for event in scheduler.queue:
            scheduler.cancel(event)

        if captive_time() < 10:
            logout_wifirst()
            login_wifirst()
            scheduler.enter(next_round, 1, hack_wifirst)
        else:
            scheduler.enter(captive_time(), 1, hack_wifirst)
    else:
        print("Not connected to Wifirst or portal unreachable")


# Start the loop
hack_wifirst()
scheduler.run(blocking=True)
