# Tools for BB-Display
- Android APK for firmware update
- shell script for firmware update
- Windows powershell script for firmare update
- Windows exe (ps2exe generated), may invoke virus warning due to certificate

# Firmwareupdate des BB-Display

## iOS, iPadOS

1. **Shortcut installieren:**
   Öffne die Datei `bb-display.shortcut` um diese unter der App Shortscuts / Kurzbefehle zu installieren
2. **Kurzbefehl ausführen:**
   Im der App Kurtzbefehle den Befehl `BB-Display` zum Starten antippen. Der Befehl lädt automatisch eine Liste der verfügbaren Firmwaredateien.
3. **Firmware laden:**
   Gewünschte Firmware Version auswählen. Anschliessend wird abgefragt unter welcher Adresse das BB-Display zu erreichen ist.
4. **Upload abwarten:**
   Der Upload startet sofort, das BB-Display zeigt dabei die ganze Zeit `Firmare 0%`.
   Der Vorgang dauert ca. 1 Minute. BB-Display startet anschliessend automatisch neu. 

## Android
Die Datei BB-Display-Update-release-1.1.apk.zip laden und auspacken. Anschliessend das APK installieren, ggf. vorher das installieren von APKs in den Einstellungen aktivieren.

## Windows

1. **Programm starten:**  
   Öffnen Sie das Programm `update_gui.exe`.  
   **Hinweis:** Einige Virenscanner können einen Alarm auslösen, da das Programm keine digitale Signatur besitzt. Dies ist kein Fehler, sondern eine Sicherheitsmaßnahme.

2. **Firmware-Datei auswählen:**  
   Wählen Sie die zuvor heruntergeladene Firmware-Datei, z. B. `bb-display.v1.3.0-beta1.0` (oder neuer).

3. **IP-Adresse eintragen:**  
   - Falls das BB-Display im **Hotspot-Modus** arbeitet, verwenden Sie die feste IP-Adresse: `192.168.5.1`.  
   - Wenn das BB-Display mit einem WLAN-Router verbunden ist, tragen Sie die von Ihrem Router zugewiesene IP-Adresse ein.

   **IP-Adresse herausfinden:**  
   Die IP-Adresse wird auf der Titelseite des BB-Displays ("BB-Display") angezeigt. Tippen Sie dafür zweimal auf das rechte Touchfeld `>`.

---

## macOS, Linux, Windows (z. B. Git Shell)

1. **Vorbereitung:**  
   - Entpacken Sie die beiliegende Skript-Datei `update.sh` und speichern Sie sie ab.  
   - Öffnen Sie ein Terminal und navigieren Sie in das Verzeichnis, in dem sich die Datei befindet.  
   - Machen Sie das Skript ausführbar mit:  
     ```bash
     chmod +x upload.sh
     ```

2. **Firmware-Datei vorbereiten:**  
   Laden Sie die aktuelle Firmware-Datei, z. B. `bb-display.v1.3.0-beta1.0` (oder neuer), herunter und speichern Sie sie im selben Verzeichnis wie das Skript.

3. **IP-Adresse ermitteln:**  
   - Im **Hotspot-Modus** hat das BB-Display die feste IP-Adresse: `192.168.5.1`.  
   - Wenn das BB-Display mit einem WLAN-Router verbunden ist, ermitteln Sie die von Ihrem Router zugewiesene IP-Adresse.  

     **Hinweis:** Die IP-Adresse wird auf der Titelseite des BB-Displays ("BB-Display") angezeigt. Tippen Sie dafür zweimal auf das rechte Touchfeld `>`.

4. **Firmware hochladen:**  
   Starten Sie das Update mit folgendem Befehl:  
   ```bash
   ./upload.sh bb-display.v1.3.0-beta1.0 192.168.5.1
