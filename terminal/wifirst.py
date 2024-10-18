#!/bin/env python3

import sched, time
import urllib.request
import os, json

success_url = "https://www.google.fr"
error_url = "https://portal-front.wifirst.net"


def reset_mac():
    if os.getlogin() == "jing":
        cmd = r"""
            dev=$(/bin/ip link | /bin/grep -o -P 'wl[^:]+')
            sudo /bin/ip link set $dev down
            sudo /bin/macchanger -r $dev
            sudo /bin/ip link set $dev up"""
        os.system(cmd)
    elif os.environ["TERMUX_VERSION"] != "":
        cmd = r"""
            su shell -c svc data disable
            wifi=$(sudo cmd wifi status) 
            current_ssid=$(echo $wifi | grep -o -P 'SSID: "\K.*(?=",)')
            su shell -c cmd wifi forget-network $(echo $wifi | grep -o -P 'Net ID: \K\d+')
            sudo cmd wifi connect-network "$current_ssid" open -r non_persistent"""
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
                except:
                    time.sleep(2)
            login_wifirst()
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


def hack_wifirst():
    hostname = "wireless.wifirst.net"
    param = '-n' if os.sys.platform.lower() == 'win32' else '-c'
    response = os.system(f"ping {param} 1 {hostname}")

    if response == 0:
        next_round = 10 * 60
        for event in scheduler.queue:
            scheduler.cancel(event)
        if captive_time() < 10:
            logout_wifirst()
            login_wifirst()
            scheduler.enter(next_round, 1, hack_wifirst)
        else:
            scheduler.enter(captive_time(), 1, hack_wifirst)
    else:
        print("Not connected to Wifirst")


hack_wifirst()
scheduler.run(blocking=True)
