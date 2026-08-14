#!/bin/bash

SERVICES=("NetworkManager" "pipewire" "pipewire-pulse" "wireplumber" "bluetooth" "sshd" "systemd-journald")

while true; do
    clear
    echo "=================================================="
    echo "       Мониторинг и управление службами           "
    echo "=================================================="
    echo -e "№\tCлужба\t\t\tСтатус"
    echo "--------------------------------------------------"

    for i in "${!SERVICES[@]}"; do
        SERVICE="${SERVICES[$i]}"
        
        if [[ "$SERVICE" == "pipewire" || "$SERVICE" == "pipewire-pulse" || "$SERVICE" == "wireplumber" ]]; then
            STATUS=$(systemctl --user is-active "$SERVICE" 2>/dev/null)
        else
            STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null)
        fi
        
        if [ "$STATUS" = "active" ]; then
            STATUS_COLOR="\e[32mвключен ($STATUS)\e[0m"
        else
            STATUS_COLOR="\e[31mвыключен ($STATUS)\e[0m"
        fi
        
        printf "%d)\t%-20s\t%b\n" $((i+1)) "$SERVICE" "$STATUS_COLOR"
    done

    echo "--------------------------------------------------"
    echo "q) Выход"
    echo "=================================================="
    
    read -p "Выберите номер службы или 'q': " CHOICE

    if [[ "$CHOICE" == "q" ]]; then
        clear
        break
    fi

    if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -le 0 ] || [ "$CHOICE" -gt "${#SERVICES[@]}" ]; then
        echo -e "\e[31mОшибка: неверный выбор!\e[0m"
        sleep 1.5
        continue
    fi

    INDEX=$((CHOICE-1))
    SEL_SERVICE="${SERVICES[$INDEX]}"

    if [[ "$SEL_SERVICE" == "pipewire" || "$SEL_SERVICE" == "pipewire-pulse" || "$SEL_SERVICE" == "wireplumber" ]]; then
        CMD="systemctl --user"
    else
        CMD="sudo systemctl"
    fi

    while true; do
        clear
        echo "Управление службой: $SEL_SERVICE"
        echo "--------------------------------------------------"
        echo "1) Запустить (start)"
        echo "2) Перезапустить (restart)"
        echo "3) Остановить (stop)"
        echo "4) Назад в главное меню"
        echo "--------------------------------------------------"
        read -p "Выберите действие: " ACTION

        case $ACTION in
            1)
                echo "Запуск $SEL_SERVICE..."
                $CMD start "$SEL_SERVICE"
                break
                ;;
            2)
                echo "Перезапуск $SEL_SERVICE..."
                $CMD restart "$SEL_SERVICE"
                break
                ;;
            3)
                echo "Остановка $SEL_SERVICE..."
                $CMD stop "$SEL_SERVICE"
                break
                ;;
            4)
                break
                ;;
            *)
                echo -e "\e[31mНеверное действие!\e[0m"
                sleep 1
                ;;
        esac
    done
done
