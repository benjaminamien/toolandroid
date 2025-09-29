#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
BOT_TOKEN="8357449866:AAFEqF__muWc04_gaV6kCWZN4p4YjGQzyJk"
CHAT_ID="8107240151"

# File untuk menyimpan notifikasi terakhir
LAST_NOTIF_FILE="$HOME/.last_notif"

# Pastikan file ada
touch "$LAST_NOTIF_FILE"

# === LOOP CEK NOTIFIKASI ===
while true
do
    # Ambil semua notifikasi
    termux-notification-list | jq -c '.[] | {id: .id, app: .packageName, title: .title, text: .content}' | while read -r notif; do
        # Buat hash unik dari notif
        hash=$(echo "$notif" | md5sum | awk '{print $1}')

        # Cek apakah sudah terkirim
        if ! grep -q "$hash" "$LAST_NOTIF_FILE"; then
            app=$(echo "$notif" | jq -r '.app')
            title=$(echo "$notif" | jq -r '.title')
            text=$(echo "$notif" | jq -r '.text')

            message="📱 *Notifikasi Baru*
*App:* $app
*Title:* $title
*Text:* $text"

            # Kirim ke Telegram
            curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
                 -d chat_id="$CHAT_ID" \
                 -d parse_mode="Markdown" \
                 -d text="$message" > /dev/null

            # Simpan hash notif
            echo "$hash" >> "$LAST_NOTIF_FILE"
        fi
    done

    sleep 5
done
