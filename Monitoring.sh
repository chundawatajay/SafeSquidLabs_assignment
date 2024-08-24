#!/bin/bash


top_applications() {
    echo "Top 10 CPU consuming applications:"
    ps aux --sort=-%cpu | head -n 11

    echo "Top 10 memory consuming applications:"
    ps aux --sort=-%mem | head -n 11
}


network_monitoring() {
    echo "Number of concurrent connections to the server:"
    netstat -an | grep ESTABLISHED | wc -l

    echo "Packet drops:"
    netstat -s | grep "packet loss"

    echo "Network traffic (in MB):"
    ifconfig | awk '/RX bytes/ {print $3 " " $4}' | awk -F":" '{rx+=$2} END {print "Received: " rx/1024/1024 " MB"}'
    ifconfig | awk '/TX bytes/ {print $7 " " $8}' | awk -F":" '{tx+=$2} END {print "Transmitted: " tx/1024/1024 " MB"}'
}


disk_usage() {
    echo "Disk usage by mounted partitions:"
    df -h

    echo "Partitions using more than 80% of the space:"
    df -h | awk '$5 > 80 {print $0}'
}


system_load() {
    echo "Current system load average:"
    uptime

    echo "CPU usage breakdown:"
    mpstat
}


memory_usage() {
    echo "Memory usage:"
    free -h

    echo "Swap memory usage:"
    swapon --show
}


process_monitoring() {
    echo "Number of active processes:"
    ps aux | wc -l

    echo "Top 5 processes by CPU usage:"
    ps aux --sort=-%cpu | head -n 6

    echo "Top 5 processes by memory usage:"
    ps aux --sort=-%mem | head -n 6
}


service_monitoring() {
    services=(sshd nginx apache2 iptables)
    for service in "${services[@]}"; do
        systemctl is-active --quiet $service && echo "$service is running" || echo "$service is not running"
    done
}


show_help() {
    echo "Usage: $0 [-cpu] [-memory] [-network] [-disk] [-process] [-services] [-all]"
    echo "Options:"
    echo "  -cpu       Show CPU usage and system load"
    echo "  -memory    Show memory usage"
    echo "  -network   Show network monitoring"
    echo "  -disk      Show disk usage"
    echo "  -process   Show process monitoring"
    echo "  -services  Show service monitoring"
    echo "  -all       Show all monitoring information"
}


case "$1" in
    -cpu)
        system_load
        ;;
    -memory)
        memory_usage
        ;;
    -network)
        network_monitoring
        ;;
    -disk)
        disk_usage
        ;;
    -process)
        process_monitoring
        ;;
    -services)
        service_monitoring
        ;;
    -all)
        system_load
        memory_usage
        network_monitoring
        disk_usage
        process_monitoring
        service_monitoring
        ;;
    *)
        show_help
        ;;
esac
