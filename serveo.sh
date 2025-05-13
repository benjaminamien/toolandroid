#!/data/data/com.termux/files/usr/bin/bash

BOT_TOKEN="7450852198:AAEJrO8y3gqaWFECOW87VtOpOtx13_WwrXg"
CHAT_ID="8107240151"
LOCAL_PORT=8022

kirim_telegram() {
    local pesan="$1"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$pesan" > /dev/null
}

while true; do
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo "[+] Koneksi internet aktif."
        rm -f serveo_log.txt

        echo "[*] Menghubungkan ke Serveo..."
        ssh -o StrictHostKeyChecking=no -R 0:localhost:$LOCAL_PORT serveo.net > serveo_log.txt 2>&1 &
        SSH_PID=$!

        echo "[*] Menunggu TCP URL dari Serveo..."
        TIMEOUT=30
        TCP_URL=""
        for ((i=0; i<TIMEOUT; i++)); do
            TCP_URL=$(grep -oE "serveo\.net:[0-9]+" serveo_log.txt | head -n 1)
            if [[ -n "$TCP_URL" ]]; then
                break
            fi
            sleep 1
        done

        if [[ -n "$TCP_URL" ]]; then
            echo "[+] TCP URL ditemukan: $TCP_URL"
            kirim_telegram "Serveo aktif: $TCP_URL (forward ke localhost:$LOCAL_PORT)"
        else
            echo "[!] Gagal mendapatkan URL Serveo dalam $TIMEOUT detik."
            kirim_telegram "Serveo GAGAL: Tidak ada TCP URL setelah $TIMEOUT detik"
        fi

        echo "[*] Menunggu Serveo mati..."
        wait $SSH_PID
        echo "[!] Serveo putus. Mengulang dalam 10 detik..."
        sleep 10
    else
        echo "[!] Tidak ada koneksi. Coba ulangi dalam 10 detik..."
        sleep 10
    fi
done
